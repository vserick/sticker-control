import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/logic/orcamento.dart';
import 'package:sticker_control/ui/historico/historico_page.dart';
import 'package:sticker_control/ui/orcamento/novo_orcamento_page.dart';
import 'package:sticker_control/ui/recorte/tema.dart';
import 'package:sticker_control/ui/recorte/tipografia.dart';

import '../support/finders.dart';
import '../support/fontes.dart';
import '../support/servicos_fake.dart';

/// Largura de um celular comum (390 × 844): pega estouro de layout que a tela
/// larga dos outros testes esconde.
void usarCelular(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(carregarFontesDoApp);

  testWidgets('as fontes do app são carregadas nos testes (sem Ahem)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: construirTema(),
        home: Center(
          child: Text('Orçamentos', style: RecorteTexto.tituloInicio),
        ),
      ),
    );
    final largura = tester.getSize(find.text('Orçamentos')).width;
    // Ahem faria 10 letras × 36 px = 360 px.
    expect(largura, lessThan(250));
  });

  Future<ServicosFake> abrirNovo(WidgetTester tester) async {
    usarCelular(tester);
    final fake = ServicosFake();
    await fake.materiais.criar(
      nome: 'Vinil Branco',
      precoPorMetroCentavos: 5000,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: construirTema(),
        home: const Scaffold(body: Text('início')),
      ),
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

  testWidgets('Novo orçamento cabe em 390 px nos estados principais', (
    tester,
  ) async {
    await abrirNovo(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Vinil Branco').last);
    await tester.pumpAndSettle();
    await tester.enterText(campoDe('Comprimento'), '1,00');
    await tester.enterText(campoDe('Largura'), '1,20');
    await tester.enterText(campoDe('Acréscimo'), '50');
    await tester.pump();
    expect(find.textContaining('Largura acima de 1,10 m'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.enterText(campoDe('Comprimento'), 'abc');
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Terceirizada'));
    await tester.pumpAndSettle();
    await tester.enterText(campoDe('Valor do fornecedor'), '1234567,89');
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Início e Detalhe cabem em 390 px, com título e valor longos', (
    tester,
  ) async {
    usarCelular(tester);
    final fake = ServicosFake();
    await fake.orcamentos.salvar(
      const RascunhoOrcamento(
        tipo: TipoProducao.propria,
        descricao: 'Adesivo de vitrine com recorte especial para loja grande',
        larguraMm: 1250,
        comprimentoMm: 20000,
        materialNome: 'Vinil Branco',
        precoPorMetroCentavos: 5000,
        custoCentavos: 123456789,
        acrescimoBp: 5000,
        finalCentavos: 185185183,
      ),
    );
    await fake.orcamentos.salvar(
      const RascunhoOrcamento(
        tipo: TipoProducao.terceirizada,
        fornecedorCentavos: 8000,
        custoCentavos: 8000,
        acrescimoBp: 5000,
        finalCentavos: 12000,
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: construirTema(),
        home: HistoricoPage(servicos: fake.servicos),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Sem descrição'), findsOneWidget);

    await tester.tap(find.textContaining('Adesivo de vitrine'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Preço final'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sem descrição'));
    await tester.pumpAndSettle();
    expect(find.text('Fornecedor'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
