import 'dart:async';

import 'package:sticker_control/data/material_repository.dart';
import 'package:sticker_control/logic/calculo.dart';
import 'package:sticker_control/logic/material_validacao.dart';

/// Repositório em memória para testes de widget (sem banco nem timers).
class MaterialRepositoryFake implements MaterialRepository {
  final List<MaterialAdesivo> _itens = [];
  final _controller = StreamController<List<MaterialAdesivo>>.broadcast();
  int _proximoId = 1;

  List<MaterialAdesivo> get itens => List.unmodifiable(_itens);

  void _emitir() {
    final ordenados = [..._itens]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    _controller.add(ordenados);
  }

  @override
  Stream<List<MaterialAdesivo>> observarTodos() async* {
    yield [..._itens]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    yield* _controller.stream;
  }

  void _exigirNomeLivre(String nome, {int? ignorarId}) {
    if (_itens.any(
      (m) => m.id != ignorarId && m.nome.toLowerCase() == nome.toLowerCase(),
    )) {
      throw const ErroDeValidacao('Já existe um material com esse nome.');
    }
  }

  @override
  Future<void> criar({
    required String nome,
    required int precoPorMetroCentavos,
    int larguraMm = larguraMaximaProprioMm,
    int? comprimentoMm,
  }) async {
    final limpo = validarMaterial(
      nome: nome,
      precoPorMetroCentavos: precoPorMetroCentavos,
      larguraMm: larguraMm,
      comprimentoMm: comprimentoMm,
    );
    _exigirNomeLivre(limpo);
    _itens.add(
      MaterialAdesivo(
        id: _proximoId++,
        nome: limpo,
        precoPorMetroCentavos: precoPorMetroCentavos,
        larguraMm: larguraMm,
        comprimentoMm: comprimentoMm,
      ),
    );
    _emitir();
  }

  @override
  Future<void> atualizar(
    int id, {
    required String nome,
    required int precoPorMetroCentavos,
    int larguraMm = larguraMaximaProprioMm,
    int? comprimentoMm,
  }) async {
    final limpo = validarMaterial(
      nome: nome,
      precoPorMetroCentavos: precoPorMetroCentavos,
      larguraMm: larguraMm,
      comprimentoMm: comprimentoMm,
    );
    _exigirNomeLivre(limpo, ignorarId: id);
    final i = _itens.indexWhere((m) => m.id == id);
    _itens[i] = MaterialAdesivo(
      id: id,
      nome: limpo,
      precoPorMetroCentavos: precoPorMetroCentavos,
      larguraMm: larguraMm,
      comprimentoMm: comprimentoMm,
    );
    _emitir();
  }

  @override
  Future<void> excluir(int id) async {
    _itens.removeWhere((m) => m.id == id);
    _emitir();
  }
}
