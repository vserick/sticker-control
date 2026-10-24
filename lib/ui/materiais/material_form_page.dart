import 'package:flutter/material.dart';

import '../../data/material_repository.dart';
import '../../logic/calculo.dart';
import '../../logic/dinheiro.dart';
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
  }

  @override
  void dispose() {
    _nome.dispose();
    _preco.dispose();
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

  Future<void> _salvar() async {
    _erroDoRepositorio = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    final centavos = lerCentavos(_preco.text)!;
    try {
      final material = widget.material;
      if (material == null) {
        await widget.repositorio.criar(
          nome: _nome.text,
          precoPorMetroCentavos: centavos,
        );
      } else {
        await widget.repositorio.atualizar(
          material.id,
          nome: _nome.text,
          precoPorMetroCentavos: centavos,
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
              rotulo: 'Preço por metro',
              controller: _preco,
              alturaMinima: 72,
              prefixo: r'R$',
              sufixo: '/ m',
              teclado: const TextInputType.numberWithOptions(decimal: true),
              validator: _validarPreco,
              onSubmitted: (_) => _salvar(),
            ),
            const SizedBox(height: RecorteEspaco.entreBlocos),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  const IconeCota.vertical(),
                  const SizedBox(width: 8),
                  Text(
                    'Largura fixa: 1,10 m.',
                    style: RecorteTexto.corpoSecundario.copyWith(
                      fontSize: 13,
                      height: 18 / 13,
                    ),
                  ),
                ],
              ),
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
