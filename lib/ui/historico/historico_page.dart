import 'package:flutter/material.dart';

import '../../logic/dinheiro.dart';
import '../../logic/formatacao.dart';
import '../../logic/orcamento.dart';
import '../../servicos.dart';
import '../materiais/materiais_page.dart';
import '../mensagem/modelo_mensagem_page.dart';
import '../orcamento/novo_orcamento_page.dart';
import '../recorte/botoes.dart';
import '../recorte/campo.dart';
import '../recorte/estados.dart';
import '../recorte/grade_mesa.dart';
import '../recorte/icones.dart';
import '../recorte/lista_bloco.dart';
import '../recorte/logotipo.dart';
import '../recorte/menu.dart';
import '../recorte/tipografia.dart';
import '../recorte/tokens.dart';
import 'detalhe_orcamento_page.dart';

enum _OpcaoMenu { materiais, empresa, mensagem }

/// Tela inicial: histórico de orçamentos e atalho para criar um novo.
class HistoricoPage extends StatefulWidget {
  final Servicos servicos;

  const HistoricoPage({super.key, required this.servicos});

  @override
  State<HistoricoPage> createState() => _HistoricoPageState();
}

class _HistoricoPageState extends State<HistoricoPage> {
  late final Stream<List<Orcamento>> _orcamentos = widget.servicos.orcamentos
      .observarTodos();

  void _abrir(Widget pagina) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => pagina));
  }

  void _selecionar(_OpcaoMenu opcao) {
    switch (opcao) {
      case _OpcaoMenu.materiais:
        _abrir(MateriaisPage(repositorio: widget.servicos.materiais));
      case _OpcaoMenu.empresa:
        _editarEmpresa();
      case _OpcaoMenu.mensagem:
        _editarMensagem();
    }
  }

  Future<void> _editarMensagem() async {
    final config = widget.servicos.configuracoes;
    final modelo = await config.lerModeloMensagem();
    final empresa = await config.lerNomeEmpresa();
    if (!mounted) return;
    _abrir(
      ModeloMensagemPage(
        servicos: widget.servicos,
        modeloInicial: modelo,
        empresa: empresa,
      ),
    );
  }

  Future<void> _editarEmpresa() async {
    final atual = await widget.servicos.configuracoes.lerNomeEmpresa();
    if (!mounted) return;
    final nome = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoEmpresa(nomeAtual: atual ?? ''),
    );
    if (nome != null) {
      await widget.servicos.configuracoes.salvarNomeEmpresa(nome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: BotaoFlutuanteRecorte(
        rotulo: 'Novo orçamento',
        onPressed: () => _abrir(NovoOrcamentoPage(servicos: widget.servicos)),
      ),
      body: Stack(
        children: [
          const Positioned(top: 0, left: 0, right: 0, child: GradeMesa()),
          StreamBuilder<List<Orcamento>>(
            stream: _orcamentos,
            builder: (context, snapshot) {
              final orcamentos = snapshot.data;
              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    automaticallyImplyLeading: false,
                    titleSpacing: RecorteEspaco.margemTela,
                    title: const LogotipoTopo(),
                    actions: [
                      MenuRecorte<_OpcaoMenu>(
                        onSelected: _selecionar,
                        itens: (_) => [
                          itemMenuRecorte(
                            valor: _OpcaoMenu.materiais,
                            icone: Icons.layers_outlined,
                            texto: 'Materiais',
                          ),
                          itemMenuRecorte(
                            valor: _OpcaoMenu.empresa,
                            icone: Icons.storefront_outlined,
                            texto: 'Nome da empresa',
                          ),
                          itemMenuRecorte(
                            valor: _OpcaoMenu.mensagem,
                            icone: Icons.chat_outlined,
                            texto: 'Mensagem do WhatsApp',
                          ),
                        ],
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        RecorteEspaco.margemTela,
                        14,
                        RecorteEspaco.margemTela,
                        20,
                      ),
                      child: Text(
                        'Orçamentos',
                        style: RecorteTexto.tituloInicio,
                      ),
                    ),
                  ),
                  if (orcamentos == null)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: CarregandoCentralizado(),
                    )
                  else if (orcamentos.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EstadoVazio(
                        icone: Icons.add,
                        titulo: 'Nenhum orçamento salvo ainda.',
                        texto: 'Toque em "Novo orçamento" para começar.',
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        RecorteEspaco.margemTela,
                        0,
                        RecorteEspaco.margemTela,
                        96,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: ListaBloco(
                          itens: [
                            for (final o in orcamentos) _itemOrcamento(o),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _itemOrcamento(Orcamento o) {
    final proprio = o.tipo == TipoProducao.propria;
    return ItemListaBloco(
      ficha: FichaModalidade(propria: proprio),
      titulo: o.descricao ?? o.materialNome ?? 'Sem descrição',
      metadado:
          '${formatarDataHora(o.criadoEm)} · '
          '${proprio ? 'Própria' : 'Terceirizada'}',
      valor: formatarBrl(o.finalCentavos),
      onTap: () =>
          _abrir(DetalheOrcamentoPage(servicos: widget.servicos, orcamento: o)),
    );
  }
}

/// Pede o nome da empresa. Devolve o texto digitado ao salvar, ou `null` ao
/// cancelar. O controller é descartado junto com o diálogo, só depois da
/// animação de fechamento.
class _DialogoEmpresa extends StatefulWidget {
  final String nomeAtual;

  const _DialogoEmpresa({required this.nomeAtual});

  @override
  State<_DialogoEmpresa> createState() => _DialogoEmpresaState();
}

class _DialogoEmpresaState extends State<_DialogoEmpresa> {
  late final _controller = TextEditingController(text: widget.nomeAtual);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nome da empresa'),
      content: CampoRecorte(
        rotulo: '',
        rotuloSemantico: 'Nome da empresa',
        controller: _controller,
        autofocus: true,
        linha: true,
        grande: false,
        alturaMinima: 56,
        estiloValor: RecorteTexto.valorTexto.copyWith(
          fontWeight: FontWeight.w500,
          fontVariations: [FontVariation.weight(500)],
        ),
        ajuda: 'Aparece no topo da mensagem de WhatsApp.',
      ),
      actions: [
        BotaoCancelarDialogo(onPressed: () => Navigator.of(context).pop()),
        BotaoMarcaDialogo(
          texto: 'Salvar',
          onPressed: () => Navigator.of(context).pop(_controller.text),
        ),
      ],
    );
  }
}
