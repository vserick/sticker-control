import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/ui/recorte/tipografia.dart';

import '../../support/fontes.dart';

/// As fontes são variáveis: confirma que cada peso do recorte.md renderiza de
/// fato diferente (a largura do texto cresce com o eixo `wght`).
double _largura(TextStyle estilo) {
  final p = TextPainter(
    text: TextSpan(text: 'Orçamento R\$ 1.234,56 mm', style: estilo),
    textDirection: TextDirection.ltr,
  )..layout();
  return p.width;
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await carregarFontesDoApp();
  });

  void conferir(String familia, List<int> pesos) {
    final larguras = [
      for (final p in pesos)
        _largura(
          TextStyle(
            fontFamily: familia,
            fontSize: 40,
            fontWeight: FontWeight.values[p ~/ 100 - 1],
            fontVariations: [FontVariation.weight(p.toDouble())],
          ),
        ),
    ];
    for (var i = 1; i < larguras.length; i++) {
      expect(
        larguras[i],
        greaterThan(larguras[i - 1]),
        reason: '$familia ${pesos[i]} deve ser mais largo que ${pesos[i - 1]}',
      );
    }
  }

  test('Schibsted Grotesk 500/600/700/800 são diferentes', () {
    conferir(familiaTitulos, [500, 600, 700, 800]);
  });

  test('Instrument Sans 400/500/600/700 são diferentes', () {
    conferir(familiaCorpo, [400, 500, 600, 700]);
  });

  test('os papéis do recorte usam o peso e a família pedidos', () {
    expect(RecorteTexto.tituloInicio.fontFamily, familiaTitulos);
    expect(RecorteTexto.tituloInicio.fontSize, 36);
    expect(RecorteTexto.tituloInicio.letterSpacing, closeTo(-0.035 * 36, 1e-9));
    expect(RecorteTexto.tituloItem.fontFamily, familiaCorpo);
    expect(RecorteTexto.tituloItem.fontVariations!.single.value, 600);
    expect(RecorteTexto.precoFinal.fontFeatures, isNotEmpty);
  });
}
