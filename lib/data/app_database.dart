import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// Materiais de adesivo. A largura (1,10 m) é fixa e não fica no banco.
@DataClassName('MaterialRow')
class Materiais extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nome => text().unique()();
  IntColumn get precoPorMetroCentavos => integer()();
}

@DriftDatabase(tables: [Materiais])
class AppDatabase extends _$AppDatabase {
  /// Sem [executor], abre o banco no armazenamento do aparelho.
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'sticker_control'));

  @override
  int get schemaVersion => 1;
}
