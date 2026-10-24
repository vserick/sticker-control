import 'dinheiro.dart';

/// Largura máxima, em mm, da produção própria (1,10 m). Vale quando o material
/// não informa a sua própria largura.
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

  /// Largura acima da largura do material (1,10 m por padrão) na produção
  /// própria: só aviso, não bloqueia.
  final bool avisoLargura;

  const ResultadoCalculo({
    required this.custoCentavos,
    required this.finalCentavos,
    this.avisoLargura = false,
  });
}

/// Produção própria: `custo = preço_m × comprimento` (a largura não altera o
/// custo, ADR-003) e `final = custo × (1 + acréscimo/100)`.
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
