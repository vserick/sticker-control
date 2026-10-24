import 'package:flutter/material.dart';

import 'marca.dart';
import 'tipografia.dart';
import 'tokens.dart';

/// Seletor de modalidade (seção 3.3): trilho com duas metades. A selecionada
/// ganha fundo branco, sombra leve e uma bolinha da cor da marca com ✓.
class SeletorModalidade<T> extends StatelessWidget {
  final List<({T valor, String rotulo})> opcoes;
  final T selecionado;
  final ValueChanged<T> onChanged;

  const SeletorModalidade({
    super.key,
    required this.opcoes,
    required this.selecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: RecorteCores.trilho,
        borderRadius: BorderRadius.circular(RecorteRaio.trilho),
      ),
      child: Row(
        children: [
          for (var i = 0; i < opcoes.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: _Segmento(
                rotulo: opcoes[i].rotulo,
                selecionado: opcoes[i].valor == selecionado,
                onTap: () => onChanged(opcoes[i].valor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Segmento extends StatelessWidget {
  final String rotulo;
  final bool selecionado;
  final VoidCallback onTap;

  const _Segmento({
    required this.rotulo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final marca = context.marca;
    return Semantics(
      button: true,
      selected: selecionado,
      label: rotulo,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selecionado ? RecorteCores.superficie : Colors.transparent,
            borderRadius: BorderRadius.circular(RecorteRaio.segmento),
            boxShadow: selecionado ? RecorteSombra.segmento : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selecionado) ...[
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: marca.brand,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, size: 12, color: marca.onBrand),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  rotulo,
                  style: RecorteTexto.botao.copyWith(
                    fontSize: 15,
                    color: selecionado
                        ? RecorteCores.grafite
                        : RecorteCores.textoSecundario,
                    fontWeight: selecionado ? FontWeight.w700 : FontWeight.w600,
                    fontVariations: [
                      FontVariation.weight(selecionado ? 700 : 600),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Seletor de material (seção 3.4): célula de linha com o nome do material,
/// o preço e a seta. A lista aberta é o menu suspenso do Material, com o
/// estilo de menu do tema.
class SeletorMaterial extends StatelessWidget {
  final List<({int id, String nome, String preco})> materiais;
  final int? selecionado;
  final ValueChanged<int?> onChanged;

  const SeletorMaterial({
    super.key,
    required this.materiais,
    required this.selecionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final atual = materiais.where((m) => m.id == selecionado).firstOrNull;
    return Container(
      height: RecorteEspaco.alturaCelulaLinha,
      decoration: BoxDecoration(
        color: RecorteCores.superficie,
        border: Border.all(color: RecorteCores.borda),
        borderRadius: BorderRadius.circular(RecorteRaio.celula),
      ),
      child: DropdownButtonFormField<int>(
        initialValue: atual?.id,
        isExpanded: true,
        isDense: false,
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 12, 0),
        borderRadius: BorderRadius.circular(RecorteRaio.menu),
        dropdownColor: RecorteCores.superficie,
        elevation: 8,
        itemHeight: 52,
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: RecorteCores.grafite,
        ),
        iconSize: 22,
        style: RecorteTexto.itemMenu,
        hint: Text(
          'Material',
          style: RecorteTexto.valorTexto.copyWith(color: RecorteCores.rotulo),
        ),
        selectedItemBuilder: (_) => [
          for (final m in materiais)
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Material', style: RecorteTexto.rotuloCelula),
                      Text(
                        m.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: RecorteTexto.valorTexto.copyWith(
                          fontWeight: FontWeight.w600,
                          fontVariations: [FontVariation.weight(600)],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(m.preco, style: RecorteTexto.rotuloPrecoMaterial),
              ],
            ),
        ],
        items: [
          for (final m in materiais)
            DropdownMenuItem(
              value: m.id,
              child: Text(
                '${m.nome} · ${m.preco}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
