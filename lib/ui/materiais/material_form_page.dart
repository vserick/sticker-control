import 'package:flutter/material.dart';

import '../../data/material_repository.dart';
import '../../logic/calculo.dart';
import '../../logic/dinheiro.dart';
import '../../logic/formatacao.dart';
import '../recorte/barra.dart';
import '../recorte/botoes.dart';
import '../recorte/campo.dart';
import '../recorte/icones.dart';
import '../recorte/tipografia.dart';
import '../recorte/tokens.dart';

/// Cria um material, ou edita [material] quando informado.
class MaterialFormPage extends StatefulWidget {
  final MaterialRepository repositorio;
  final MaterialAdesivo? material;

  const MaterialFormPage({super.key, required this.repositorio, this.material});

  @override
  State<MaterialFormPage> createState() => _MaterialFormPageState();
}

class _MaterialFormPageState extends State<MaterialFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _preco;
  late final TextEditingController _largura;
  late final TextEditingController _comprimento;

  /// A largura começa travada, para não ser alterada sem querer.
  bool _larguraTravada = true;
  String? _erroDoRepositorio;
  bool _salvando = false;

  bool get _editando => widget.material != null;

  @override
  void initState() {
    super.initState();
    final m = widget.material;
    _nome = TextEditingController(text: m?.nome ?? '');
    _preco = TextEditingController(
      text: m == null ? '' : _centavosParaCampo(m.precoPorMetroCentavos),
    );
    _largura = TextEditingController(
      text: formatarMetros(m?.larguraMm ?? larguraMaximaProprioMm),
    );
    final rolo = m?.comprimentoMm;
    _comprimento = TextEditingController(
      text: rolo == null ? '' : formatarMetros(rolo),
    );
  }

  @override
  void dispose() {
    _nome.dispose();
    _preco.dispose();
    _largura.dispose();
    _comprimento.dispose();
    super.dispose();
  }

  String _centavosParaCampo(int centavos) =>
      '${centavos ~/ 100},${(centavos % 100).toString().padLeft(2, '0')}';

  String? _validarNome(String? valor) {
    if (valor == null || valor.trim().isEmpty) return 'Informe o nome.';
    return _erroDoRepositorio;
  }

  String? _validarPreco(String? valor) {
    final centavos = lerCentavos(valor ?? '');
    if (centavos == null) return 'Informe um valor válido, ex.: 50,00.';
    if (centavos <= 0) return 'O preço deve ser maior que zero.';
    return null;
  }

  String? _validarLargura(String? valor) {
    final mm = lerMetrosEmMm(valor ?? '');
    if (mm == null) return 'Informe uma largura válida, ex.: 1,10.';
    if (mm <= 0) return 'A largura deve ser maior que zero.';
    return null;
  }

  /// Opcional: em branco vale "sem metragem informada".
  String? _validarComprimento(String? valor) {
    if (valor == null || valor.trim().isEmpty) return null;
    final mm = lerMetrosEmMm(valor);
    if (mm == null) return 'Informe um comprimento válido, ex.: 50,00.';
    if (mm <= 0) return 'O comprimento deve ser maior que zero.';
    return null;
  }

  Future<void> _salvar() async {
    _erroDoRepositorio = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final centavos = lerCentavos(_preco.text)!;
    final larguraMm = lerMetrosEmMm(_largura.text)!;
    final comprimentoMm = _comprimento.text.trim().isEmpty
        ? null
        : lerMetrosEmMm(_comprimento.text);
    try {
      final material = widget.material;
      if (material == null) {
        await widget.repositorio.criar(
          nome: _nome.text,
          precoPorMetroCentavos: centavos,
          larguraMm: larguraMm,
          comprimentoMm: comprimentoMm,
        );
      } else {
        await widget.repositorio.atualizar(
          material.id,
          nome: _nome.text,
          precoPorMetroCentavos: centavos,
          larguraMm: larguraMm,
          comprimentoMm: comprimentoMm,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on ErroDeValidacao catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      _erroDoRepositorio = e.mensagem;
      _formKey.currentState!.validate();
    }
  }

  Future<void> _excluir() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir material?'),
        content: Text(
          'Orçamentos já salvos com "${widget.material!.nome}" não são '
          'alterados.',
        ),
        actions: [
          BotaoCancelarDialogo(
            onPressed: () => Navigator.of(context).pop(false),
          ),
          BotaoExcluirDialogo(onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmou != true) return;
    await widget.repositorio.excluir(widget.material!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraRecorte(
        titulo: _editando ? 'Editar material' : 'Novo material',
        acoes: [
          if (_editando)
            IconButton(
              tooltip: 'Excluir',
              icon: const Icon(Icons.delete_outline, color: RecorteCores.erro),
              onPressed: _excluir,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            RecorteEspaco.margemTela,
            8,
            RecorteEspaco.margemTela,
            24,
          ),
          children: [
            CampoRecorte(
              rotulo: 'Nome do material',
              controller: _nome,
              grande: false,
              alturaMinima: 72,
              estiloValor: RecorteTexto.valorTexto.copyWith(
                fontSize: 18,
                height: 30 / 18,
                fontWeight: FontWeight.w600,
                fontVariations: [FontVariation.weight(600)],
              ),
              capitalizacao: TextCapitalization.sentences,
              acaoTeclado: TextInputAction.next,
              validator: _validarNome,
              onChanged: (_) => _erroDoRepositorio = null,
            ),
            const SizedBox(height: RecorteEspaco.entreBlocos),
            CampoRecorte(
              rotulo: 'Preço por metro - em comprimento',
              controller: _preco,
              alturaMinima: 72,
              prefixo: r'R$',
              sufixo: '/ m',
              teclado: const TextInputType.numberWithOptions(decimal: true),
              validator: _validarPreco,
              onSubmitted: (_) => _salvar(),
            ),
            const SizedBox(height: RecorteEspaco.entreBlocos),
            CampoRecorte(
              rotulo: 'Largura do material',
              icone: const IconeCota.vertical(),
              controller: _largura,
              alturaMinima: 72,
              sufixo: 'm',
              teclado: const TextInputType.numberWithOptions(decimal: true),
              somenteLeitura: _larguraTravada,
              validator: _validarLargura,
              ajuda: _larguraTravada
                  ? 'Travada. Toque no cadeado para alterar.'
                  : 'Largura do rolo; define o aviso de largura nos orçamentos.',
              trailing: IconButton(
                tooltip: _larguraTravada
                    ? 'Destravar largura'
                    : 'Travar largura',
                icon: Icon(
                  _larguraTravada ? Icons.lock_outline : Icons.lock_open,
                ),
                onPressed: () =>
                    setState(() => _larguraTravada = !_larguraTravada),
              ),
            ),
            const SizedBox(height: RecorteEspaco.entreBlocos),
            CampoRecorte(
              rotulo: 'Comprimento do material',
              icone: const IconeCota.horizontal(),
              controller: _comprimento,
              alturaMinima: 72,
              sufixo: 'm',
              placeholder: 'opcional',
              teclado: const TextInputType.numberWithOptions(decimal: true),
              validator: _validarComprimento,
              ajuda: 'Metragem do rolo; avisa se um orçamento passar dela.',
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
