import 'dart:math' as math;
import 'dart:ui';

// Funções de cor da seção 2.2 do recorte.md: contraste WCAG e mistura em sRGB.

int _canal(double v) => (v * 255).round();

/// Luminância relativa (WCAG 2.x) de [c], ignorando transparência.
double luminanciaRelativa(Color c) {
  double linear(double v) {
    final s = _canal(v) / 255;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * linear(c.r) + 0.7152 * linear(c.g) + 0.0722 * linear(c.b);
}

/// Razão de contraste WCAG entre [a] e [b], de 1 a 21.
double contraste(Color a, Color b) {
  final x = luminanciaRelativa(a);
  final y = luminanciaRelativa(b);
  return (math.max(x, y) + 0.05) / (math.min(x, y) + 0.05);
}

/// Mistura [a] com [b]: `t` = 0 devolve [a], `t` = 1 devolve [b].
Color misturar(Color a, Color b, double t) {
  int canal(double x, double y) =>
      (_canal(x) + (_canal(y) - _canal(x)) * t).round().clamp(0, 255);
  return Color.fromARGB(
    0xFF,
    canal(a.r, b.r),
    canal(a.g, b.g),
    canal(a.b, b.b),
  );
}

/// Escurece [cor] (mistura com preto em passos de 5%) até o contraste com
/// [fundo] chegar a [alvo]. Se nunca chegar, termina em preto.
Color escurecerAteContraste(Color cor, Color fundo, double alvo) {
  const preto = Color(0xFF000000);
  var passo = 0;
  var resultado = misturar(cor, cor, 0);
  while (contraste(resultado, fundo) < alvo && passo < 20) {
    passo++;
    resultado = misturar(cor, preto, passo / 20);
  }
  return resultado;
}
