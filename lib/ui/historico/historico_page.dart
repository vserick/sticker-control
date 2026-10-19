import 'package:flutter/material.dart';

import '../../logic/dinheiro.dart';
import '../../logic/formatacao.dart';
import '../../logic/orcamento.dart';
import '../../servicos.dart';
import '../materiais/materiais_page.dart';
import '../mensagem/modelo_mensagem_page.dart';
import '../orcamento/novo_orcamento_page.dart';
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
      appBar: AppBar(
        title: const Text('Orçamentos'),
        actions: [
          PopupMenuButton<_OpcaoMenu>(
            tooltip: 'Menu',
            onSelected: _selecionar,
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: _OpcaoMenu.materiais,
                child: ListTile(
                  leading: Icon(Icons.layers_outlined),
                  title: Text('Materiais'),
                ),
              ),
              PopupMenuItem(
                value: _OpcaoMenu.empresa,
                child: ListTile(
                  leading: Icon(Icons.storefront_outlined),
                  title: Text('Nome da empresa'),
                ),
              ),
              PopupMenuItem(
                value: _OpcaoMenu.mensagem,
                child: ListTile(
                  leading: Icon(Icons.chat_outlined),
                  title: Text('Mensagem do WhatsApp'),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrir(NovoOrcamentoPage(servicos: widget.servicos)),
        icon: const Icon(Icons.add),
        label: const Text('Novo orçamento'),
      ),
      body: StreamBuilder<List<Orcamento>>(
        stream: _orcamentos,
        builder: (context, snapshot) {
          final orcamentos = snapshot.data;
          if (orcamentos == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (orcamentos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nenhum orçamento salvo ainda.\n'
                  'Toque em "Novo orçamento" para começar.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 88),
            itemCount: orcamentos.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final o = orcamentos[i];
              final proprio = o.tipo == TipoProducao.propria;
              return ListTile(
                title: Text(
                  o.descricao ?? o.materialNome ?? 'Sem descrição',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${formatarDataHora(o.criadoEm)} · '
                  '${proprio ? 'Própria' : 'Terceirizada'}',
                ),
                trailing: Text(
                  formatarBrl(o.finalCentavos),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                onTap: () => _abrir(
                  DetalheOrcamentoPage(servicos: widget.servicos, orcamento: o),
                ),
              );
            },
          );
        },
      ),
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
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          helperText: 'Aparece no topo da mensagem de WhatsApp.',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
