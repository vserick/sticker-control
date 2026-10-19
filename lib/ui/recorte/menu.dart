import 'package:flutter/material.dart';

import 'tipografia.dart';
import 'tokens.dart';

/// Item do menu (seção 3.13): 52 de altura, ícone de 22 e texto 15/600.
PopupMenuItem<T> itemMenuRecorte<T>({
  required T valor,
  required IconData icone,
  required String texto,
  bool destrutivo = false,
}) {
  final cor = destrutivo ? RecorteCores.erro : RecorteCores.grafite;
  return PopupMenuItem<T>(
    value: valor,
    height: 52,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Row(
      children: [
        Icon(icone, size: 22, color: cor),
        const SizedBox(width: 14),
        Text(texto, style: RecorteTexto.itemMenu.copyWith(color: cor)),
      ],
    ),
  );
}

/// Botão ⋮ com o menu do Recorte: cartão ancorado abaixo do botão, que fica
/// com fundo `trilho` enquanto o menu está aberto.
class MenuRecorte<T> extends StatefulWidget {
  final String dica;
  final List<PopupMenuEntry<T>> Function(BuildContext) itens;
  final ValueChanged<T> onSelected;

  const MenuRecorte({
    super.key,
    required this.itens,
    required this.onSelected,
    this.dica = 'Menu',
  });

  @override
  State<MenuRecorte<T>> createState() => _MenuRecorteState<T>();
}

class _MenuRecorteState<T> extends State<MenuRecorte<T>> {
  bool _aberto = false;

  void _definir(bool aberto) {
    if (mounted) setState(() => _aberto = aberto);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      tooltip: widget.dica,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 4),
      constraints: const BoxConstraints.tightFor(width: 252),
      onOpened: () => _definir(true),
      onCanceled: () => _definir(false),
      onSelected: (v) {
        _definir(false);
        widget.onSelected(v);
      },
      itemBuilder: widget.itens,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _aberto ? RecorteCores.trilho : Colors.transparent,
          borderRadius: BorderRadius.circular(RecorteRaio.celula),
        ),
        child: const Icon(
          Icons.more_vert,
          size: 24,
          color: RecorteCores.grafite,
        ),
      ),
    );
  }
}
