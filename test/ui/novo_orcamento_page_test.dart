import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/ui/orcamento/novo_orcamento_page.dart';

import '../support/material_repository_fake.dart';

Future<void> _abrir(WidgetTester tester, {bool comMaterial = true}) async {
  final repo = MaterialRepositoryFake();
  if (comMaterial) {
    await repo.criar(nome: 'Vinil branco', precoPorMetroCentavos: 5000);
  }
  await tester.pumpWidget(
    MaterialApp(home: NovoOrcamentoPage(materiais: repo)),
  );
  await tester.pumpAndSettle();
}

Future<void> _digitar(WidgetTester tester, String rotulo, String texto) async {
  await tester.enterText(find.widgetWithText(TextField, rotulo), texto);
  await tester.pump();
}

Future<void> _escolherMaterial(WidgetTester tester) async {
  await tester.tap(find.byType(DropdownButtonFormField<int>));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('Vinil branco').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sem material cadastrado orienta a cadastrar', (tester) async {
    await _abrir(tester, comMaterial: false);
    expect(find.text('Nenhum material cadastrado'), findsOneWidget);
  });

  testWidgets('própria: custo, acréscimo e preço final ao vivo', (
    tester,
  ) async {
    await _abrir(tester);
    expect(find.text('Preencha os campos para ver o preço.'), findsOneWidget);

    await _escolherMaterial(tester);
    await _digitar(tester, 'Comprimento', '2');
    await _digitar(tester, 'Largura', '1');
    await _digitar(tester, 'Acréscimo', '50');

    // 2 m × R$ 50,00 = R$ 100,00; +50% = R$ 150,00.
    expect(find.text('R\$ 100,00'), findsOneWidget);
    expect(find.text('R\$ 50,00'), findsWidgets);
    expect(find.text('R\$ 150,00'), findsOneWidget);
    expect(find.textContaining('Largura acima de 1,10 m'), findsNothing);
  });

  testWidgets('própria: largura acima de 1,10 m só avisa', (tester) async {
    await _abrir(tester);
    await _escolherMaterial(tester);
    await _digitar(tester, 'Comprimento', '2');
    await _digitar(tester, 'Largura', '1,2');

    expect(find.textContaining('Largura acima de 1,10 m'), findsOneWidget);
    expect(find.text('R\$ 100,00'), findsWidgets); // ainda calcula
  });

  testWidgets('largura exata de 1,10 m não avisa', (tester) async {
    await _abrir(tester);
    await _escolherMaterial(tester);
    await _digitar(tester, 'Comprimento', '2');
    await _digitar(tester, 'Largura', '1,10');

    expect(find.textContaining('Largura acima de 1,10 m'), findsNothing);
  });

  testWidgets('terceirizada: fornecedor com acréscimo; largura é informativa', (
    tester,
  ) async {
    await _abrir(tester);
    await tester.tap(find.text('Terceirizada'));
    await tester.pumpAndSettle();

    await _digitar(tester, 'Valor do fornecedor', '80');
    await _digitar(tester, 'Largura (informativa)', '2');
    await _digitar(tester, 'Acréscimo', '50');

    expect(find.text('R\$ 80,00'), findsOneWidget);
    expect(find.text('R\$ 120,00'), findsOneWidget);
    expect(find.textContaining('Largura acima de 1,10 m'), findsNothing);
  });

  testWidgets('valor inválido mostra erro e esconde o resultado', (
    tester,
  ) async {
    await _abrir(tester);
    await _escolherMaterial(tester);
    await _digitar(tester, 'Comprimento', 'abc');

    expect(find.text('Valor inválido, ex.: 1,50.'), findsOneWidget);
    expect(find.text('Preencha os campos para ver o preço.'), findsOneWidget);
  });
}
