import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/logic/dinheiro.dart';

void main() {
  group('formatarBrl', () {
    test('formata com milhar e vírgula', () {
      expect(formatarBrl(0), 'R\$ 0,00');
      expect(formatarBrl(5), 'R\$ 0,05');
      expect(formatarBrl(15000), 'R\$ 150,00');
      expect(formatarBrl(123456), 'R\$ 1.234,56');
      expect(formatarBrl(100000000), 'R\$ 1.000.000,00');
    });
  });

  group('lerCentavos', () {
    test('aceita vírgula decimal e milhar com ponto', () {
      expect(lerCentavos('12,50'), 1250);
      expect(lerCentavos('12,5'), 1250);
      expect(lerCentavos('12'), 1200);
      expect(lerCentavos('1.234,56'), 123456);
      expect(lerCentavos('R\$ 1.234,56'), 123456);
      expect(lerCentavos('  50 '), 5000);
    });

    test('ponto sem vírgula é decimal, exceto milhar exato', () {
      expect(lerCentavos('1.5'), 150);
      expect(lerCentavos('1.234'), 123400);
    });

    test('rejeita inválidos, negativos e casas demais', () {
      expect(lerCentavos(''), isNull);
      expect(lerCentavos('abc'), isNull);
      expect(lerCentavos('-5'), isNull);
      expect(lerCentavos('1,234'), isNull);
      expect(lerCentavos('1,2,3'), isNull);
      expect(lerCentavos(','), isNull);
    });
  });

  group('medidas e percentual', () {
    test('metros viram milímetros', () {
      expect(lerMetrosEmMm('1,10'), 1100);
      expect(lerMetrosEmMm('2'), 2000);
      expect(lerMetrosEmMm('0,5'), 500);
      expect(lerMetrosEmMm('1,1005'), isNull);
    });

    test('percentual vira centésimos de percentual', () {
      expect(lerPercentualEmBp('50'), 5000);
      expect(lerPercentualEmBp('12,5'), 1250);
      expect(lerPercentualEmBp('0'), 0);
    });
  });
}
