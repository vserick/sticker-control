import 'package:flutter/material.dart';

import '../../logic/dinheiro.dart';
import '../../logic/formatacao.dart';
import '../../logic/orcamento.dart';
import '../../servicos.dart';
import '../orcamento/enviar_whatsapp.dart';
import '../orcamento/novo_orcamento_page.dart';

/// Dados salvos de um orçamento (visão interna), com compartilhar, duplicar e
/// excluir.
class DetalheOrcamentoPage extends StatelessWidget {
  final Servicos servicos;
  final Orcamento orcamento;

  const DetalheOrcamentoPage({
    super.key,
    required this.servicos,
    required this.orcamento,
  });

  Future<void> _excluir(BuildContext context) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir orçamento?'),
        content: const Text('Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmou != true || !context.mounted) return;
    final navigator = Navigator.of(context);
    await servicos.orcamentos.excluir(orcamento.id);
    navigator.pop();
  }

  Future<void> _enviar(BuildContext context) async {
    final mensagens = ScaffoldMessenger.of(context);
    final aberto = await enviarPorWhatsapp(servicos, orcamento);
    if (!aberto) {
      mensagens.showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp.')),
      );
    }
  }

  void _duplicar(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => NovoOrcamentoPage(servicos: servicos, base: orcamento),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final o = orcamento;
    final tema = Theme.of(context);
    final proprio = o.tipo == TipoProducao.propria;
    final acrescimo = o.finalCentavos - o.custoCentavos;

    Widget linha(String rotulo, String valor, {TextStyle? estilo}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo, style: estilo),
          const SizedBox(width: 16),
          Flexible(
            child: Text(valor, style: estilo, textAlign: TextAlign.end),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Orçamento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  linha('Data', formatarDataHora(o.criadoEm)),
                  linha('Tipo', proprio ? 'Própria' : 'Terceirizada'),
                  if (o.descricao != null) linha('Descrição', o.descricao!),
                  if (proprio && o.materialNome != null)
                    linha(
                      'Material',
                      '${o.materialNome} · '
                          '${formatarBrl(o.precoPorMetroCentavos ?? 0)} / m',
                    ),
                  if (o.larguraMm != null)
                    linha('Largura', '${formatarMetros(o.larguraMm!)} m'),
                  if (o.comprimentoMm != null)
                    linha(
                      'Comprimento',
                      '${formatarMetros(o.comprimentoMm!)} m',
                    ),
                  if (!proprio && o.fornecedorCentavos != null)
                    linha('Fornecedor', formatarBrl(o.fornecedorCentavos!)),
                ],
              ),
            ),
          ),
          Card(
            color: tema.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  linha('Custo', formatarBrl(o.custoCentavos)),
                  linha(
                    'Acréscimo (${formatarPercentual(o.acrescimoBp)}%)',
                    formatarBrl(acrescimo),
                  ),
                  const Divider(),
                  linha(
                    'Preço final',
                    formatarBrl(o.finalCentavos),
                    estilo: tema.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => _enviar(context),
            icon: const Icon(Icons.send),
            label: const Text('Enviar por WhatsApp'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _duplicar(context),
            icon: const Icon(Icons.copy),
            label: const Text('Duplicar'),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _excluir(context),
            icon: Icon(Icons.delete_outline, color: tema.colorScheme.error),
            label: Text(
              'Excluir',
              style: TextStyle(color: tema.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
