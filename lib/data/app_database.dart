import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Materiais de adesivo. `larguraMm` vem com 1,10 m (padrão) e `comprimentoMm`
/// (metragem do material) é opcional.
@DataClassName('MaterialRow')
class Materiais extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().unique()();
  IntColumn get precoPorMetroCentavos => integer()();
  IntColumn get larguraMm => integer().withDefault(const Constant(1100))();
  IntColumn get comprimentoMm => integer().nullable()();
}

/// Orçamentos salvos. `materialNome` e `precoPorMetroCentavos` são cópias do
/// momento de salvar (ADR-004), sem chave estrangeira para [Materiais].
@DataClassName('OrcamentoRow')
class Orcamentos extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get criadoEm => dateTime()();

  /// Nome de `TipoProducao`.
  TextColumn get tipo => text()();
  TextColumn get descricao => text().nullable()();
  IntColumn get larguraMm => integer().nullable()();
  IntColumn get comprimentoMm => integer().nullable()();
  TextColumn get materialNome => text().nullable()();
  IntColumn get precoPorMetroCentavos => integer().nullable()();
  IntColumn get fornecedorCentavos => integer().nullable()();
  IntColumn get custoCentavos => integer()();
  IntColumn get acrescimoBp => integer()();
  IntColumn get finalCentavos => integer()();
}

/// Configurações simples do app, em pares chave/valor.
@DataClassName('ConfiguracaoRow')
class Configuracoes extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text()();

  @override
  Set<Column> get primaryKey => {chave};
}

@DriftDatabase(tables: [Materiais, Orcamentos, Configuracoes])
class AppDatabase extends _$AppDatabase {
  /// Sem [executor], abre o banco no armazenamento do aparelho.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'sticker_control'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(orcamentos);
        await m.createTable(configuracoes);
      }
      if (from < 3) {
        await m.addColumn(materiais, materiais.larguraMm);
        await m.addColumn(materiais, materiais.comprimentoMm);
      }
    },
  );
}
