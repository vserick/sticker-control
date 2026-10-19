import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/logic/mensagem_whatsapp.dart';
import 'package:sticker_control/ui/historico/historico_page.dart';

import '../support/finders.dart';
import '../support/servicos_fake.dart';

Future<ServicosFake> _abrirEditor(
  WidgetTester tester, {
  String? modelo,
  String? empresa,
}) async {
  usarTelaAlta(tester);
  final fake = ServicosFake();
  fake.configuracoes.modeloMensagem = modelo;
  fake.configuracoes.nomeEmpresa = empresa;
  await tester.pumpWidget(
    MaterialApp(home: HistoricoPage(servicos: fake.servicos)),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Menu'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Mensagem do WhatsApp'));
  await tester.pumpAndSettle();
  return fake;
}

Finder get _campo => find.widgetWithText(TextField, 'Modelo da mensagem');

String _textoDoCampo(WidgetTester tester) =>
    tester.widget<TextField>(_campo).controller!.text;

void main() {
  testWidgets('abre com a mensagem padrão e mostra a prévia', (tester) async {
    await _abrirEditor(tester, empresa: 'Adesivos Exemplo');

    expect(_textoDoCampo(tester), modeloMensagemPadrao);
    // A prévia usa dados de exemplo e o nome da empresa configurado.
    expect(find.text('Prévia'), findsOneWidget);
    expect(find.textContaining('🏷️ Adesivos Exemplo'), findsNothing);
    expect(find.textContaining('*Adesivos Exemplo*'), findsOneWidget);
    expect(find.textContaining('Vinil branco'), findsOneWidget);
    expect(find.textContaining('R\$ 150,00'), findsOneWidget);
  });

  testWidgets('abre com o modelo próprio já salvo', (tester) async {
    await _abrirEditor(tester, modelo: 'Total: {valor}');
    expect(_textoDoCampo(tester), 'Total: {valor}');
    expect(find.text('Total: R\$ 150,00'), findsOneWidget);
  });

  testWidgets('toque na variável insere no cursor e atualiza a prévia', (
    tester,
  ) async {
    await _abrirEditor(tester, modelo: 'Valor: ');
    await tester.tap(_campo);
    await tester.pump();
    await tester.tap(find.widgetWithText(ActionChip, '{valor}'));
    await tester.pump();

    expect(_textoDoCampo(tester), 'Valor: {valor}');
    expect(find.text('Valor: R\$ 150,00'), findsOneWidget);
  });

  testWidgets('não oferece variáveis de custo nem percentual', (tester) async {
    await _abrirEditor(tester);
    expect(find.widgetWithText(ActionChip, '{valor}'), findsOneWidget);
    expect(find.widgetWithText(ActionChip, '{custo}'), findsNothing);
    expect(find.widgetWithText(ActionChip, '{percentual}'), findsNothing);
  });

  testWidgets('salva o modelo próprio', (tester) async {
    final fake = await _abrirEditor(tester);
    await tester.enterText(_campo, '{descricao} - {valor}');
    await tester.pump();
    await tester.tap(botao('Salvar'));
    await tester.pumpAndSettle();

    expect(fake.configuracoes.modeloMensagem, '{descricao} - {valor}');
    expect(find.text('Mensagem salva.'), findsOneWidget);
  });

  testWidgets('restaurar padrão e salvar apaga o modelo próprio', (
    tester,
  ) async {
    final fake = await _abrirEditor(tester, modelo: 'Total: {valor}');
    await tester.tap(botao('Restaurar padrão'));
    await tester.pump();
    expect(_textoDoCampo(tester), modeloMensagemPadrao);

    await tester.tap(botao('Salvar'));
    await tester.pumpAndSettle();

    expect(fake.configuracoes.modeloMensagem, isNull);
  });
}
