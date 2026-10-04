import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'data/material_repository.dart';
import 'ui/orcamento/novo_orcamento_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final banco = AppDatabase();
  runApp(StickerControlApp(materiais: DriftMaterialRepository(banco)));
}

class StickerControlApp extends StatelessWidget {
  final MaterialRepository materiais;

  const StickerControlApp({super.key, required this.materiais});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticker Control',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      // Provisório: o histórico na tela inicial vem na F1.4.
      home: NovoOrcamentoPage(materiais: materiais),
    );
  }
}
