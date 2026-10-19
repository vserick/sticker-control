import 'data/configuracao_repository.dart';
import 'data/material_repository.dart';
import 'data/orcamento_repository.dart';
import 'data/whatsapp.dart';

/// Dependências do app, repassadas às telas (e trocadas por fakes nos testes).
class Servicos {
  final MaterialRepository materiais;
  final OrcamentoRepository orcamentos;
  final ConfiguracaoRepository configuracoes;
  final EnviadorWhatsApp whatsapp;

  const Servicos({
    required this.materiais,
    required this.orcamentos,
    required this.configuracoes,
    required this.whatsapp,
  });
}
