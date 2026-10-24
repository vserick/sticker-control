import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/ui/materiais/materiais_page.dart';

import '../support/finders.dart';
import '../support/material_repository_fake.dart';

Future<MaterialRepositoryFake> _abrir(
  WidgetTester tester, {
  List<(String, int)> iniciais = const [],
}) async {
  final repo = MaterialRepositoryFake();
  for (final (nome, preco) in iniciais) {
    await repo.criar(nome: nome, precoPorMetroCentavos: preco);
  }
  await tester.pumpWidget(MaterialApp(home: MateriaisPage(repositorio: repo)));
  await tester.pumpAndSettle();
  return repo;
}

Future<void> _preencher(WidgetTester tester, String nome, String preco) async {
  await tester.enterText(campoDe('Nome do material'), nome);
  await tester.enterText(campoDe('Preço por metro - em comprimento'), preco);
}

void main() {
  testWidgets('estado vazio orienta a cadastrar o primeiro material', (
    tester,
  ) async {
    await _abrir(tester);
    expect(find.text('Nenhum material cadastrado'), findsOneWidget);
    expect(find.textContaining('Cadastre o primeiro material'), findsOneWidget);
  });

  testWidgets('lista materiais com preço formatado e largura fixa', (
    tester,
  ) async {
    await _abrir(
      tester,
      iniciais: [('Vinil branco', 5000), ('Adesivo fosco', 123456)],
    );
    expect(find.text('Vinil branco'), findsOneWidget);
    expect(find.text('R\$ 50,00 / m'), findsOneWidget);
    expect(find.text('R\$ 1.234,56 / m'), findsOneWidget);
    expect(find.text('Largura 1,10 m'), findsNWidgets(2));
  });

  testWidgets('cadastra um material pelo formulário', (tester) async {
    final repo = await _abrir(tester);

    await tester.tap(find.text('Novo material'));
    await tester.pumpAndSettle();
    expect(find.text('Largura do material'), findsOneWidget);

    await _preencher(tester, 'Vinil branco', '50,5');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repo.itens.single.nome, 'Vinil branco');
    expect(repo.itens.single.precoPorMetroCentavos, 5050);
    expect(find.text('R\$ 50,50 / m'), findsOneWidget);
  });

  testWidgets('valida nome obrigatório e preço > 0', (tester) async {
    final repo = await _abrir(tester);
    await tester.tap(find.text('Novo material'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('Informe o nome.'), findsOneWidget);
    expect(find.textContaining('valor válido'), findsOneWidget);

    await _preencher(tester, 'Vinil', '0');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();
    expect(find.text('O preço deve ser maior que zero.'), findsOneWidget);
    expect(repo.itens, isEmpty);
  });

  testWidgets('nome repetido mostra erro e não salva', (tester) async {
    final repo = await _abrir(tester, iniciais: [('Vinil', 5000)]);
    await tester.tap(find.text('Novo material'));
    await tester.pumpAndSettle();

    await _preencher(tester, 'vinil', '10');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Já existe um material com esse nome.'), findsOneWidget);
    expect(repo.itens, hasLength(1));
  });

  testWidgets('edita o preço de um material existente', (tester) async {
    final repo = await _abrir(tester, iniciais: [('Vinil', 5000)]);
    await tester.tap(find.text('Vinil'));
    await tester.pumpAndSettle();
    expect(find.text('Editar material'), findsOneWidget);

    await tester.enterText(
      campoDe('Preço por metro - em comprimento'),
      '60,00',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repo.itens.single.precoPorMetroCentavos, 6000);
    expect(find.text('R\$ 60,00 / m'), findsOneWidget);
  });

  testWidgets('exclui após confirmar', (tester) async {
    final repo = await _abrir(tester, iniciais: [('Vinil', 5000)]);
    await tester.tap(find.text('Vinil'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Excluir'));
    await tester.pumpAndSettle();

    expect(repo.itens, isEmpty);
    expect(find.text('Nenhum material cadastrado'), findsOneWidget);
  });

  testWidgets('largura vem 1,10 m e travada; destravar permite alterar', (
    tester,
  ) async {
    final repo = await _abrir(tester);
    await tester.tap(find.text('Novo material'));
    await tester.pumpAndSettle();

    final largura = campoDe('Largura do material');
    expect(tester.widget<TextField>(largura).controller!.text, '1,10');
    expect(tester.widget<TextField>(largura).readOnly, isTrue);
    expect(find.text('Preço por metro - em comprimento'), findsOneWidget);

    await tester.tap(find.byTooltip('Destravar largura'));
    await tester.pump();
    expect(tester.widget<TextField>(largura).readOnly, isFalse);
    await tester.enterText(largura, '1,60');
    await tester.enterText(campoDe('Comprimento do material'), '50');
    await _preencher(tester, 'Vinil largo', '80');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final m = repo.itens.single;
    expect(m.larguraMm, 1600);
    expect(m.comprimentoMm, 50000);
    expect(find.text('Largura 1,60 m'), findsOneWidget);
  });

  testWidgets('largura inválida e comprimento inválido são recusados', (
    tester,
  ) async {
    final repo = await _abrir(tester);
    await tester.tap(find.text('Novo material'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Destravar largura'));
    await tester.pump();
    await tester.enterText(campoDe('Largura do material'), '0');
    await tester.enterText(campoDe('Comprimento do material'), 'abc');
    await _preencher(tester, 'Vinil', '50');
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('A largura deve ser maior que zero.'), findsOneWidget);
    expect(find.textContaining('comprimento válido'), findsOneWidget);
    expect(repo.itens, isEmpty);
  });
}
