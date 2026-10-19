import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sticker_control/data/material_repository.dart';
import 'package:sticker_control/ui/materiais/materiais_page.dart';
import 'package:sticker_control/ui/recorte/tema.dart';

import '../support/fontes.dart';
import '../support/material_repository_fake.dart';

class _RepositorioComErro extends MaterialRepositoryFake {
  @override
  Stream<List<MaterialAdesivo>> observarTodos() =>
      Stream.error(StateError('falha'));
}

class _RepositorioLento extends MaterialRepositoryFake {
  final _controller = StreamController<List<MaterialAdesivo>>();

  @override
  Stream<List<MaterialAdesivo>> observarTodos() => _controller.stream;
}

Future<void> _abrir(WidgetTester tester, MaterialRepositoryFake repo) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: construirTema(),
      home: MateriaisPage(repositorio: repo),
    ),
  );
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  setUpAll(carregarFontesDoApp);

  testWidgets('erro ao carregar mostra o estado de erro', (tester) async {
    await _abrir(tester, _RepositorioComErro());
    expect(find.text('Não foi possível carregar.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('enquanto carrega mostra o indicador, sem texto de vazio', (
    tester,
  ) async {
    await _abrir(tester, _RepositorioLento());
    expect(find.bySemanticsLabel('Carregando'), findsOneWidget);
    expect(find.text('Nenhum material cadastrado'), findsNothing);
  });

  testWidgets('lista cabe em 390 px com nome e preço longos', (tester) async {
    final repo = MaterialRepositoryFake();
    await repo.criar(
      nome: 'Vinil perfurado microfuro para vidro de vitrine',
      precoPorMetroCentavos: 123456,
    );
    await _abrir(tester, repo);
    expect(find.text('R\$ 1.234,56 / m'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
