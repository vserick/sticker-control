// Dinheiro em centavos inteiros e leitura/formatação no padrão brasileiro.
// Nunca usa ponto flutuante (ADR-006).

/// Divide `numerador / denominador` arredondando half-up (só valores >= 0).
int dividirHalfUp(int numerador, int denominador) {
  assert(numerador >= 0 && denominador > 0);
  return (numerador + denominador ~/ 2) ~/ denominador;
}

/// Formata centavos como `R$ 1.234,56`.
String formatarBrl(int centavos) {
  final negativo = centavos < 0;
  final abs = centavos.abs();
  final reais = (abs ~/ 100).toString();
  final cents = (abs % 100).toString().padLeft(2, '0');
  final milhares = reais.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '${negativo ? '-' : ''}R\$ $milhares,$cents';
}

final _prefixoReais = RegExp(r'^R\$\s*');
final _milharesComPonto = RegExp(r'^\d{1,3}(\.\d{3})+$');
final _numeroSimples = RegExp(r'^\d+(,\d+)?$');

/// Lê um número decimal digitado pelo usuário e devolve o valor multiplicado
/// por 10^[casas], como inteiro. Retorna `null` se o texto for inválido, for
/// negativo ou tiver mais casas decimais do que [casas].
///
/// A vírgula é o separador decimal; com vírgula presente, pontos são
/// separadores de milhar (`1.234,56`). Sem vírgula, um ponto é decimal
/// (`1.5`), exceto quando forma milhares exatos (`1.234`). Aceita prefixo `R$`.
///
/// - `lerDecimalEscalado('R$ 1.234,56', 2)` → `123456`
/// - `lerDecimalEscalado('1,1', 3)` → `1100`
int? lerDecimalEscalado(String texto, int casas) {
  var t = texto.trim().replaceFirst(_prefixoReais, '').replaceAll(' ', '');
  if (t.isEmpty) return null;

  if (t.contains(',')) {
    t = t.replaceAll('.', '');
  } else if (_milharesComPonto.hasMatch(t)) {
    t = t.replaceAll('.', '');
  } else {
    t = t.replaceFirst('.', ',');
  }
  if (!_numeroSimples.hasMatch(t)) return null;

  final partes = t.split(',');
  final decimais = partes.length > 1 ? partes[1] : '';
  if (decimais.length > casas) return null;

  return int.parse('${partes[0]}${decimais.padRight(casas, '0')}');
}

/// Lê um valor em reais (`12,50`) e devolve centavos, ou `null` se inválido.
int? lerCentavos(String texto) => lerDecimalEscalado(texto, 2);

/// Lê uma medida em metros (`1,10`) e devolve milímetros, ou `null`.
int? lerMetrosEmMm(String texto) => lerDecimalEscalado(texto, 3);

/// Lê um percentual (`12,5`) e devolve centésimos de percentual (1250).
int? lerPercentualEmBp(String texto) => lerDecimalEscalado(texto, 2);
