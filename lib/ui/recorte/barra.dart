import 'package:flutter/material.dart';

/// Barra superior (seção 3.1): fundo transparente sobre o liner, `trilho`
/// quando o conteúdo rola por baixo, sem sombra. A aparência vem do
/// `AppBarTheme` (ver tema.dart); este widget só fixa o formato.
class BarraRecorte extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final List<Widget> acoes;

  const BarraRecorte({super.key, required this.titulo, this.acoes = const []});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: Text(titulo), actions: acoes);
  }
}
