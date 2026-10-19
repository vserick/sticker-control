import 'package:drift/drift.dart';

import '../logic/orcamento.dart';
import 'app_database.dart';

abstract class OrcamentoRepository {
  /// Todos os orçamentos, do mais recente para o mais antigo, atualizado a
  /// cada mudança.
  Stream<List<Orcamento>> observarTodos();

  /// Grava o orçamento com a data atual e devolve a versão salva.
  Future<Orcamento> salvar(RascunhoOrcamento rascunho);

  Future<void> excluir(int id);
}

class DriftOrcamentoRepository implements OrcamentoRepository {
  final AppDatabase _db;

  DriftOrcamentoRepository(this._db);

  @override
  Stream<List<Orcamento>> observarTodos() {
    final consulta = _db.select(_db.orcamentos)
      ..orderBy([
        (o) => OrderingTerm.desc(o.criadoEm),
        (o) => OrderingTerm.desc(o.id),
      ]);
    return consulta.watch().map((linhas) => linhas.map(_paraModelo).toList());
  }

  @override
  Future<Orcamento> salvar(RascunhoOrcamento r) async {
    final agora = DateTime.now();
    final descricao = r.descricao?.trim();
    final id = await _db
        .into(_db.orcamentos)
        .insert(
          OrcamentosCompanion.insert(
            criadoEm: agora,
            tipo: r.tipo.name,
            descricao: Value(
              descricao == null || descricao.isEmpty ? null : descricao,
            ),
            larguraMm: Value(r.larguraMm),
            comprimentoMm: Value(r.comprimentoMm),
            materialNome: Value(r.materialNome),
            precoPorMetroCentavos: Value(r.precoPorMetroCentavos),
            fornecedorCentavos: Value(r.fornecedorCentavos),
            custoCentavos: r.custoCentavos,
            acrescimoBp: r.acrescimoBp,
            finalCentavos: r.finalCentavos,
          ),
        );
    final linha = await (_db.select(
      _db.orcamentos,
    )..where((o) => o.id.equals(id))).getSingle();
    return _paraModelo(linha);
  }

  @override
  Future<void> excluir(int id) async {
    await (_db.delete(_db.orcamentos)..where((o) => o.id.equals(id))).go();
  }

  Orcamento _paraModelo(OrcamentoRow l) => Orcamento(
    id: l.id,
    criadoEm: l.criadoEm,
    tipo: TipoProducao.values.byName(l.tipo),
    descricao: l.descricao,
    larguraMm: l.larguraMm,
    comprimentoMm: l.comprimentoMm,
    materialNome: l.materialNome,
    precoPorMetroCentavos: l.precoPorMetroCentavos,
    fornecedorCentavos: l.fornecedorCentavos,
    custoCentavos: l.custoCentavos,
    acrescimoBp: l.acrescimoBp,
    finalCentavos: l.finalCentavos,
  );
}
