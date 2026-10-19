import 'dart:io';

import 'package:flutter/services.dart';
import 'package:sticker_control/ui/recorte/tipografia.dart';

/// O `flutter test` não carrega as fontes do pubspec: o texto sairia na fonte
/// de teste (Ahem, quadrada e larga). Carrega as do app para os testes de
/// layout terem as larguras reais.
Future<void> carregarFontesDoApp() async {
  Future<void> carregar(String familia, String arquivo) async {
    final dados = File('assets/fonts/$arquivo').readAsBytesSync();
    final loader = FontLoader(familia)
      ..addFont(Future.value(ByteData.sublistView(dados)));
    await loader.load();
  }

  await carregar(familiaTitulos, 'SchibstedGrotesk-Variable.ttf');
  await carregar(familiaCorpo, 'InstrumentSans-Variable.ttf');
}
