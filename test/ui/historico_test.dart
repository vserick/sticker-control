import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/logic/orcamento.dart';
import 'package:sticker_control/ui/historico/historico_page.dart';

import '../support/finders.dart';
import '../support/servicos_fake.dart';

const _porta = RascunhoOrcamento(
  tipo: TipoProducao.propria,
  descricao: 'Adesivo de porta',
  larguraMm: 1000,
  comprimentoMm: 2000,
  materialNome: 'Vinil branco',
  precoPorMetroCentavos: 5000,
  custoCentavos: 10000,
  acrescimoBp: 5000,
  finalCentavos: 15000,
);

Future<ServicosFake> _abrir(
  WidgetTester tester, {
  bool comOrcamento = true,
}) async {
  usarTelaAlta(tester);
  final fake = ServicosFake();
  await fake.materiais.criar(nome: 'Vinil branco', precoPorMetroCentavos: 5000);
  if (comOrcamento) await fake.orcamentos.salvar(_porta);
  await tester.pumpWidget(
    MaterialApp(home: HistoricoPage(servicos: fake.servicos)),
  );
  await tester.pumpAndSettle();
  return fake;
}

void main() {
  testWidgets('histórico vazio orienta a criar o primeiro orçamento', (
    tester,
  ) async {
    await _abrir(tester, comOrcamento: false);
    expect(find.textContaining('Nenhum orçamento salvo'), findsOneWidget);
  });

  testWidgets('lista orçamentos com data, tipo e preço final', (tester) async {
    await _abrir(tester);
    expect(find.text('Adesivo de porta'), findsOneWidget);
    expect(find.text('05/10/2026 14:30 · Própria'), findsOneWidget);
    expect(find.text('R\$ 150,00'), findsOneWidget);
  });

  testWidgets('detalhe mostra os dados salvos, incluindo custo e percentual', (
    tester,
  ) async {
    await _abrir(tester);
    await tester.tap(find.text('Adesivo de porta'));
    await tester.pumpAndSettle();

    expect(find.text('Vinil branco · R\$ 50,00 / m'), findsOneWidget);
    expect(find.text('1,00 m'), findsOneWidget);
    expect(find.text('2,00 m'), findsOneWidget);
    expect(find.text('R\$ 100,00'), findsOneWidget);
    expect(find.text('Acréscimo (50%)'), findsOneWidget);
    expect(find.text('R\$ 150,00'), findsOneWidget);
  });

  testWidgets('excluir pede confirmação e remove do histórico', (tester) async {
    final fake = await _abrir(tester);
    await tester.tap(find.text('Adesivo de porta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    expect(find.text('Excluir orçamento?'), findsOneWidget);
    await tester.tap(noDialogo('Cancelar'));
    await tester.pumpAndSettle();
    expect(fake.orcamentos.itens, hasLength(1));

    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();
    await tester.tap(noDialogo('Excluir'));
    await tester.pumpAndSettle();

    expect(fake.orcamentos.itens, isEmpty);
    expect(find.textContaining('Nenhum orçamento salvo'), findsOneWidget);
  });

  testWidgets(
    'duplicar abre o formulário preenchido para refazer com outro %',
    (tester) async {
      final fake = await _abrir(tester);
      await tester.tap(find.text('Adesivo de porta'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicar'));
      await tester.pumpAndSettle();

      expect(find.text('Novo orçamento'), findsOneWidget);
      expect(find.widgetWithText(TextField, '2,00'), findsOneWidget);
      expect(find.widgetWithText(TextField, '1,00'), findsOneWidget);
      expect(find.widgetWithText(TextField, '50'), findsOneWidget);
      expect(
        find.widgetWithText(TextField, 'Adesivo de porta'),
        findsOneWidget,
      );
      expect(find.text('R\$ 150,00'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, '50'), '100');
      await tester.pump();
      await tester.ensureVisible(botao('Salvar'));
      await tester.tap(botao('Salvar'));
      await tester.pumpAndSettle();

      expect(fake.orcamentos.itens, hasLength(2));
      expect(fake.orcamentos.itens.last.finalCentavos, 20000);
      expect(
        fake.orcamentos.itens.first.finalCentavos,
        15000,
      ); // original intacto
      expect(find.text('Orçamentos'), findsOneWidget);
    },
  );

  testWidgets('WhatsApp do detalhe usa o nome da empresa configurado', (
    tester,
  ) async {
    final fake = await _abrir(tester);
    fake.configuracoes.nomeEmpresa = 'Adesivos Exemplo';
    await tester.tap(find.text('Adesivo de porta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar por WhatsApp'));
    await tester.pumpAndSettle();

    final mensagem = fake.whatsapp.mensagens.single;
    expect(mensagem, contains('🏷️ *Adesivos Exemplo*'));
    expect(mensagem, contains('▪️ *Medidas:* 1,00 × 2,00 m'));
    expect(mensagem, contains('💰 *Valor: R\$ 150,00*'));
    expect(mensagem, contains('📅 05/10/2026')); // data do orçamento salvo
  });

  testWidgets('avisa quando não consegue abrir o WhatsApp', (tester) async {
    final fake = await _abrir(tester);
    fake.whatsapp.disponivel = false;
    await tester.tap(find.text('Adesivo de porta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enviar por WhatsApp'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível abrir o WhatsApp.'), findsOneWidget);
  });

  testWidgets('configura o nome da empresa', (tester) async {
    final fake = await _abrir(tester, comOrcamento: false);
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nome da empresa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Adesivos Exemplo');
    await tester.tap(noDialogo('Salvar'));
    await tester.pumpAndSettle();

    expect(fake.configuracoes.nomeEmpresa, 'Adesivos Exemplo');
  });

  testWidgets('diálogo do nome da empresa não muda com o teclado aberto', (
    tester,
  ) async {
    await _abrir(tester, comOrcamento: false);
    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nome da empresa'));
    await tester.pumpAndSettle();
    final antes = tester.getRect(find.byType(AlertDialog));

    tester.view.viewInsets = const FakeViewPadding(bottom: 800);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.getRect(find.byType(AlertDialog)), antes);
  });
}
