import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'linha_corte.dart';
import 'marca.dart';
import 'tipografia.dart';
import 'tokens.dart';

class _QuadradoTracejadoPainter extends CustomPainter {
  final Color cor;
  final double raio;
  final double traco;
  final double espaco;
  final bool preenchido;

  const _QuadradoTracejadoPainter({
    required this.cor,
    required this.raio,
    required this.traco,
    required this.espaco,
    required this.preenchido,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (preenchido) {
      final k = size.width / 88;
      final interno = RRect.fromRectAndRadius(
        Rect.fromLTWH(14 * k, 14 * k, 60 * k, 60 * k),
        Radius.circular(16 * k),
      );
      canvas.drawRRect(interno, Paint()..color = RecorteCores.superficie);
      canvas.drawRRect(
        interno,
        Paint()
          ..color = RecorteCores.borda
          ..style = PaintingStyle.stroke,
      );
    }
    final inset = 0.75 + (preenchido ? 6 : 4);
    final caminho = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            inset,
            inset,
            size.width - 2 * inset,
            size.height - 2 * inset,
          ),
          Radius.circular(raio),
        ),
      );
    desenharTracejado(
      canvas,
      caminho,
      Paint()
        ..color = cor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
      traco: traco,
      espaco: espaco,
    );
  }

  @override
  bool shouldRepaint(_QuadradoTracejadoPainter o) =>
      o.cor != cor || o.raio != raio || o.preenchido != preenchido;
}

/// Estado vazio (seção 3.12): ilustração de 88 px, título e texto centralizados.
class EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String texto;

  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: CustomPaint(
                size: const Size.square(88),
                painter: const _QuadradoTracejadoPainter(
                  cor: RecorteCores.contornoNeutro,
                  raio: 22,
                  traco: 5,
                  espaco: 4,
                  preenchido: true,
                ),
                child: SizedBox.square(
                  dimension: 88,
                  child: Icon(icone, size: 28, color: RecorteCores.rotulo),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: RecorteTexto.tituloEstado,
            ),
            const SizedBox(height: 6),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: RecorteTexto.corpo.copyWith(
                color: RecorteCores.textoSecundario,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estado de erro (seção 3.12): quadrado tracejado `erro` com "!" e texto.
class EstadoErro extends StatelessWidget {
  final String texto;

  const EstadoErro({super.key, this.texto = 'Não foi possível carregar.'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 96),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: CustomPaint(
                size: const Size.square(64),
                painter: const _QuadradoTracejadoPainter(
                  cor: RecorteCores.erro,
                  raio: 16,
                  traco: 5,
                  espaco: 4,
                  preenchido: false,
                ),
                child: const SizedBox.square(
                  dimension: 64,
                  child: Center(
                    child: Text(
                      '!',
                      style: TextStyle(
                        fontFamily: familiaTitulos,
                        fontSize: 30,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: RecorteCores.erro,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: RecorteTexto.tituloEstado,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnelPainter extends CustomPainter {
  final Color arco;
  final double giro;

  const _AnelPainter({required this.arco, required this.giro});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final raio = size.width * 18 / 44;
    final anel = Path()..addOval(Rect.fromCircle(center: c, radius: raio));
    desenharTracejado(
      canvas,
      anel,
      Paint()
        ..color = RecorteCores.borda
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
      traco: 5,
      espaco: 4,
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: raio),
      -math.pi / 2 + giro,
      math.pi / 2,
      false,
      Paint()
        ..color = arco
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_AnelPainter o) => o.giro != giro || o.arco != arco;
}

/// Indicador de carregamento (seção 3.12): anel tracejado de 44 px com arco
/// sólido `brandLinha` girando. Sem texto.
class IndicadorCarregando extends StatefulWidget {
  final String rotuloSemantico;

  const IndicadorCarregando({super.key, this.rotuloSemantico = 'Carregando'});

  @override
  State<IndicadorCarregando> createState() => _IndicadorCarregandoState();
}

class _IndicadorCarregandoState extends State<IndicadorCarregando>
    with SingleTickerProviderStateMixin {
  late final _giro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _giro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arco = context.marca.brandLinha;
    return Semantics(
      label: widget.rotuloSemantico,
      liveRegion: true,
      child: AnimatedBuilder(
        animation: _giro,
        builder: (_, _) => CustomPaint(
          size: const Size.square(44),
          painter: _AnelPainter(arco: arco, giro: _giro.value * 2 * math.pi),
        ),
      ),
    );
  }
}

/// [IndicadorCarregando] centralizado, ocupando o espaço disponível.
class CarregandoCentralizado extends StatelessWidget {
  const CarregandoCentralizado({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.only(bottom: 96),
      child: IndicadorCarregando(),
    ),
  );
}
