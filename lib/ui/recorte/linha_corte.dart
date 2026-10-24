import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Desenha [caminho] tracejado: o Flutter não tem borda tracejada pronta.
void desenharTracejado(
  Canvas canvas,
  Path caminho,
  Paint pincel, {
  required double traco,
  required double espaco,
}) {
  for (final PathMetric m in caminho.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      canvas.drawPath(m.extractPath(d, d + traco), pincel);
      d += traco + espaco;
    }
  }
}

class _TracejadoPainter extends CustomPainter {
  final Color cor;
  final double raio;
  final double espessura;
  final double traco;
  final double espaco;
  final double afastamento;

  const _TracejadoPainter({
    required this.cor,
    required this.raio,
    required this.espessura,
    required this.traco,
    required this.espaco,
    required this.afastamento,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final retangulo = (Offset.zero & size).inflate(afastamento);
    final caminho = Path()
      ..addRRect(
        RRect.fromRectAndRadius(retangulo, Radius.circular(raio + afastamento)),
      );
    final pincel = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = espessura;
    desenharTracejado(canvas, caminho, pincel, traco: traco, espaco: espaco);
  }

  @override
  bool shouldRepaint(_TracejadoPainter o) =>
      o.cor != cor ||
      o.raio != raio ||
      o.espessura != espessura ||
      o.traco != traco ||
      o.espaco != espaco ||
      o.afastamento != afastamento;
}

/// Contorno tracejado de plotter ao redor de [child], afastado [afastamento]
/// para fora. O contorno é pintado fora dos limites do filho; quem usa deve
/// reservar a margem externa (5 px na seção 3.6).
class LinhaDeCorte extends StatelessWidget {
  final Widget child;
  final Color cor;
  final double raio;
  final double afastamento;
  final double espessura;
  final double traco;
  final double espaco;

  const LinhaDeCorte({
    super.key,
    required this.child,
    this.cor = RecorteCores.grafite,
    this.raio = RecorteRaio.adesivo,
    this.afastamento = 4,
    this.espessura = 1.5,
    this.traco = 4,
    this.espaco = 3,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _TracejadoPainter(
        cor: cor,
        raio: raio,
        espessura: espessura,
        traco: traco,
        espaco: espaco,
        afastamento: afastamento,
      ),
      child: child,
    );
  }
}
