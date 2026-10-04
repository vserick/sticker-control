import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/logic/calculo.dart';

ResultadoCalculo _proprio({
  int preco = 5000,
  int comp = 1000,
  int larg = 500,
  int acr = 0,
}) => calcularProprio(
  precoMetroCentavos: preco,
  comprimentoMm: comp,
  larguraMm: larg,
  acrescimoBp: acr,
);

void main() {
  group('calcularProprio', () {
    test('R\$ 50/m × 2 m com 50% = R\$ 150', () {
      final r = _proprio(comp: 2000, acr: 5000);
      expect(r.custoCentavos, 10000);
      expect(r.finalCentavos, 15000);
      expect(r.avisoLargura, isFalse);
    });

    test('a largura não altera o custo nem o final', () {
      final estreita = _proprio(comp: 2000, larg: 100, acr: 5000);
      final larga = _proprio(comp: 2000, larg: 1000, acr: 5000);
      expect(estreita.finalCentavos, larga.finalCentavos);
      expect(estreita.custoCentavos, larga.custoCentavos);
    });

    test('1,10 m exato não avisa; 1,101 m avisa sem bloquear', () {
      expect(_proprio(larg: 1100).avisoLargura, isFalse);
      final acima = _proprio(larg: 1101);
      expect(acima.avisoLargura, isTrue);
      expect(acima.finalCentavos, 5000);
    });

    test('0% de acréscimo: final = custo', () {
      final r = _proprio(preco: 3333, comp: 1500);
      expect(r.finalCentavos, r.custoCentavos);
      expect(r.finalCentavos, 5000); // 49,995 → half-up 50,00
    });

    test('arredondamento half-up só no valor final', () {
      // 0,01/m × 0,5 m = 0,005 → 0,01
      expect(_proprio(preco: 1, comp: 500).finalCentavos, 1);
      // 0,01/m × 0,499 m = 0,00499 → 0,00
      expect(_proprio(preco: 1, comp: 499).finalCentavos, 0);
    });

    test('acréscimo fracionado (12,5%)', () {
      final r = _proprio(preco: 4000, acr: 1250);
      expect(r.finalCentavos, 4500);
    });

    test('rejeita valores inválidos', () {
      expect(() => _proprio(preco: 0), throwsA(isA<ErroDeValidacao>()));
      expect(() => _proprio(comp: 0), throwsA(isA<ErroDeValidacao>()));
      expect(() => _proprio(larg: 0), throwsA(isA<ErroDeValidacao>()));
      expect(() => _proprio(acr: -1), throwsA(isA<ErroDeValidacao>()));
    });
  });

  group('calcularTerceirizado', () {
    test('R\$ 20 com 100% = R\$ 40', () {
      final r = calcularTerceirizado(
        fornecedorCentavos: 2000,
        acrescimoBp: 10000,
      );
      expect(r.custoCentavos, 2000);
      expect(r.finalCentavos, 4000);
      expect(r.avisoLargura, isFalse);
    });

    test('0% mantém o valor do fornecedor', () {
      final r = calcularTerceirizado(fornecedorCentavos: 1234, acrescimoBp: 0);
      expect(r.finalCentavos, 1234);
    });

    test('half-up: 0,05 com 10% = 0,055 → 0,06', () {
      final r = calcularTerceirizado(fornecedorCentavos: 5, acrescimoBp: 1000);
      expect(r.finalCentavos, 6);
    });

    test('rejeita fornecedor <= 0 e acréscimo negativo', () {
      expect(
        () => calcularTerceirizado(fornecedorCentavos: 0, acrescimoBp: 0),
        throwsA(isA<ErroDeValidacao>()),
      );
      expect(
        () => calcularTerceirizado(fornecedorCentavos: 100, acrescimoBp: -5),
        throwsA(isA<ErroDeValidacao>()),
      );
    });
  });
}
