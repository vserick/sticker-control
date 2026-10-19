import 'dart:async';

import 'package:sticker_control/data/configuracao_repository.dart';
import 'package:sticker_control/data/orcamento_repository.dart';
import 'package:sticker_control/data/whatsapp.dart';
import 'package:sticker_control/logic/orcamento.dart';
import 'package:sticker_control/servicos.dart';

import 'material_repository_fake.dart';

class OrcamentoRepositoryFake implements OrcamentoRepository {
  final List<Orcamento> _itens = [];
  final _controller = StreamController<List<Orcamento>>.broadcast();
  int _proximoId = 1;

  List<Orcamento> get itens => List.unmodifiable(_itens);

  List<Orcamento> get _maisRecentesPrimeiro => _itens.reversed.toList();

  @override
  Stream<List<Orcamento>> observarTodos() async* {
    yield _maisRecentesPrimeiro;
    yield* _controller.stream;
  }

  @override
  Future<Orcamento> salvar(RascunhoOrcamento r) async {
    final salvo = Orcamento(
      id: _proximoId++,
      criadoEm: DateTime(2026, 10, 5, 14, 30),
      tipo: r.tipo,
      descricao: r.descricao,
      larguraMm: r.larguraMm,
      comprimentoMm: r.comprimentoMm,
      materialNome: r.materialNome,
      precoPorMetroCentavos: r.precoPorMetroCentavos,
      fornecedorCentavos: r.fornecedorCentavos,
      custoCentavos: r.custoCentavos,
      acrescimoBp: r.acrescimoBp,
      finalCentavos: r.finalCentavos,
    );
    _itens.add(salvo);
    _controller.add(_maisRecentesPrimeiro);
    return salvo;
  }

  @override
  Future<void> excluir(int id) async {
    _itens.removeWhere((o) => o.id == id);
    _controller.add(_maisRecentesPrimeiro);
  }
}

class ConfiguracaoRepositoryFake implements ConfiguracaoRepository {
  String? nomeEmpresa;
  String? modeloMensagem;

  @override
  Future<String?> lerModeloMensagem() async => modeloMensagem;

  @override
  Future<void> salvarModeloMensagem(String modelo) async {
    modeloMensagem = modelo.trim().isEmpty ? null : modelo.trim();
  }

  @override
  Future<String?> lerNomeEmpresa() async => nomeEmpresa;

  @override
  Future<void> salvarNomeEmpresa(String nome) async {
    nomeEmpresa = nome.trim().isEmpty ? null : nome.trim();
  }
}

class EnviadorWhatsAppFake implements EnviadorWhatsApp {
  final List<String> mensagens = [];
  bool disponivel = true;

  @override
  Future<bool> enviar(String mensagem) async {
    mensagens.add(mensagem);
    return disponivel;
  }
}

/// Serviços em memória, com acesso aos fakes para preparar e conferir estado.
class ServicosFake {
  final materiais = MaterialRepositoryFake();
  final orcamentos = OrcamentoRepositoryFake();
  final configuracoes = ConfiguracaoRepositoryFake();
  final whatsapp = EnviadorWhatsAppFake();

  Servicos get servicos => Servicos(
    materiais: materiais,
    orcamentos: orcamentos,
    configuracoes: configuracoes,
    whatsapp: whatsapp,
  );
}
