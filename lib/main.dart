import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'data/material_repository.dart';
import 'ui/materiais/materiais_page.dart';

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
      // Provisório: a tela inicial (novo orçamento e histórico) vem na F1.3.
      home: MateriaisPage(repositorio: materiais),
    );
  }
}
