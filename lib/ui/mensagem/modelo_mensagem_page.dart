import 'package:flutter/material.dart';

import '../../logic/mensagem_whatsapp.dart';
import '../../logic/orcamento.dart';
import '../../servicos.dart';
import '../recorte/avisos.dart';
import '../recorte/barra.dart';
import '../recorte/campo.dart';
import '../recorte/tipografia.dart';
import '../recorte/tokens.dart';

/// Exemplo usado na prévia: o modelo nunca é testado com dados reais.
const _exemplo = RascunhoOrcamento(
  tipo: TipoProducao.propria,
  descricao: 'Adesivo de porta',
  larguraMm: 1100,
  comprimentoMm: 2000,
  materialNome: 'Vinil branco',
  precoPorMetroCentavos: 5000,
  custoCentavos: 10000,
  acrescimoBp: 5000,
  finalCentavos: 15000,
);

/// Edita o modelo da mensagem de WhatsApp com variáveis `{nome}` e mostra uma
/// prévia ao vivo. [modeloInicial] vazio ou `null` parte do modelo padrão.
class ModeloMensagemPage extends StatefulWidget {
  final Servicos servicos;
  final String? modeloInicial;
  final String? empresa;

  const ModeloMensagemPage({
    super.key,
    required this.servicos,
    this.modeloInicial,
    this.empresa,
  });

  @override
  State<ModeloMensagemPage> createState() => _ModeloMensagemPageState();
}

class _ModeloMensagemPageState extends State<ModeloMensagemPage> {
  late final _controller = TextEditingController(
    text: widget.modeloInicial?.trim().isNotEmpty == true
        ? widget.modeloInicial
        : modeloMensagemPadrao,
  );
  final _agora = DateTime.now();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _inserir(String variavel) {
    final texto = '{$variavel}';
    final selecao = _controller.selection;
    final inicio = selecao.isValid ? selecao.start : _controller.text.length;
    final fim = selecao.isValid ? selecao.end : inicio;
    _controller.value = TextEditingValue(
      text: _controller.text.replaceRange(inicio, fim, texto),
      selection: TextSelection.collapsed(offset: inicio + texto.length),
    );
  }

  Future<void> _salvar() async {
    final navigator = Navigator.of(context);
    final mensagens = ScaffoldMessenger.of(context);
    final texto = _controller.text.trim();
    // Igual ao padrão: não grava, para o app seguir o padrão atual.
    await widget.servicos.configuracoes.salvarModeloMensagem(
      texto == modeloMensagemPadrao.trim() ? '' : texto,
    );
    navigator.pop();
    mensagens.showSnackBar(avisoRodape('Mensagem salva.'));
  }

  @override
  Widget build(BuildContext context) {
    final previa = montarMensagemWhatsapp(
      _exemplo,
      empresa: widget.empresa ?? 'Sua Empresa',
      modelo: _controller.text,
      agora: _agora,
    );
    return Scaffold(
      appBar: const BarraRecorte(titulo: 'Mensagem do WhatsApp'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          RecorteEspaco.margemTela,
          8,
          RecorteEspaco.margemTela,
          24,
        ),
        children: [
          Text(
            'Monte a mensagem enviada ao cliente. Toque numa variável para '
            'inseri-la onde o cursor está. Use *texto* para negrito. Linhas '
            'cujas variáveis ficam vazias não aparecem.',
            style: RecorteTexto.corpoSecundario21,
          ),
          const SizedBox(height: RecorteEspaco.entreBlocos),
          CampoRecorte(
            rotulo: 'Modelo da mensagem',
            controller: _controller,
            grande: false,
            estiloValor: RecorteTexto.corpo,
            minLinhas: 8,
            maxLinhas: 16,
            teclado: TextInputType.multiline,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in variaveisMensagem.entries)
                Tooltip(
                  message: v.value,
                  child: ActionChip(
                    label: Text('{${v.key}}'),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 6,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () => _inserir(v.key),
                  ),
                ),
            ],
          ),
          const SizedBox(height: RecorteEspaco.entreBlocos),
          Text('Prévia', style: RecorteTexto.tituloSecao),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: RecorteCores.superficie,
              border: Border.all(color: RecorteCores.borda),
              borderRadius: BorderRadius.circular(RecorteRaio.celula),
            ),
            child: previa.isEmpty
                ? Text(
                    '(mensagem vazia)',
                    style: RecorteTexto.corpo.copyWith(
                      color: RecorteCores.rotulo,
                    ),
                  )
                : SelectableText(previa, style: RecorteTexto.corpo),
          ),
          const SizedBox(height: RecorteEspaco.entreBlocos),
          FilledButton.icon(
            onPressed: _salvar,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar'),
          ),
          const SizedBox(height: RecorteEspaco.entreBotoes),
          TextButton.icon(
            style: TextButton.styleFrom(
              textStyle: RecorteTexto.botaoDialogo,
              iconSize: 20,
            ),
            onPressed: () => _controller.text = modeloMensagemPadrao,
            icon: const Icon(Icons.restore),
            label: const Text('Restaurar padrão'),
          ),
        ],
      ),
    );
  }
}
