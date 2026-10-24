import 'package:flutter/material.dart';

import 'tokens.dart';

class _GradePainter extends CustomPainter {
  const _GradePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = RecorteCores.grade
      ..strokeWidth = 1;
    for (var x = 0.5; x <= size.width; x += 16) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (var y = 0.5; y <= size.height; y += 16) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GradePainter o) => false;
}

/// Grade de mesa de corte do topo do Início (seção 3.14): linhas de 1 px a
/// cada 16 px, ~190 px de altura, sumindo para baixo. Decorativa.
class GradeMesa extends StatelessWidget {
  const GradeMesa({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: IgnorePointer(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (r) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.white, Colors.transparent],
            stops: [0, 0.55, 1],
          ).createShader(r),
          child: const SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(painter: _GradePainter()),
          ),
        ),
      ),
    );
  }
}
