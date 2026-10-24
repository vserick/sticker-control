import 'package:flutter/material.dart';

import 'linha_corte.dart';
import 'marca.dart';
import 'tipografia.dart';
import 'tokens.dart';

/// Botões do recorte.md (seção 3.7). Primário, secundário e texto são os
/// `FilledButton`, `OutlinedButton` e `TextButton` do tema; aqui ficam só as
/// variações pontuais.

/// Botão de texto destrutivo da tela (ícone e texto em `erro`).
ButtonStyle estiloDestrutivoTexto() => TextButton.styleFrom(
  foregroundColor: RecorteCores.erro,
  iconColor: RecorteCores.erro,
);

/// Botões dos diálogos: altura 44, texto 15.
ButtonStyle _estiloDialogo() => ButtonStyle(
  minimumSize: const WidgetStatePropertyAll(
    Size(64, RecorteEspaco.alturaBotaoDialogo),
  ),
  textStyle: WidgetStatePropertyAll(RecorteTexto.botaoDialogo),
);

/// "Cancelar" nos diálogos: botão de texto.
class BotaoCancelarDialogo extends StatelessWidget {
  final VoidCallback onPressed;
  final String texto;

  const BotaoCancelarDialogo({
    super.key,
    required this.onPressed,
    this.texto = 'Cancelar',
  });

  @override
  Widget build(BuildContext context) => TextButton(
    style: _estiloDialogo(),
    onPressed: onPressed,
    child: Text(texto),
  );
}

/// Confirmação destrutiva (Excluir): fundo `erro`, texto branco.
class BotaoExcluirDialogo extends StatelessWidget {
  final VoidCallback onPressed;
  final String texto;

  const BotaoExcluirDialogo({
    super.key,
    required this.onPressed,
    this.texto = 'Excluir',
  });

  @override
  Widget build(BuildContext context) => FilledButton(
    style: _estiloDialogo().merge(
      FilledButton.styleFrom(
        backgroundColor: RecorteCores.erro,
        foregroundColor: Colors.white,
      ),
    ),
    onPressed: onPressed,
    child: Text(texto),
  );
}

/// Confirmação na cor da marca (Salvar do nome da empresa).
class BotaoMarcaDialogo extends StatelessWidget {
  final VoidCallback onPressed;
  final String texto;

  const BotaoMarcaDialogo({
    super.key,
    required this.onPressed,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    final marca = context.marca;
    return FilledButton(
      style: _estiloDialogo().merge(
        FilledButton.styleFrom(
          backgroundColor: marca.brand,
          foregroundColor: marca.onBrand,
        ),
      ),
      onPressed: onPressed,
      child: Text(texto),
    );
  }
}

/// Botão flutuante: fundo na cor da marca, raio 14, sombra e linha de corte
/// tracejada a 4 px. Vai no `floatingActionButton` do `Scaffold`.
class BotaoFlutuanteRecorte extends StatelessWidget {
  final String rotulo;
  final IconData icone;
  final VoidCallback onPressed;

  const BotaoFlutuanteRecorte({
    super.key,
    required this.rotulo,
    required this.onPressed,
    this.icone = Icons.add,
  });

  @override
  Widget build(BuildContext context) {
    final marca = context.marca;
    return Padding(
      padding: const EdgeInsets.all(5),
      child: LinhaDeCorte(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: marca.brand,
            borderRadius: BorderRadius.circular(RecorteRaio.adesivo),
            boxShadow: RecorteSombra.botaoFlutuante,
          ),
          child: Material(
            type: MaterialType.transparency,
            borderRadius: BorderRadius.circular(RecorteRaio.adesivo),
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(RecorteRaio.adesivo),
              child: Container(
                height: RecorteEspaco.alturaBotaoFlutuante,
                padding: const EdgeInsets.fromLTRB(18, 0, 22, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icone, size: 22, color: marca.onBrand),
                    const SizedBox(width: 10),
                    Text(
                      rotulo,
                      style: RecorteTexto.botaoFlutuante.copyWith(
                        color: marca.onBrand,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
