import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/ui/orcamento/novo_orcamento_page.dart';

import '../support/finders.dart';
import '../support/servicos_fake.dart';

Future<ServicosFake> _abrir(
  WidgetTester tester, {
  bool comMaterial = true,
}) async {
  usarTelaAlta(tester);
  final fake = ServicosFake();
  if (comMaterial) {
    await fake.materiais.criar(
      nome: 'Vinil branco',
      precoPorMetroCentavos: 5000,
    );
  }
  // A página é aberta por cima de outra, como no app (salvar faz `pop`).
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: Text('início'))),
  );
  unawaited(
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .push(
          MaterialPageRoute<void>(
            builder: (_) => NovoOrcamentoPage(servicos: fake.servicos),
          ),
        ),
  );
  await tester.pumpAndSettle();
  return fake;
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

  testWidgets('salvar e WhatsApp ficam desabilitados sem resultado', (
    tester,
  ) async {
    await _abrir(tester);
    expect(tester.widget<ButtonStyleButton>(botao('Salvar')).onPressed, isNull);
    expect(
      tester
          .widget<ButtonStyleButton>(botao('Salvar e enviar por WhatsApp'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('salva com snapshot do material e volta à tela anterior', (
    tester,
  ) async {
    final fake = await _abrir(tester);
    await _escolherMaterial(tester);
    await _digitar(tester, 'Comprimento', '2');
    await _digitar(tester, 'Largura', '1');
    await _digitar(tester, 'Acréscimo', '50');
    await _digitar(tester, 'Descrição (opcional)', 'Adesivo de porta');

    await tester.ensureVisible(botao('Salvar'));
    await tester.tap(botao('Salvar'));
    await tester.pumpAndSettle();

    final salvo = fake.orcamentos.itens.single;
    expect(salvo.materialNome, 'Vinil branco');
    expect(salvo.precoPorMetroCentavos, 5000);
    expect(salvo.larguraMm, 1000);
    expect(salvo.comprimentoMm, 2000);
    expect(salvo.custoCentavos, 10000);
    expect(salvo.acrescimoBp, 5000);
    expect(salvo.finalCentavos, 15000);
    expect(salvo.descricao, 'Adesivo de porta');
    expect(find.text('Orçamento salvo.'), findsOneWidget);
  });

  Future<ServicosFake> preencherProprio(WidgetTester tester) async {
    final fake = await _abrir(tester);
    fake.configuracoes.nomeEmpresa = 'Adesivos Exemplo';
    await _escolherMaterial(tester);
    await _digitar(tester, 'Comprimento', '2');
    await _digitar(tester, 'Largura', '1,1');
    await _digitar(tester, 'Acréscimo', '50');
    await _digitar(tester, 'Descrição (opcional)', 'Placa');
    return fake;
  }

  testWidgets('salvar e enviar grava o orçamento e abre o WhatsApp', (
    tester,
  ) async {
    final fake = await preencherProprio(tester);

    await tester.ensureVisible(botao('Salvar e enviar por WhatsApp'));
    await tester.tap(botao('Salvar e enviar por WhatsApp'));
    await tester.pumpAndSettle();

    final salvo = fake.orcamentos.itens.single;
    expect(salvo.finalCentavos, 15000);
    expect(salvo.descricao, 'Placa');

    final mensagem = fake.whatsapp.mensagens.single;
    expect(mensagem, contains('🏷️ *Adesivos Exemplo*'));
    expect(mensagem, contains('▪️ *Item:* Vinil branco'));
    expect(mensagem, contains('▪️ *Descrição:* Placa'));
    expect(mensagem, contains('▪️ *Medidas:* 1,10 × 2,00 m'));
    expect(mensagem, contains('💰 *Valor: R\$ 150,00*'));
    // Nada de custo (R$ 100,00), preço por metro (R$ 50,00) nem percentual.
    expect(mensagem, isNot(contains('100,00')));
    expect(mensagem, isNot(contains('R\$ 50,00')));
    expect(mensagem, isNot(contains('%')));
    expect(find.text('Orçamento salvo.'), findsOneWidget);
  });

  testWidgets('salvar e enviar usa o modelo próprio configurado', (
    tester,
  ) async {
    final fake = await preencherProprio(tester);
    fake.configuracoes.modeloMensagem = '{descricao} por {valor}';

    await tester.ensureVisible(botao('Salvar e enviar por WhatsApp'));
    await tester.tap(botao('Salvar e enviar por WhatsApp'));
    await tester.pumpAndSettle();

    expect(fake.whatsapp.mensagens.single, 'Placa por R\$ 150,00');
  });

  testWidgets('salvar e enviar mantém o orçamento se o WhatsApp falhar', (
    tester,
  ) async {
    final fake = await preencherProprio(tester);
    fake.whatsapp.disponivel = false;

    await tester.ensureVisible(botao('Salvar e enviar por WhatsApp'));
    await tester.tap(botao('Salvar e enviar por WhatsApp'));
    await tester.pumpAndSettle();

    expect(fake.orcamentos.itens, hasLength(1));
    expect(
      find.text('Orçamento salvo, mas não foi possível abrir o WhatsApp.'),
      findsOneWidget,
    );
  });

  testWidgets('só salvar não abre o WhatsApp', (tester) async {
    final fake = await preencherProprio(tester);

    await tester.ensureVisible(botao('Salvar'));
    await tester.tap(botao('Salvar'));
    await tester.pumpAndSettle();

    expect(fake.orcamentos.itens, hasLength(1));
    expect(fake.whatsapp.mensagens, isEmpty);
  });

  testWidgets('terceirizada salva fornecedor e largura opcional', (
    tester,
  ) async {
    final fake = await _abrir(tester);
    await tester.tap(find.text('Terceirizada'));
    await tester.pumpAndSettle();
    await _digitar(tester, 'Valor do fornecedor', '20');
    await _digitar(tester, 'Acréscimo', '100');

    await tester.ensureVisible(botao('Salvar'));
    await tester.tap(botao('Salvar'));
    await tester.pumpAndSettle();

    final salvo = fake.orcamentos.itens.single;
    expect(salvo.tipo.name, 'terceirizada');
    expect(salvo.fornecedorCentavos, 2000);
    expect(salvo.larguraMm, isNull);
    expect(salvo.finalCentavos, 4000);
  });
}
