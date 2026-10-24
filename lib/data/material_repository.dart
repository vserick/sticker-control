import 'package:drift/drift.dart';

import '../logic/calculo.dart';
import '../logic/material_validacao.dart';
import 'app_database.dart';

/// Material de adesivo com preço por metro linear (em comprimento). A largura
/// padrão é 1,10 m; [comprimentoMm] é a metragem do rolo, quando informada.
class MaterialAdesivo {
  final int id;
  final String nome;
  final int precoPorMetroCentavos;
  final int larguraMm;
  final int? comprimentoMm;

  const MaterialAdesivo({
    required this.id,
    required this.nome,
    required this.precoPorMetroCentavos,
    this.larguraMm = larguraMaximaProprioMm,
    this.comprimentoMm,
  });
}

abstract class MaterialRepository {
  /// Todos os materiais em ordem alfabética, atualizado a cada mudança.
  Stream<List<MaterialAdesivo>> observarTodos();

  /// Lança [ErroDeValidacao] se o nome for vazio ou repetido, ou o preço <= 0.
  Future<void> criar({
    required String nome,
    required int precoPorMetroCentavos,
    int larguraMm = larguraMaximaProprioMm,
    int? comprimentoMm,
  });

  /// Mesmas validações de [criar]; o nome pode continuar o mesmo do material.
  Future<void> atualizar(
    int id, {
    required String nome,
    required int precoPorMetroCentavos,
    int larguraMm = larguraMaximaProprioMm,
    int? comprimentoMm,
  });

  Future<void> excluir(int id);
}

class DriftMaterialRepository implements MaterialRepository {
  final AppDatabase _db;

  DriftMaterialRepository(this._db);

  @override
  Stream<List<MaterialAdesivo>> observarTodos() {
    final consulta = _db.select(_db.materiais)
      ..orderBy([(m) => OrderingTerm.asc(m.nome.collate(Collate.noCase))]);
    return consulta.watch().map((linhas) => linhas.map(_paraModelo).toList());
  }

  @override
  Future<void> criar({
    required String nome,
    required int precoPorMetroCentavos,
    int larguraMm = larguraMaximaProprioMm,
    int? comprimentoMm,
  }) async {
    final nomeLimpo = validarMaterial(
      nome: nome,
      precoPorMetroCentavos: precoPorMetroCentavos,
      larguraMm: larguraMm,
      comprimentoMm: comprimentoMm,
    );
    await _exigirNomeLivre(nomeLimpo);
    await _db
        .into(_db.materiais)
        .insert(
          MateriaisCompanion.insert(
            nome: nomeLimpo,
            precoPorMetroCentavos: precoPorMetroCentavos,
            larguraMm: Value(larguraMm),
            comprimentoMm: Value(comprimentoMm),
          ),
        );
  }

  @override
  Future<void> atualizar(
    int id, {
    required String nome,
    required int precoPorMetroCentavos,
    int larguraMm = larguraMaximaProprioMm,
    int? comprimentoMm,
  }) async {
    final nomeLimpo = validarMaterial(
      nome: nome,
      precoPorMetroCentavos: precoPorMetroCentavos,
      larguraMm: larguraMm,
      comprimentoMm: comprimentoMm,
    );
    await _exigirNomeLivre(nomeLimpo, ignorarId: id);
    await (_db.update(_db.materiais)..where((m) => m.id.equals(id))).write(
      MateriaisCompanion(
        nome: Value(nomeLimpo),
        precoPorMetroCentavos: Value(precoPorMetroCentavos),
        larguraMm: Value(larguraMm),
        comprimentoMm: Value(comprimentoMm),
      ),
    );
  }

  @override
  Future<void> excluir(int id) async {
    await (_db.delete(_db.materiais)..where((m) => m.id.equals(id))).go();
  }

  /// Compara sem diferenciar maiúsculas (inclusive acentuadas) em Dart, já que
  /// o `UNIQUE` do SQLite só ignora caixa em ASCII.
  Future<void> _exigirNomeLivre(String nome, {int? ignorarId}) async {
    final alvo = nome.toLowerCase();
    final linhas = await _db.select(_db.materiais).get();
    final repetido = linhas.any(
      (m) => m.id != ignorarId && m.nome.toLowerCase() == alvo,
    );
    if (repetido) {
      throw const ErroDeValidacao('Já existe um material com esse nome.');
    }
  }

  MaterialAdesivo _paraModelo(MaterialRow linha) => MaterialAdesivo(
    id: linha.id,
    nome: linha.nome,
    precoPorMetroCentavos: linha.precoPorMetroCentavos,
    larguraMm: linha.larguraMm,
    comprimentoMm: linha.comprimentoMm,
  );
}
