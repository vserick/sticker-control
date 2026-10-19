import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/data/app_database.dart';
import 'package:sticker_control/data/configuracao_repository.dart';
import 'package:sticker_control/data/material_repository.dart';
import 'package:sticker_control/data/orcamento_repository.dart';
import 'package:sticker_control/logic/orcamento.dart';

void main() {
  late Directory pasta;
  late File arquivo;

  setUp(() {
    pasta = Directory.systemTemp.createTempSync('sticker_persistencia');
    arquivo = File('${pasta.path}/banco.sqlite');
  });

  tearDown(() => pasta.deleteSync(recursive: true));

  test('dados continuam ali depois de fechar e reabrir o banco', () async {
    var banco = AppDatabase(NativeDatabase(arquivo));
    await DriftMaterialRepository(banco)
        .criar(nome: 'Vinil branco', precoPorMetroCentavos: 5000);
    await DriftOrcamentoRepository(banco).salvar(
      const RascunhoOrcamento(
        tipo: TipoProducao.propria,
        larguraMm: 1000,
        comprimentoMm: 2000,
        materialNome: 'Vinil branco',
        precoPorMetroCentavos: 5000,
        custoCentavos: 10000,
        acrescimoBp: 5000,
        finalCentavos: 15000,
      ),
    );
    await DriftConfiguracaoRepository(banco).salvarNomeEmpresa('Empresa X');
    await banco.close();

    banco = AppDatabase(NativeDatabase(arquivo));
    addTearDown(banco.close);

    final materiais = await DriftMaterialRepository(banco)
        .observarTodos()
        .first;
    final orcamentos = await DriftOrcamentoRepository(banco)
        .observarTodos()
        .first;
    expect(materiais.single.nome, 'Vinil branco');
    expect(orcamentos.single.finalCentavos, 15000);
    expect(
      await DriftConfiguracaoRepository(banco).lerNomeEmpresa(),
      'Empresa X',
    );
  });
}
