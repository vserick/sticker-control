import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/ui/recorte/cor_marca.dart';
import 'package:sticker_control/ui/recorte/marca.dart';
import 'package:sticker_control/ui/recorte/tokens.dart';

const _branco = Color(0xFFFFFFFF);

void main() {
  group('contraste', () {
    test('preto e branco dão 21:1; cor igual dá 1:1', () {
      expect(contraste(const Color(0xFF000000), _branco), closeTo(21, 0.001));
      expect(contraste(_branco, _branco), closeTo(1, 0.001));
    });

    test('é simétrico', () {
      const a = Color(0xFFC2185B);
      expect(contraste(a, _branco), closeTo(contraste(_branco, a), 1e-9));
    });
  });

  group('misturar', () {
    test('extremos e ponto médio', () {
      const preto = Color(0xFF000000);
      expect(misturar(_branco, preto, 0), _branco);
      expect(misturar(_branco, preto, 1), preto);
      expect(misturar(preto, _branco, 0.5), const Color(0xFF808080));
    });
  });

  group('escurecerAteContraste', () {
    test('cor que já passa não muda', () {
      const escura = Color(0xFF17181B);
      expect(escurecerAteContraste(escura, _branco, 4.5), escura);
    });

    test('amarelo escurece até o contraste pedido', () {
      const amarelo = Color(0xFFF2C200);
      final linha = escurecerAteContraste(amarelo, _branco, 3);
      final texto = escurecerAteContraste(amarelo, _branco, 4.5);
      expect(contraste(linha, _branco), greaterThanOrEqualTo(3));
      expect(contraste(texto, _branco), greaterThanOrEqualTo(4.5));
      expect(contraste(amarelo, _branco), lessThan(3));
      // Escurece o mínimo: o passo anterior (5% mais claro) não bastava.
      expect(
        luminanciaRelativa(texto),
        lessThanOrEqualTo(luminanciaRelativa(linha)),
      );
    });
  });

  group('RecorteMarca', () {
    test('amarelo recebe texto grafite', () {
      final m = RecorteMarca.de(const Color(0xFFF2C200));
      expect(m.onBrand, RecorteCores.grafite);
    });

    test('magenta padrão recebe texto branco', () {
      final m = RecorteMarca.de(corMarcaPadrao);
      expect(corMarcaPadrao, const Color(0xFFC2185B));
      expect(m.onBrand, _branco);
    });

    test('derivadas cumprem os contrastes da seção 2.2', () {
      for (final brand in const [
        Color(0xFFC2185B),
        Color(0xFFF2C200),
        Color(0xFF6D28D9),
        Color(0xFF1F6F5C),
      ]) {
        final m = RecorteMarca.de(brand);
        expect(contraste(m.brandLinha, _branco), greaterThanOrEqualTo(3));
        expect(contraste(m.brandTexto, _branco), greaterThanOrEqualTo(4.5));
        expect(m.brandTint, misturar(brand, _branco, 0.72));
        expect(m.brandDobra, misturar(brand, _branco, 0.5));
        expect(
          contraste(brand, m.onBrand),
          greaterThanOrEqualTo(contraste(brand, _branco) < 4.5 ? 3 : 4.5),
        );
      }
    });
  });
}
