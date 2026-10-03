import 'package:flutter/material.dart';

void main() {
  runApp(const StickerControlApp());
}

class StickerControlApp extends StatelessWidget {
  const StickerControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sticker Control',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const Scaffold(
        body: Center(child: Text('Sticker Control')),
      ),
    );
  }
}
