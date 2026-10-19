import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/data/material_repository.dart';
import 'package:sticker_control/logic/orcamento.dart';
import 'package:sticker_control/servicos.dart';
import 'package:sticker_control/ui/historico/historico_page.dart';
import 'package:sticker_control/ui/orcamento/novo_orcamento_page.dart';

import 'package:sticker_control/ui/recorte/estados.dart';

import '../support/finders.dart';
import '../support/material_repository_fake.dart';
import '../support/servicos_fake.dart';

final _carregandoMateriais = find.byWidgetPredicate(
  (w) =>
      w is IndicadorCarregando && w.rotuloSemantico == 'Carregando materiais',
);

const _avisoOriginal = 'O material original não existe mais. Escolha outro.';

/// Materiais que nunca emitem: simula o banco ainda carregando.
class _MateriaisSemResposta extends MaterialRepositoryFake {
  @override
  Stream<List<MaterialAdesivo>> observarTodos() =>
      StreamController<List<MaterialAdesivo>>().stream;
}

/// Orçamentos cujo stream dá erro.
class _OrcamentosComErro extends OrcamentoRepositoryFake {
  @override
  Stream<List<Orcamento>> observarTodos() => Stream.error(StateError('falha'));
}

const _original = RascunhoOrcamento(
  tipo: TipoProducao.propria,
  descricao: 'Placa',
  larguraMm: 1000,
  comprimentoMm: 2000,
  materialNome: 'Vinil Branco',
  precoPorMetroCentavos: 5000,
  custoCentavos: 10000,
  acrescimoBp: 5000,
  finalCentavos: 15000,
);

Orcamento _orcamentoBase() => Orcamento(
  id: 1,
  criadoEm: DateTime(2026, 10, 5, 14, 30),
  tipo: _original.tipo,
  descricao: _original.descricao,
  larguraMm: _original.larguraMm,
  comprimentoMm: _original.comprimentoMm,
  materialNome: _original.materialNome,
  precoPorMetroCentavos: _original.precoPorMetroCentavos,
  custoCentavos: _original.custoCentavos,
  acrescimoBp: _original.acrescimoBp,
  finalCentavos: _original.finalCentavos,
);

Future<void> _abrirNovo(
  WidgetTester tester,
  Servicos servicos, {
  Orcamento? base,
}) async {
  usarTelaAlta(tester);
  await tester.pumpWidget(
    MaterialApp(
      home: NovoOrcamentoPage(servicos: servicos, base: base),
    ),
  );
  await tester.pump();
}

void main() {
  group('5.1 carregamento no Novo orçamento', () {
    testWidgets('sem resposta dos materiais mostra o indicador, não "Nenhum"', (
      tester,
    ) async {
      final fake = ServicosFake();
      final servicos = Servicos(
        materiais: _MateriaisSemResposta(),
        orcamentos: fake.orcamentos,
        configuracoes: fake.configuracoes,
        whatsapp: fake.whatsapp,
      );
      await _abrirNovo(tester, servicos);

      expect(_carregandoMateriais, findsOneWidget);
      expect(find.text('Nenhum material cadastrado'), findsNothing);
      expect(find.text('Comprimento'), findsNothing);
      // Acréscimo, descrição e resultado vazio continuam; botões desativados.
      expect(find.text('Acréscimo'), findsOneWidget);
      expect(find.text('Descrição'), findsOneWidget);
      expect(find.text('Preencha os campos para ver o preço.'), findsOneWidget);
      expect(
        tester.widget<ButtonStyleButton>(botao('Salvar')).onPressed,
        isNull,
      );
      expect(
        tester
            .widget<ButtonStyleButton>(botao('Salvar e enviar por WhatsApp'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('terceirizada não espera os materiais', (tester) async {
      final fake = ServicosFake();
      final servicos = Servicos(
        materiais: _MateriaisSemResposta(),
        orcamentos: fake.orcamentos,
        configuracoes: fake.configuracoes,
        whatsapp: fake.whatsapp,
      );
      await _abrirNovo(tester, servicos);
      await tester.tap(find.text('Terceirizada'));
      await tester.pump();

      expect(_carregandoMateriais, findsNothing);
      expect(find.text('Valor do fornecedor'), findsOneWidget);
    });

    testWidgets('quando os materiais chegam o indicador some', (tester) async {
      final fake = ServicosFake();
      await fake.materiais.criar(
        nome: 'Vinil Branco',
        precoPorMetroCentavos: 5000,
      );
      await _abrirNovo(tester, fake.servicos);
      await tester.pumpAndSettle();

      expect(_carregandoMateriais, findsNothing);
      expect(find.text('Comprimento'), findsOneWidget);
    });
  });

  group('5.2 erro no Início', () {
    testWidgets('stream com erro mostra "Não foi possível carregar."', (
      tester,
    ) async {
      usarTelaAlta(tester);
      final fake = ServicosFake();
      final servicos = Servicos(
        materiais: fake.materiais,
        orcamentos: _OrcamentosComErro(),
        configuracoes: fake.configuracoes,
        whatsapp: fake.whatsapp,
      );
      await tester.pumpWidget(
        MaterialApp(home: HistoricoPage(servicos: servicos)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível carregar.'), findsOneWidget);
      expect(find.textContaining('Nenhum orçamento salvo'), findsNothing);
      // A barra e o botão de novo orçamento continuam disponíveis.
      expect(find.text('Novo orçamento'), findsOneWidget);
    });
  });

  group('5.3 duplicar com material excluído', () {
    testWidgets('avisa, mantém os campos e some ao escolher outro material', (
      tester,
    ) async {
      final fake = ServicosFake();
      await fake.materiais.criar(
        nome: 'Vinil Fosco',
        precoPorMetroCentavos: 6000,
      );
      await _abrirNovo(tester, fake.servicos, base: _orcamentoBase());
      await tester.pumpAndSettle();

      expect(find.text(_avisoOriginal), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      // Os demais campos continuam preenchidos.
      expect(find.widgetWithText(TextField, '2,00'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Placa'), findsOneWidget);

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.textContaining('Vinil Fosco').last);
      await tester.pumpAndSettle();
      expect(find.text(_avisoOriginal), findsNothing);
    });

    testWidgets('material original ainda existe: sem aviso e já selecionado', (
      tester,
    ) async {
      final fake = ServicosFake();
      await fake.materiais.criar(
        nome: 'vinil branco',
        precoPorMetroCentavos: 7000,
      );
      await _abrirNovo(tester, fake.servicos, base: _orcamentoBase());
      await tester.pumpAndSettle();

      expect(find.text(_avisoOriginal), findsNothing);
      expect(find.text('vinil branco'), findsOneWidget);
    });

    testWidgets('orçamento novo (sem base) nunca mostra o aviso', (
      tester,
    ) async {
      final fake = ServicosFake();
      await fake.materiais.criar(
        nome: 'Vinil Fosco',
        precoPorMetroCentavos: 6000,
      );
      await _abrirNovo(tester, fake.servicos);
      await tester.pumpAndSettle();
      expect(find.text(_avisoOriginal), findsNothing);
    });

    testWidgets('enquanto os materiais carregam não avisa', (tester) async {
      final fake = ServicosFake();
      final servicos = Servicos(
        materiais: _MateriaisSemResposta(),
        orcamentos: fake.orcamentos,
        configuracoes: fake.configuracoes,
        whatsapp: fake.whatsapp,
      );
      await _abrirNovo(tester, servicos, base: _orcamentoBase());
      expect(find.text(_avisoOriginal), findsNothing);
    });
  });
}
