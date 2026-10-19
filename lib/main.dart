import 'package:flutter/material.dart';

import 'data/app_database.dart';
import 'data/configuracao_repository.dart';
import 'data/material_repository.dart';
import 'data/orcamento_repository.dart';
import 'data/whatsapp.dart';
import 'servicos.dart';
import 'ui/historico/historico_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final banco = AppDatabase();
  runApp(
    StickerControlApp(
      servicos: Servicos(
        materiais: DriftMaterialRepository(banco),
        orcamentos: DriftOrcamentoRepository(banco),
        configuracoes: DriftConfiguracaoRepository(banco),
        whatsapp: UrlLauncherWhatsApp(),
      ),
    ),
  );
}

class StickerControlApp extends StatelessWidget {
  final Servicos servicos;

  const StickerControlApp({super.key, required this.servicos});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticker Control',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: HistoricoPage(servicos: servicos),
    );
  }
}
