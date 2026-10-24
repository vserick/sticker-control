import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/data/app_database.dart';
import 'package:sticker_control/data/material_repository.dart';
import 'package:sticker_control/logic/calculo.dart';
import 'package:sticker_control/logic/material_validacao.dart';

ResultadoCalculo _calc({
  int larg = 500,
  int comp = 2000,
  int larguraMax = larguraMaximaProprioMm,
  int? compMax,
}) => calcularProprio(
  precoMetroCentavos: 5000,
  comprimentoMm: comp,
  larguraMm: larg,
  acrescimoBp: 0,
  larguraMaximaMm: larguraMax,
  comprimentoMaximoMm: compMax,
);

void main() {
  group('limites vindos do material', () {
    test('largura do material maior que 1,10 m move o limite do aviso', () {
      expect(_calc(larg: 1300).avisoLargura, isTrue);
      expect(_calc(larg: 1300, larguraMax: 1500).avisoLargura, isFalse);
      expect(_calc(larg: 1501, larguraMax: 1500).avisoLargura, isTrue);
    });

    test('largura continua sem alterar o custo', () {
      final a = _calc(larg: 300, larguraMax: 1500);
      final b = _calc(larg: 1500, larguraMax: 1500);
      expect(a.finalCentavos, b.finalCentavos);
    });

    test('comprimento acima do rolo só avisa; sem metragem nunca avisa', () {
      expect(_calc(comp: 50001, compMax: 50000).avisoComprimento, isTrue);
      expect(_calc(comp: 50000, compMax: 50000).avisoComprimento, isFalse);
      expect(_calc(comp: 999999).avisoComprimento, isFalse);
      // O aviso não muda o preço.
      expect(_calc(comp: 3000, compMax: 2000).finalCentavos, 15000);
    });
  });

  group('validação do material', () {
    test('largura e comprimento precisam ser positivos', () {
      expect(
        () =>
            validarMaterial(nome: 'a', precoPorMetroCentavos: 1, larguraMm: 0),
        throwsA(isA<ErroDeValidacao>()),
      );
      expect(
        () => validarMaterial(
          nome: 'a',
          precoPorMetroCentavos: 1,
          comprimentoMm: 0,
        ),
        throwsA(isA<ErroDeValidacao>()),
      );
      expect(validarMaterial(nome: ' a ', precoPorMetroCentavos: 1), 'a');
    });
  });

  group('persistência', () {
    late AppDatabase banco;
    late DriftMaterialRepository repo;

    setUp(() {
      banco = AppDatabase(NativeDatabase.memory());
      repo = DriftMaterialRepository(banco);
    });
    tearDown(() => banco.close());

    test('material novo vem com 1,10 m e sem metragem', () async {
      await repo.criar(nome: 'Vinil', precoPorMetroCentavos: 5000);
      final m = (await repo.observarTodos().first).single;
      expect(m.larguraMm, 1100);
      expect(m.comprimentoMm, isNull);
    });

    test('guarda e atualiza largura e comprimento', () async {
      await repo.criar(
        nome: 'Vinil',
        precoPorMetroCentavos: 5000,
        larguraMm: 1500,
        comprimentoMm: 50000,
      );
      var m = (await repo.observarTodos().first).single;
      expect((m.larguraMm, m.comprimentoMm), (1500, 50000));

      await repo.atualizar(
        m.id,
        nome: 'Vinil',
        precoPorMetroCentavos: 5000,
        larguraMm: 1600,
      );
      m = (await repo.observarTodos().first).single;
      expect((m.larguraMm, m.comprimentoMm), (1600, null));
    });
  });
}
