import 'package:flutter/material.dart';

import 'tipografia.dart';
import 'tokens.dart';

/// Aviso amarelo (seção 3.8): largura acima de 1,10 m, material excluído.
class AvisoAmarelo extends StatelessWidget {
  final String texto;
  final IconData icone;

  const AvisoAmarelo({
    super.key,
    required this.texto,
    this.icone = Icons.warning_amber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: RecorteCores.avisoFundo,
        border: Border.all(color: RecorteCores.avisoBorda),
        borderRadius: BorderRadius.circular(RecorteRaio.celula),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 22, color: RecorteCores.avisoBorda),
          const SizedBox(width: 12),
          Expanded(child: Text(texto, style: RecorteTexto.aviso)),
        ],
      ),
    );
  }
}

/// Aviso de rodapé (seção 3.9): SnackBar grafite com ícone ✓ (sucesso) ou
/// alerta (falha). O botão flutuante sobe sozinho, pois o SnackBar é flutuante.
SnackBar avisoRodape(String texto, {bool sucesso = true}) {
  return SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: RecorteCores.grafite,
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(RecorteRaio.celula),
    ),
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    content: Row(
      children: [
        Icon(
          sucesso ? Icons.check : Icons.warning_amber,
          size: 20,
          color: sucesso ? RecorteCores.okEscuro : RecorteCores.alertaEscuro,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(texto, style: RecorteTexto.avisoRodape)),
      ],
    ),
  );
}
