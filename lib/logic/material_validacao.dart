import 'calculo.dart';

/// Largura, em mm, com que todo material novo é cadastrado (1,10 m).
const larguraPadraoMaterialMm = 1100;

/// Valida os campos de um material e devolve o nome sem espaços nas pontas.
/// A unicidade do nome é checada pelo repositório.
String validarMaterial({
  required String nome,
  required int precoPorMetroCentavos,
  int larguraMm = larguraPadraoMaterialMm,
  int? comprimentoMm,
}) {
  final nomeLimpo = nome.trim();
  if (nomeLimpo.isEmpty) {
    throw const ErroDeValidacao('Informe o nome do material.');
  }
  if (precoPorMetroCentavos <= 0) {
    throw const ErroDeValidacao('O preço por metro deve ser maior que zero.');
  }
  if (larguraMm <= 0) {
    throw const ErroDeValidacao('A largura deve ser maior que zero.');
  }
  if (comprimentoMm != null && comprimentoMm <= 0) {
    throw const ErroDeValidacao('O comprimento deve ser maior que zero.');
  }
  return nomeLimpo;
}
