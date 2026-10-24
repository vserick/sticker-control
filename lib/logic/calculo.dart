import 'dinheiro.dart';

/// Largura padrão, em mm, de um material novo (1,10 m): a da máquina atual.
const larguraMaximaProprioMm = 1100;

/// Dados inválidos para o cálculo (ex.: comprimento zero).
class ErroDeValidacao implements Exception {
  final String mensagem;
  const ErroDeValidacao(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Resultado de um cálculo. Valores em centavos.
class ResultadoCalculo {
  /// Custo base, antes do acréscimo (arredondado half-up para exibição).
  final int custoCentavos;

  /// Preço final ao cliente, arredondado half-up uma única vez.
  final int finalCentavos;

  /// Largura acima da do material na produção própria: só aviso, não bloqueia.
  final bool avisoLargura;

  /// Comprimento acima da metragem cadastrada do material: só aviso.
  final bool avisoComprimento;

  const ResultadoCalculo({
    required this.custoCentavos,
    required this.finalCentavos,
    this.avisoLargura = false,
    this.avisoComprimento = false,
  });
}

/// Produção própria: `custo = preço_m × comprimento` (a largura não altera o
/// custo, ADR-003) e `final = custo × (1 + acréscimo/100)`.
///
/// [larguraMaximaMm] é a largura do material escolhido (padrão 1,10 m); acima
/// dela só há aviso. [comprimentoMaximoMm], quando o material tem metragem
/// cadastrada, avisa se o pedido passar dela.
///
/// Unidades: preço em centavos por metro, medidas em milímetros e acréscimo em
/// centésimos de percentual (50% = 5000). Toda a conta é inteira; só o valor
/// final é arredondado.
ResultadoCalculo calcularProprio({
  required int precoMetroCentavos,
  required int comprimentoMm,
  required int larguraMm,
  required int acrescimoBp,
  int larguraMaximaMm = larguraMaximaProprioMm,
  int? comprimentoMaximoMm,
}) {
  _exigirPositivo(
    precoMetroCentavos,
    'O preço por metro deve ser maior que zero.',
  );
  _exigirPositivo(comprimentoMm, 'O comprimento deve ser maior que zero.');
  _exigirPositivo(larguraMm, 'A largura deve ser maior que zero.');
  _validarAcrescimo(acrescimoBp);

  final custoBase = precoMetroCentavos * comprimentoMm; // centavos × 1000
  return ResultadoCalculo(
    custoCentavos: dividirHalfUp(custoBase, 1000),
    finalCentavos: dividirHalfUp(
      custoBase * (10000 + acrescimoBp),
      1000 * 10000,
    ),
    avisoLargura: larguraMm > larguraMaximaMm,
    avisoComprimento:
        comprimentoMaximoMm != null && comprimentoMm > comprimentoMaximoMm,
  );
}

/// Produção terceirizada: `final = fornecedor × (1 + acréscimo/100)`.
ResultadoCalculo calcularTerceirizado({
  required int fornecedorCentavos,
  required int acrescimoBp,
}) {
  _exigirPositivo(
    fornecedorCentavos,
    'O valor do fornecedor deve ser maior que zero.',
  );
  _validarAcrescimo(acrescimoBp);

  return ResultadoCalculo(
    custoCentavos: fornecedorCentavos,
    finalCentavos: dividirHalfUp(
      fornecedorCentavos * (10000 + acrescimoBp),
      10000,
    ),
  );
}

void _exigirPositivo(int valor, String mensagem) {
  if (valor <= 0) throw ErroDeValidacao(mensagem);
}

void _validarAcrescimo(int acrescimoBp) {
  if (acrescimoBp < 0) {
    throw const ErroDeValidacao('O acréscimo não pode ser negativo.');
  }
}
