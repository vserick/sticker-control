import 'package:flutter/material.dart';

import '../../data/material_repository.dart';
import '../../logic/dinheiro.dart';
import '../recorte/barra.dart';
import '../recorte/botoes.dart';
import '../recorte/estados.dart';
import '../recorte/icones.dart';
import '../recorte/lista_bloco.dart';
import '../recorte/tipografia.dart';
import '../recorte/tokens.dart';
import 'material_form_page.dart';

class MateriaisPage extends StatelessWidget {
  final MaterialRepository repositorio;

  const MateriaisPage({super.key, required this.repositorio});

  void _abrirFormulario(BuildContext context, [MaterialAdesivo? material]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            MaterialFormPage(repositorio: repositorio, material: material),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarraRecorte(titulo: 'Materiais'),
      floatingActionButton: BotaoFlutuanteRecorte(
        rotulo: 'Novo material',
        onPressed: () => _abrirFormulario(context),
      ),
      body: StreamBuilder<List<MaterialAdesivo>>(
        stream: repositorio.observarTodos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const EstadoErro();
          final materiais = snapshot.data;
          if (materiais == null) return const CarregandoCentralizado();
          if (materiais.isEmpty) {
            return const EstadoVazio(
              icone: Icons.layers_outlined,
              titulo: 'Nenhum material cadastrado',
              texto:
                  'Cadastre o primeiro material para poder fazer orçamentos.',
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              RecorteEspaco.margemTela,
              8,
              RecorteEspaco.margemTela,
              96,
            ),
            children: [
              ListaBloco(
                itens: [
                  for (final m in materiais)
                    ItemListaBloco(
                      ficha: const FichaModalidade.material(),
                      titulo: m.nome,
                      metadado: 'Largura 1,10 m',
                      valor: '${formatarBrl(m.precoPorMetroCentavos)} / m',
                      valorComposto: TextSpan(
                        children: [
                          TextSpan(text: formatarBrl(m.precoPorMetroCentavos)),
                          TextSpan(
                            text: ' / m',
                            style: RecorteTexto.rotuloLinha.copyWith(
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      onTap: () => _abrirFormulario(context, m),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
