import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/data/app_database.dart';
import 'package:sticker_control/data/material_repository.dart';
import 'package:sticker_control/logic/calculo.dart';

void main() {
  late AppDatabase banco;
  late DriftMaterialRepository repo;

  setUp(() {
    banco = AppDatabase(NativeDatabase.memory());
    repo = DriftMaterialRepository(banco);
  });

  tearDown(() => banco.close());

  Future<List<MaterialAdesivo>> todos() => repo.observarTodos().first;

  test('começa vazio', () async {
    expect(await todos(), isEmpty);
  });

  test('cria e lista em ordem alfabética sem diferenciar caixa', () async {
    await repo.criar(nome: 'vinil branco', precoPorMetroCentavos: 5000);
    await repo.criar(nome: 'Adesivo fosco', precoPorMetroCentavos: 4200);
    await repo.criar(nome: 'Transparente', precoPorMetroCentavos: 6100);

    final lista = await todos();
    expect(lista.map((m) => m.nome), [
      'Adesivo fosco',
      'Transparente',
      'vinil branco',
    ]);
    expect(lista.first.precoPorMetroCentavos, 4200);
  });

  test('remove espaços do nome', () async {
    await repo.criar(nome: '  Vinil  ', precoPorMetroCentavos: 5000);
    expect((await todos()).single.nome, 'Vinil');
  });

  test('rejeita nome vazio e preço <= 0', () async {
    expect(
      () => repo.criar(nome: '   ', precoPorMetroCentavos: 5000),
      throwsA(isA<ErroDeValidacao>()),
    );
    expect(
      () => repo.criar(nome: 'Vinil', precoPorMetroCentavos: 0),
      throwsA(isA<ErroDeValidacao>()),
    );
    expect(await todos(), isEmpty);
  });

  test('nome único, sem diferenciar maiúsculas nem acentos de caixa', () async {
    await repo.criar(nome: 'Vinil Ç', precoPorMetroCentavos: 5000);
    for (final repetido in ['vinil ç', ' VINIL Ç ']) {
      expect(
        () => repo.criar(nome: repetido, precoPorMetroCentavos: 100),
        throwsA(isA<ErroDeValidacao>()),
      );
    }
    expect(await todos(), hasLength(1));
  });

  test('atualiza nome e preço; manter o próprio nome é permitido', () async {
    await repo.criar(nome: 'Vinil', precoPorMetroCentavos: 5000);
    final id = (await todos()).single.id;

    await repo.atualizar(id, nome: 'Vinil', precoPorMetroCentavos: 5500);
    expect((await todos()).single.precoPorMetroCentavos, 5500);

    await repo.atualizar(id, nome: 'Vinil branco', precoPorMetroCentavos: 5500);
    expect((await todos()).single.nome, 'Vinil branco');
  });

  test('atualizar para o nome de outro material é rejeitado', () async {
    await repo.criar(nome: 'A', precoPorMetroCentavos: 100);
    await repo.criar(nome: 'B', precoPorMetroCentavos: 200);
    final b = (await todos()).firstWhere((m) => m.nome == 'B');

    expect(
      () => repo.atualizar(b.id, nome: 'a', precoPorMetroCentavos: 200),
      throwsA(isA<ErroDeValidacao>()),
    );
  });

  test('exclui', () async {
    await repo.criar(nome: 'Vinil', precoPorMetroCentavos: 5000);
    await repo.excluir((await todos()).single.id);
    expect(await todos(), isEmpty);
  });

  test('os dados persistem enquanto o banco é o mesmo', () async {
    await repo.criar(nome: 'Vinil', precoPorMetroCentavos: 5000);
    final outroRepo = DriftMaterialRepository(banco);
    expect((await outroRepo.observarTodos().first).single.nome, 'Vinil');
  });
}
