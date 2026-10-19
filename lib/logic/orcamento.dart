enum TipoProducao { propria, terceirizada }

/// Dados de um orçamento ainda não salvo. Valores em centavos, medidas em mm e
/// acréscimo em centésimos de percentual (50% = 5000).
///
/// O preço por metro e o nome do material são cópias do momento do cálculo
/// (snapshot, ADR-004): mudar o material depois não altera o orçamento.
class RascunhoOrcamento {
  final TipoProducao tipo;
  final String? descricao;

  /// Obrigatória na produção própria; opcional (informativa) na terceirizada.
  final int? larguraMm;

  /// Só na produção própria.
  final int? comprimentoMm;
  final String? materialNome;
  final int? precoPorMetroCentavos;

  /// Só na produção terceirizada.
  final int? fornecedorCentavos;
  final int custoCentavos;
  final int acrescimoBp;
  final int finalCentavos;

  const RascunhoOrcamento({
    required this.tipo,
    this.descricao,
    this.larguraMm,
    this.comprimentoMm,
    this.materialNome,
    this.precoPorMetroCentavos,
    this.fornecedorCentavos,
    required this.custoCentavos,
    required this.acrescimoBp,
    required this.finalCentavos,
  });
}

/// Orçamento salvo no histórico.
class Orcamento extends RascunhoOrcamento {
  final int id;
  final DateTime criadoEm;

  const Orcamento({
    required this.id,
    required this.criadoEm,
    required super.tipo,
    super.descricao,
    super.larguraMm,
    super.comprimentoMm,
    super.materialNome,
    super.precoPorMetroCentavos,
    super.fornecedorCentavos,
    required super.custoCentavos,
    required super.acrescimoBp,
    required super.finalCentavos,
  });
}
