import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/data/app_database.dart';
import 'package:sticker_control/data/configuracao_repository.dart';
import 'package:sticker_control/data/material_repository.dart';
import 'package:sticker_control/data/orcamento_repository.dart';
import 'package:sticker_control/logic/orcamento.dart';

RascunhoOrcamento _rascunho({
  String? descricao,
  String material = 'Vinil branco',
  int preco = 5000,
}) => RascunhoOrcamento(
  tipo: TipoProducao.propria,
  descricao: descricao,
  larguraMm: 1000,
  comprimentoMm: 2000,
  materialNome: material,
  precoPorMetroCentavos: preco,
  custoCentavos: 10000,
  acrescimoBp: 5000,
  finalCentavos: 15000,
);

void main() {
  late AppDatabase banco;
  late DriftOrcamentoRepository repo;

  setUp(() {
    banco = AppDatabase(NativeDatabase.memory());
    repo = DriftOrcamentoRepository(banco);
  });

  tearDown(() => banco.close());

  test('começa vazio', () async {
    expect(await repo.observarTodos().first, isEmpty);
  });

  test('salva e devolve todos os campos', () async {
    final salvo = await repo.salvar(_rascunho(descricao: '  Porta  '));

    expect(salvo.id, greaterThan(0));
    expect(salvo.descricao, 'Porta');
    expect(salvo.tipo, TipoProducao.propria);
    expect(salvo.materialNome, 'Vinil branco');
    expect(salvo.precoPorMetroCentavos, 5000);
    expect(salvo.larguraMm, 1000);
    expect(salvo.comprimentoMm, 2000);
    expect(salvo.fornecedorCentavos, isNull);
    expect(salvo.custoCentavos, 10000);
    expect(salvo.acrescimoBp, 5000);
    expect(salvo.finalCentavos, 15000);
    expect(await repo.observarTodos().first, hasLength(1));
  });

  test('descrição em branco vira nula', () async {
    expect((await repo.salvar(_rascunho(descricao: '   '))).descricao, isNull);
  });

  test('salva terceirizada sem largura', () async {
    final salvo = await repo.salvar(
      const RascunhoOrcamento(
        tipo: TipoProducao.terceirizada,
        fornecedorCentavos: 2000,
        custoCentavos: 2000,
        acrescimoBp: 10000,
        finalCentavos: 4000,
      ),
    );
    expect(salvo.tipo, TipoProducao.terceirizada);
    expect(salvo.larguraMm, isNull);
    expect(salvo.fornecedorCentavos, 2000);
  });

  test('lista do mais recente para o mais antigo', () async {
    await repo.salvar(_rascunho(descricao: 'primeiro'));
    await repo.salvar(_rascunho(descricao: 'segundo'));

    final lista = await repo.observarTodos().first;
    expect(lista.map((o) => o.descricao), ['segundo', 'primeiro']);
  });

  test('exclui só o orçamento escolhido', () async {
    final a = await repo.salvar(_rascunho(descricao: 'a'));
    await repo.salvar(_rascunho(descricao: 'b'));

    await repo.excluir(a.id);

    final lista = await repo.observarTodos().first;
    expect(lista.map((o) => o.descricao), ['b']);
  });

  test('mudar ou excluir o material não altera o orçamento salvo', () async {
    final materiais = DriftMaterialRepository(banco);
    await materiais.criar(nome: 'Vinil branco', precoPorMetroCentavos: 5000);
    final material = (await materiais.observarTodos().first).single;
    final salvo = await repo.salvar(_rascunho());

    await materiais.atualizar(
      material.id,
      nome: 'Vinil premium',
      precoPorMetroCentavos: 9000,
    );
    var lido = (await repo.observarTodos().first).single;
    expect(lido.id, salvo.id);
    expect(lido.materialNome, 'Vinil branco');
    expect(lido.precoPorMetroCentavos, 5000);
    expect(lido.finalCentavos, 15000);

    await materiais.excluir(material.id);
    lido = (await repo.observarTodos().first).single;
    expect(lido.materialNome, 'Vinil branco');
  });

  group('ConfiguracaoRepository', () {
    late DriftConfiguracaoRepository config;

    setUp(() => config = DriftConfiguracaoRepository(banco));

    test('começa sem nome da empresa', () async {
      expect(await config.lerNomeEmpresa(), isNull);
    });

    test('salva, atualiza e apaga com nome em branco', () async {
      await config.salvarNomeEmpresa('  Adesivos Exemplo ');
      expect(await config.lerNomeEmpresa(), 'Adesivos Exemplo');

      await config.salvarNomeEmpresa('Outra Empresa');
      expect(await config.lerNomeEmpresa(), 'Outra Empresa');

      await config.salvarNomeEmpresa('   ');
      expect(await config.lerNomeEmpresa(), isNull);
    });
  });
}
