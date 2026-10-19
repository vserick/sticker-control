import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tela alta o bastante para a `ListView` construir todos os itens (ela é
/// preguiçosa e não monta o que está fora da viewport).
void usarTelaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Botão (de qualquer estilo, inclusive os `.icon`) que contém [texto].
Finder botao(String texto) => find.ancestor(
  of: find.text(texto),
  matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
);

/// Texto dentro do diálogo aberto.
Finder noDialogo(String texto) =>
    find.descendant(of: find.byType(AlertDialog), matching: find.text(texto));
