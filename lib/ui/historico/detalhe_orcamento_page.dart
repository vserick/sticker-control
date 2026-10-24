import 'package:flutter/material.dart';

import '../../logic/dinheiro.dart';
import '../../logic/formatacao.dart';
import '../../logic/orcamento.dart';
import '../../servicos.dart';
import '../orcamento/enviar_whatsapp.dart';
import '../orcamento/novo_orcamento_page.dart';
import '../recorte/avisos.dart';
import '../recorte/barra.dart';
import '../recorte/botoes.dart';
import '../recorte/icones.dart';
import '../recorte/resultado.dart';
import '../recorte/tipografia.dart';
import '../recorte/tokens.dart';

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
          BotaoCancelarDialogo(onPressed: () => Navigator.of(ctx).pop(false)),
          BotaoExcluirDialogo(onPressed: () => Navigator.of(ctx).pop(true)),
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
        avisoRodape('Não foi possível abrir o WhatsApp.', sucesso: false),
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
    final proprio = o.tipo == TipoProducao.propria;
    final acrescimo = o.finalCentavos - o.custoCentavos;

    final linhas = <(String, String)>[
      if (proprio && o.materialNome != null)
        (
          'Material',
          '${o.materialNome} · '
              '${formatarBrl(o.precoPorMetroCentavos ?? 0)} / m',
        ),
      if (o.larguraMm != null) ('Largura', '${formatarMetros(o.larguraMm!)} m'),
      if (o.comprimentoMm != null)
        ('Comprimento', '${formatarMetros(o.comprimentoMm!)} m'),
      if (!proprio && o.fornecedorCentavos != null)
        ('Fornecedor', formatarBrl(o.fornecedorCentavos!)),
    ];

    return Scaffold(
      appBar: const BarraRecorte(titulo: 'Orçamento'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          RecorteEspaco.margemTela,
          8,
          RecorteEspaco.margemTela,
          24,
        ),
        children: [
          _CartaoDados(
            propria: proprio,
            titulo: o.descricao ?? o.materialNome ?? 'Sem descrição',
            metadado:
                '${formatarDataHora(o.criadoEm)} · '
                '${proprio ? 'Própria' : 'Terceirizada'}',
            linhas: linhas,
          ),
          const SizedBox(height: RecorteEspaco.entreBlocos),
          ResultadoRecorte(
            resumo: ResumoPreco(
              custo: formatarBrl(o.custoCentavos),
              rotuloAcrescimo:
                  'Acréscimo (${formatarPercentual(o.acrescimoBp)}%)',
              acrescimo: formatarBrl(acrescimo),
              precoFinal: formatarBrl(o.finalCentavos),
            ),
          ),
          const SizedBox(height: RecorteEspaco.entreBlocos),
          FilledButton.icon(
            onPressed: () => _enviar(context),
            icon: const Icon(Icons.send),
            label: const Text('Enviar por WhatsApp'),
          ),
          const SizedBox(height: RecorteEspaco.entreBotoes),
          OutlinedButton.icon(
            onPressed: () => _duplicar(context),
            icon: const Icon(Icons.copy),
            label: const Text('Duplicar'),
          ),
          const SizedBox(height: RecorteEspaco.entreBotoes),
          TextButton.icon(
            style: estiloDestrutivoTexto(),
            onPressed: () => _excluir(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

/// Cartão de dados: cabeçalho (ficha, título, data · modalidade) e, abaixo,
/// as linhas rótulo/valor dos campos que existem.
class _CartaoDados extends StatelessWidget {
  final bool propria;
  final String titulo;
  final String metadado;
  final List<(String, String)> linhas;

  const _CartaoDados({
    required this.propria,
    required this.titulo,
    required this.metadado,
    required this.linhas,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RecorteCores.superficie,
        border: Border.all(color: RecorteCores.borda),
        borderRadius: BorderRadius.circular(RecorteRaio.celula),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                FichaModalidade(propria: propria, tamanho: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titulo, style: RecorteTexto.tituloCartao),
                      const SizedBox(height: 2),
                      Text(metadado, style: RecorteTexto.metadado),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final (rotulo, valor) in linhas) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rotulo, style: RecorteTexto.corpoSecundario),
                  const SizedBox(width: 16),
                  Flexible(
                    child: Text(
                      valor,
                      textAlign: TextAlign.end,
                      style: RecorteTexto.valorLinha,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
