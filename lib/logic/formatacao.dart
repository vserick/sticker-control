// Formatação de medidas, percentuais e datas no padrão brasileiro.

/// Milímetros como metros com vírgula: `1100` → `1,10`, `2000` → `2,00`,
/// `1125` → `1,125`. Sempre ao menos 2 casas.
String formatarMetros(int mm) {
  final frac = (mm % 1000).toString().padLeft(3, '0');
  final casas = frac.endsWith('0') ? frac.substring(0, 2) : frac;
  return '${mm ~/ 1000},$casas';
}

/// Centésimos de percentual como texto: `5000` → `50`, `1250` → `12,5`,
/// `1205` → `12,05`.
String formatarPercentual(int bp) {
  final inteiro = bp ~/ 100;
  final frac = bp % 100;
  if (frac == 0) return '$inteiro';
  if (frac % 10 == 0) return '$inteiro,${frac ~/ 10}';
  return '$inteiro,${frac.toString().padLeft(2, '0')}';
}

String _dois(int n) => n.toString().padLeft(2, '0');

/// `dd/MM/aaaa`.
String formatarData(DateTime d) =>
    '${_dois(d.day)}/${_dois(d.month)}/${d.year}';

/// `dd/MM/aaaa HH:mm`.
String formatarDataHora(DateTime d) =>
    '${formatarData(d)} ${_dois(d.hour)}:${_dois(d.minute)}';
