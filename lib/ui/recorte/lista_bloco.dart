import 'package:flutter/material.dart';

import 'tipografia.dart';
import 'tokens.dart';

/// Lista em bloco (seção 3.11): um único cartão branco com borda de 1 px e
/// itens separados por divisória. Sem cartão por item.
class ListaBloco extends StatelessWidget {
  final List<Widget> itens;

  const ListaBloco({super.key, required this.itens});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RecorteCores.superficie,
        border: Border.all(color: RecorteCores.borda),
        borderRadius: BorderRadius.circular(RecorteRaio.celula),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RecorteRaio.celula - 1),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            children: [
              for (var i = 0; i < itens.length; i++) ...[
                if (i > 0) const Divider(),
                itens[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Item da [ListaBloco]: ficha, título + metadado e um valor à direita.
class ItemListaBloco extends StatelessWidget {
  final Widget ficha;
  final String titulo;
  final String metadado;
  final String valor;
  final VoidCallback? onTap;

  /// Estilo do [valor]. Padrão: preço da lista (Schibsted 700 17).
  final TextStyle? estiloValor;

  const ItemListaBloco({
    super.key,
    required this.ficha,
    required this.titulo,
    required this.metadado,
    required this.valor,
    this.onTap,
    this.estiloValor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: RecorteEspaco.alturaItemLista,
        ),
        padding: const EdgeInsets.fromLTRB(12, 11, 16, 11),
        child: Row(
          children: [
            ficha,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    titulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RecorteTexto.tituloItem,
                  ),
                  const SizedBox(height: 2),
                  Text(metadado, style: RecorteTexto.metadado),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(valor, style: estiloValor ?? RecorteTexto.precoLista),
          ],
        ),
      ),
    );
  }
}
