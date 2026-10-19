import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';

import 'avisos.dart';
import 'linha_corte.dart';
import 'marca.dart';
import 'tipografia.dart';
import 'tokens.dart';

/// Resultado do cálculo (seção 3.6): parcelas, aviso opcional e o adesivo de
/// preço. Sem [resumo], mostra só a linha de corte vazia, no mesmo lugar do
/// adesivo, para a tela não "pular" quando o preço aparece.
class ResultadoRecorte extends StatelessWidget {
  final ResumoPreco? resumo;

  /// Texto do aviso amarelo entre as parcelas e o adesivo (ex.: largura).
  final String? aviso;

  const ResultadoRecorte({super.key, required this.resumo, this.aviso});

  @override
  Widget build(BuildContext context) {
    final r = resumo;
    if (r == null) return const ResultadoVazio();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ParcelasResultado(
          linhas: [
            (rotulo: 'Custo', valor: r.custo),
            (rotulo: r.rotuloAcrescimo, valor: r.acrescimo),
          ],
        ),
        if (aviso != null) ...[
          const SizedBox(height: 12),
          AvisoAmarelo(texto: aviso!),
        ],
        const SizedBox(height: 12),
        AdesivoPreco(valor: r.precoFinal),
      ],
    );
  }
}

/// Valores já formatados do resultado.
class ResumoPreco {
  final String custo;
  final String rotuloAcrescimo;
  final String acrescimo;
  final String precoFinal;

  const ResumoPreco({
    required this.custo,
    required this.rotuloAcrescimo,
    required this.acrescimo,
    required this.precoFinal,
  });
}

/// Célula branca com linhas rótulo ··· valor, ligadas por guia pontilhada.
class ParcelasResultado extends StatelessWidget {
  final List<({String rotulo, String valor})> linhas;

  const ParcelasResultado({super.key, required this.linhas});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: RecorteCores.superficie,
        border: Border.all(color: RecorteCores.borda),
        borderRadius: BorderRadius.circular(RecorteRaio.celula),
      ),
      child: Column(
        children: [
          for (var i = 0; i < linhas.length; i++) ...[
            if (i > 0) const SizedBox(height: 6),
            _LinhaParcela(rotulo: linhas[i].rotulo, valor: linhas[i].valor),
          ],
        ],
      ),
    );
  }
}

class _LinhaParcela extends StatelessWidget {
  final String rotulo;
  final String valor;

  const _LinhaParcela({required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(rotulo, style: RecorteTexto.corpoSecundario),
        const SizedBox(width: 8),
        const Expanded(child: _GuiaPontilhada()),
        const SizedBox(width: 8),
        Text(valor, style: RecorteTexto.valorResultado),
      ],
    );
  }
}

class _GuiaPontilhada extends StatelessWidget {
  const _GuiaPontilhada();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(height: 1.5, child: CustomPaint(painter: _GuiaPainter())),
    );
  }
}

class _GuiaPainter extends CustomPainter {
  const _GuiaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = RecorteCores.pontilhado
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var x = 0.75; x < size.width; x += 3.5) {
      canvas.drawPoints(PointMode.points, [Offset(x, size.height / 2)], p);
    }
  }

  @override
  bool shouldRepaint(_GuiaPainter o) => false;
}

/// Adesivo de preço: bloco na cor da marca com sombra, linha de corte a 4 px
/// e "ponta descolando" no canto superior direito. A margem externa de 5 px
/// abriga a linha de corte.
class AdesivoPreco extends StatelessWidget {
  final String valor;

  const AdesivoPreco({super.key, required this.valor});

  @override
  Widget build(BuildContext context) {
    final marca = context.marca;
    final bloco = DecoratedBox(
      decoration: BoxDecoration(
        color: marca.brand,
        borderRadius: BorderRadius.circular(RecorteRaio.adesivo),
        boxShadow: RecorteSombra.adesivo,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RecorteRaio.adesivo),
        child: CustomPaint(
          foregroundPainter: _PontaPainter(
            fundo: RecorteCores.liner,
            dobra: marca.brandDobra,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            child: Row(
              children: [
                Text(
                  'Preço final',
                  style: RecorteTexto.rotuloPrecoFinal.copyWith(
                    color: marca.onBrand,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        valor,
                        maxLines: 1,
                        style: RecorteTexto.precoFinal.copyWith(
                          color: marca.onBrand,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.all(5),
      child: LinhaDeCorte(child: bloco),
    );
  }
}

class _PontaPainter extends CustomPainter {
  static const _lado = 26.0;
  final Color fundo;
  final Color dobra;

  const _PontaPainter({required this.fundo, required this.dobra});

  @override
  void paint(Canvas canvas, Size size) {
    final x = size.width - _lado;
    // Triângulo na cor do fundo cobrindo o canto superior direito.
    canvas.drawPath(
      Path()
        ..moveTo(x, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, _lado)
        ..close(),
      Paint()..color = fundo,
    );
    // Triângulo da dobra, com o canto inferior esquerdo arredondado (5).
    canvas.drawPath(
      Path()
        ..moveTo(x, 0)
        ..lineTo(size.width, _lado)
        ..lineTo(x + 5, _lado)
        ..quadraticBezierTo(x, _lado, x, _lado - 5)
        ..close(),
      Paint()..color = dobra,
    );
  }

  @override
  bool shouldRepaint(_PontaPainter o) => o.fundo != fundo || o.dobra != dobra;
}

/// Sem resultado: só a linha de corte tracejada e o convite a preencher.
class ResultadoVazio extends StatelessWidget {
  const ResultadoVazio({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: LinhaDeCorte(
        cor: RecorteCores.contornoNeutro,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          child: Text(
            'Preencha os campos para ver o preço.',
            textAlign: TextAlign.center,
            style: RecorteTexto.rotuloLinha.copyWith(
              color: RecorteCores.rotulo,
            ),
          ),
        ),
      ),
    );
  }
}
