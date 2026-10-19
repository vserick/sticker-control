import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'linha_corte.dart';
import 'marca.dart';
import 'tokens.dart';

/// Cota (medida) horizontal 16×10 ou vertical 10×16: linha com setas e
/// batentes (seção 3.5). Fica antes de "Comprimento" e "Largura".
class IconeCota extends StatelessWidget {
  final bool vertical;
  final Color cor;

  const IconeCota.horizontal({super.key, this.cor = RecorteCores.rotulo})
    : vertical = false;

  const IconeCota.vertical({super.key, this.cor = RecorteCores.rotulo})
    : vertical = true;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: vertical ? const Size(10, 16) : const Size(16, 10),
        painter: _CotaPainter(vertical: vertical, cor: cor),
      ),
    );
  }
}

class _CotaPainter extends CustomPainter {
  final bool vertical;
  final Color cor;

  const _CotaPainter({required this.vertical, required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    // Desenhado na horizontal (16×10) e girado para a vertical.
    if (vertical) {
      canvas.translate(0, size.height);
      canvas.rotate(-math.pi / 2);
    }
    final p = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final caminho = Path()
      ..moveTo(1, 1)
      ..lineTo(1, 9)
      ..moveTo(15, 1)
      ..lineTo(15, 9)
      ..moveTo(1, 5)
      ..lineTo(15, 5)
      ..moveTo(4, 2.5)
      ..lineTo(1, 5)
      ..lineTo(4, 7.5)
      ..moveTo(12, 2.5)
      ..lineTo(15, 5)
      ..lineTo(12, 7.5);
    canvas.drawPath(caminho, p);
  }

  @override
  bool shouldRepaint(_CotaPainter o) => o.vertical != vertical || o.cor != cor;
}

class _FichaPainter extends CustomPainter {
  final Color? preenchimento;
  final Color contorno;

  const _FichaPainter({required this.preenchimento, required this.contorno});

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 36;
    if (preenchimento != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(6 * k, 6 * k, 24 * k, 24 * k),
          Radius.circular(6 * k),
        ),
        Paint()..color = preenchimento!,
      );
    }
    final caminho = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(2.75 * k, 2.75 * k, 30.5 * k, 30.5 * k),
          Radius.circular(9 * k),
        ),
      );
    desenharTracejado(
      canvas,
      caminho,
      Paint()
        ..color = contorno
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * k,
      traco: 3.5 * k,
      espaco: 3 * k,
    );
  }

  @override
  bool shouldRepaint(_FichaPainter o) =>
      o.preenchimento != preenchimento || o.contorno != contorno;
}

/// Ficha de modalidade (seção 3.11), 36×36.
/// Própria: quadrado interno na cor da marca com contorno tracejado.
/// Terceirizada: só o contorno, em cinza ("produzido fora").
/// Com [icone], desenha o ícone ao centro (ficha de material).
class FichaModalidade extends StatelessWidget {
  final bool propria;
  final IconData? icone;
  final double tamanho;

  const FichaModalidade({
    super.key,
    required this.propria,
    this.icone,
    this.tamanho = 36,
  });

  /// Ficha de material: igual à "Própria", com o ícone de camadas ao centro.
  const FichaModalidade.material({super.key})
    : propria = true,
      icone = Icons.layers_outlined,
      tamanho = 36;

  @override
  Widget build(BuildContext context) {
    final marca = context.marca;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: tamanho,
        child: CustomPaint(
          painter: _FichaPainter(
            preenchimento: propria ? marca.brandTint : null,
            contorno: propria ? marca.brandLinha : RecorteCores.contornoNeutro,
          ),
          child: icone == null
              ? null
              : Center(
                  child: Icon(
                    icone,
                    size: 16 * tamanho / 36,
                    color: propria ? marca.brandTexto : RecorteCores.rotulo,
                  ),
                ),
        ),
      ),
    );
  }
}

class _MarcaRegistroPainter extends CustomPainter {
  final Color ponto;

  const _MarcaRegistroPainter({required this.ponto});

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 26;
    final traco = Paint()
      ..color = RecorteCores.grafite
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6 * k;
    canvas.drawCircle(Offset(13 * k, 13 * k), 8 * k, traco);
    final cruz = Path()
      ..moveTo(13 * k, 1 * k)
      ..lineTo(13 * k, 8 * k)
      ..moveTo(13 * k, 18 * k)
      ..lineTo(13 * k, 25 * k)
      ..moveTo(1 * k, 13 * k)
      ..lineTo(8 * k, 13 * k)
      ..moveTo(18 * k, 13 * k)
      ..lineTo(25 * k, 13 * k);
    canvas.drawPath(cruz, traco);
    canvas.drawCircle(Offset(13 * k, 13 * k), 3.4 * k, Paint()..color = ponto);
  }

  @override
  bool shouldRepaint(_MarcaRegistroPainter o) => o.ponto != ponto;
}

/// Marca de registro: círculo e cruz em grafite, ponto central na marca.
class MarcaRegistro extends StatelessWidget {
  final double tamanho;

  const MarcaRegistro({super.key, this.tamanho = 26});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(tamanho),
        painter: _MarcaRegistroPainter(ponto: context.marca.brand),
      ),
    );
  }
}
