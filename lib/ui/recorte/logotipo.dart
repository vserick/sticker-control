import 'package:flutter/material.dart';

import 'icones.dart';
import 'tipografia.dart';

/// Logotipo do topo do Início (seção 3.15), sem empresa configurada: marca de
/// registro + wordmark "StickerControl". A versão com logo e nome da empresa é
/// futura (seção 7 do recorte.md).
class LogotipoTopo extends StatelessWidget {
  const LogotipoTopo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const MarcaRegistro(),
        const SizedBox(width: 9),
        Text('StickerControl', style: RecorteTexto.wordmark),
      ],
    );
  }
}
