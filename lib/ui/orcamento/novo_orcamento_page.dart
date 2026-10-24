import 'package:flutter/material.dart';

import '../../data/material_repository.dart';
import '../../logic/calculo.dart';
import '../../logic/dinheiro.dart';
import '../../logic/formatacao.dart';
import '../../logic/orcamento.dart';
import '../../servicos.dart';
import '../materiais/materiais_page.dart';
import '../recorte/avisos.dart';
import '../recorte/barra.dart';
import '../recorte/campo.dart';
import '../recorte/estados.dart';
import '../recorte/icones.dart';
import '../recorte/resultado.dart';
import '../recorte/seletores.dart';
import '../recorte/tipografia.dart';
import '../recorte/tokens.dart';
import 'enviar_whatsapp.dart';

/// Calcula um orçamento com resultado ao vivo (visão interna: custo,
/// acréscimo e preço final), salva no histórico e envia por WhatsApp.
///
/// Com [base] (duplicar), os campos já vêm preenchidos para refazer com outro
/// acréscimo. O material é procurado pelo nome e usa o preço atual dele.
class NovoOrcamentoPage extends StatefulWidget {
  final Servicos servicos;
  final Orcamento? base;

  const NovoOrcamentoPage({super.key, required this.servicos, this.base});

  @override
  State<NovoOrcamentoPage> createState() => _NovoOrcamentoPageState();
}

class _NovoOrcamentoPageState extends State<NovoOrcamentoPage> {
  final _comprimento = TextEditingController();
  final _largura = TextEditingController();
  final _acrescimo = TextEditingController();
  final _fornecedor = TextEditingController();
  final _descricao = TextEditingController();
  TipoProducao _tipo = TipoProducao.propria;
  int? _materialId;
  String? _materialNomeBase;
  bool _salvando = false;

  late final Stream<List<MaterialAdesivo>> _materiais = widget
      .servicos
      .materiais
      .observarTodos();

  @override
  void initState() {
    super.initState();
    final base = widget.base;
    if (base != null) _preencher(base);
    for (final c in [
      _comprimento,
      _largura,
      _acrescimo,
      _fornecedor,
      _descricao,
    ]) {
      c.addListener(_recalcular);
    }
  }

  void _preencher(Orcamento base) {
    _tipo = base.tipo;
    _materialNomeBase = base.materialNome;
    _descricao.text = base.descricao ?? '';
    _acrescimo.text = formatarPercentual(base.acrescimoBp);
    final largura = base.larguraMm;
    if (largura != null) _largura.text = formatarMetros(largura);
    final comprimento = base.comprimentoMm;
    if (comprimento != null) _comprimento.text = formatarMetros(comprimento);
    final fornecedor = base.fornecedorCentavos;
    if (fornecedor != null) {
      _fornecedor.text = formatarBrl(fornecedor).replaceFirst(r'R$ ', '');
    }
  }

  @override
  void dispose() {
    _comprimento.dispose();
    _largura.dispose();
    _acrescimo.dispose();
    _fornecedor.dispose();
    _descricao.dispose();
    super.dispose();
  }

  /// Seleciona o material do orçamento duplicado, se ainda existir.
  void _resolverMaterialBase(List<MaterialAdesivo> materiais) {
    final nome = _materialNomeBase?.toLowerCase();
    if (nome == null || _materialId != null) return;
    _materialId = materiais
        .where((m) => m.nome.toLowerCase() == nome)
        .firstOrNull
        ?.id;
  }

  /// Dados prontos para salvar ou enviar, ou `null` enquanto os campos
  /// estiverem incompletos ou inválidos.
  RascunhoOrcamento? _rascunho(List<MaterialAdesivo> materiais) {
    final resultado = _resultado(materiais);
    final acrescimo = _acrescimoBp;
    if (resultado == null || acrescimo == null) return null;
    final descricao = _descricao.text.trim();
    final texto = descricao.isEmpty ? null : descricao;
    final largura = lerMetrosEmMm(_largura.text);

    if (_tipo == TipoProducao.terceirizada) {
      // Largura é opcional aqui, mas se digitada precisa ser válida.
      if (_largura.text.trim().isNotEmpty &&
          (largura == null || largura <= 0)) {
        return null;
      }
      return RascunhoOrcamento(
        tipo: _tipo,
        descricao: texto,
        larguraMm: _largura.text.trim().isEmpty ? null : largura,
        fornecedorCentavos: lerCentavos(_fornecedor.text),
        custoCentavos: resultado.custoCentavos,
        acrescimoBp: acrescimo,
        finalCentavos: resultado.finalCentavos,
      );
    }
    final material = materiais.where((m) => m.id == _materialId).firstOrNull;
    if (material == null) return null;
    return RascunhoOrcamento(
      tipo: _tipo,
      descricao: texto,
      larguraMm: largura,
      comprimentoMm: lerMetrosEmMm(_comprimento.text),
      materialNome: material.nome,
      precoPorMetroCentavos: material.precoPorMetroCentavos,
      custoCentavos: resultado.custoCentavos,
      acrescimoBp: acrescimo,
      finalCentavos: resultado.finalCentavos,
    );
  }

  /// Grava o orçamento e, com [enviar], abre o WhatsApp em seguida. Todo
  /// orçamento enviado fica no histórico.
  Future<void> _salvar(
    RascunhoOrcamento rascunho, {
    bool enviar = false,
  }) async {
    setState(() => _salvando = true);
    final navigator = Navigator.of(context);
    final mensagens = ScaffoldMessenger.of(context);
    final salvo = await widget.servicos.orcamentos.salvar(rascunho);
    final enviado = enviar
        ? await enviarPorWhatsapp(widget.servicos, salvo)
        : true;
    navigator.pop();
    mensagens.showSnackBar(
      avisoRodape(
        enviado
            ? 'Orçamento salvo.'
            : 'Orçamento salvo, mas não foi possível abrir o WhatsApp.',
        sucesso: enviado,
      ),
    );
  }

  void _recalcular() => setState(() {});

  /// Acréscimo em branco vale 0%; `null` se o texto for inválido.
  int? get _acrescimoBp =>
      _acrescimo.text.trim().isEmpty ? 0 : lerPercentualEmBp(_acrescimo.text);

  /// Resultado atual, ou `null` enquanto os campos estiverem incompletos ou
  /// inválidos.
  ResultadoCalculo? _resultado(List<MaterialAdesivo> materiais) {
    final acrescimo = _acrescimoBp;
    if (acrescimo == null) return null;
    try {
      if (_tipo == TipoProducao.terceirizada) {
        final valor = lerCentavos(_fornecedor.text);
        if (valor == null) return null;
        return calcularTerceirizado(
          fornecedorCentavos: valor,
          acrescimoBp: acrescimo,
        );
      }
      final material = materiais.where((m) => m.id == _materialId).firstOrNull;
      final comprimento = lerMetrosEmMm(_comprimento.text);
      final largura = lerMetrosEmMm(_largura.text);
      if (material == null || comprimento == null || largura == null) {
        return null;
      }
      return calcularProprio(
        precoMetroCentavos: material.precoPorMetroCentavos,
        comprimentoMm: comprimento,
        larguraMm: largura,
        acrescimoBp: acrescimo,
        larguraMaximaMm: material.larguraMm,
      );
    } on ErroDeValidacao {
      return null;
    }
  }

  String? _erroMedida(TextEditingController c) {
    if (c.text.trim().isEmpty) return null;
    final mm = lerMetrosEmMm(c.text);
    if (mm == null) return 'Valor inválido, ex.: 1,50.';
    if (mm <= 0) return 'Deve ser maior que zero.';
    return null;
  }

  String? get _erroAcrescimo =>
      _acrescimoBp == null ? 'Valor inválido, ex.: 50.' : null;

  String? get _erroFornecedor {
    if (_fornecedor.text.trim().isEmpty) return null;
    final c = lerCentavos(_fornecedor.text);
    if (c == null) return 'Valor inválido, ex.: 80,00.';
    if (c <= 0) return 'Deve ser maior que zero.';
    return null;
  }

  void _abrirMateriais() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MateriaisPage(repositorio: widget.servicos.materiais),
      ),
    );
  }

  static const _teclado = TextInputType.numberWithOptions(decimal: true);

  /// O limite é a largura do material escolhido (1,10 m se não houver).
  String _avisoLargura(List<MaterialAdesivo> materiais) {
    final material = materiais.where((m) => m.id == _materialId).firstOrNull;
    final limite = formatarMetros(
      material?.larguraMm ?? larguraMaximaProprioMm,
    );
    return 'Largura acima de $limite m: a produção própria não comporta. '
        'Considere terceirizar.';
  }

  /// Mensagens de erro de uma moldura, sem as vazias.
  List<String> _erros(List<String?> erros) => [for (final e in erros) ?e];

  Widget _semMaterial() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: RecorteCores.superficie,
        border: Border.all(color: RecorteCores.borda),
        borderRadius: BorderRadius.circular(RecorteRaio.celula),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FichaModalidade(propria: false, icone: Icons.layers_outlined),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nenhum material cadastrado',
                  style: RecorteTexto.tituloEstado.copyWith(
                    fontSize: 16,
                    height: 22 / 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cadastre um material para calcular.',
                  style: RecorteTexto.corpoSecundario,
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(
                      64,
                      RecorteEspaco.alturaBotaoDialogo,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: RecorteTexto.botaoDialogo,
                    iconSize: 18,
                  ),
                  onPressed: _abrirMateriais,
                  icon: const Icon(Icons.add),
                  label: const Text('Cadastrar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Célula de carregamento no lugar do seletor e das medidas (5.1).
  Widget _carregandoMateriais() {
    return Container(
      height: 156,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: RecorteCores.superficie,
        border: Border.all(color: RecorteCores.borda),
        borderRadius: BorderRadius.circular(RecorteRaio.celula),
      ),
      child: const IndicadorCarregando(rotuloSemantico: 'Carregando materiais'),
    );
  }

  /// Duplicado cujo material original não existe mais (5.3): lista já
  /// carregada, nenhum material com o nome do original e nada escolhido.
  bool _materialOriginalExcluido(List<MaterialAdesivo> materiais) {
    final nome = _materialNomeBase?.toLowerCase();
    return widget.base != null &&
        nome != null &&
        _materialId == null &&
        !materiais.any((m) => m.nome.toLowerCase() == nome);
  }

  List<Widget> _formularioProprio(List<MaterialAdesivo>? materiais) {
    if (materiais == null) return [_carregandoMateriais()];
    if (materiais.isEmpty) return [_semMaterial()];
    return [
      SeletorMaterial(
        materiais: [
          for (final m in materiais)
            (
              id: m.id,
              nome: m.nome,
              preco: '${formatarBrl(m.precoPorMetroCentavos)} / m',
            ),
        ],
        selecionado: _materialId,
        onChanged: (id) => setState(() => _materialId = id),
      ),
      if (_materialOriginalExcluido(materiais))
        const AvisoAmarelo(
          icone: Icons.info_outline,
          texto: 'O material original não existe mais. Escolha outro.',
        ),
      MolduraRecorte(
        eixo: Axis.horizontal,
        erros: _erros([_erroMedida(_comprimento), _erroMedida(_largura)]),
        filhos: [
          CampoInterno(
            rotulo: 'Comprimento',
            icone: const IconeCota.horizontal(),
            controller: _comprimento,
            teclado: _teclado,
            sufixo: 'm',
            erro: _erroMedida(_comprimento) != null,
          ),
          CampoInterno(
            rotulo: 'Largura',
            icone: const IconeCota.vertical(),
            controller: _largura,
            teclado: _teclado,
            sufixo: 'm',
            erro: _erroMedida(_largura) != null,
          ),
        ],
      ),
    ];
  }

  Widget _formularioTerceirizado() {
    return MolduraRecorte(
      erros: _erros([_erroFornecedor, _erroMedida(_largura)]),
      ajuda: 'Não altera o preço.',
      filhos: [
        CampoInterno(
          rotulo: 'Valor do fornecedor',
          controller: _fornecedor,
          teclado: _teclado,
          prefixo: r'R$',
          erro: _erroFornecedor != null,
        ),
        CampoInterno(
          rotulo: 'Largura (informativa)',
          icone: const IconeCota.vertical(),
          controller: _largura,
          teclado: _teclado,
          sufixo: 'm',
          erro: _erroMedida(_largura) != null,
        ),
      ],
    );
  }

  Widget _blocoResultado(ResultadoCalculo? r, List<MaterialAdesivo> materiais) {
    return ResultadoRecorte(
      resumo: r == null
          ? null
          : ResumoPreco(
              custo: formatarBrl(r.custoCentavos),
              rotuloAcrescimo: 'Acréscimo',
              acrescimo: formatarBrl(r.finalCentavos - r.custoCentavos),
              precoFinal: formatarBrl(r.finalCentavos),
            ),
      aviso: r != null && r.avisoLargura ? _avisoLargura(materiais) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarraRecorte(
        titulo: 'Novo orçamento',
        acoes: [
          IconButton(
            tooltip: 'Materiais',
            icon: const Icon(Icons.layers_outlined),
            onPressed: _abrirMateriais,
          ),
        ],
      ),
      body: StreamBuilder<List<MaterialAdesivo>>(
        stream: _materiais,
        builder: (context, snapshot) {
          final carregados = snapshot.data;
          final materiais = carregados ?? const <MaterialAdesivo>[];
          _resolverMaterialBase(materiais);
          final proprio = _tipo == TipoProducao.propria;
          final rascunho = _rascunho(materiais);
          final blocos = <Widget>[
            SeletorModalidade<TipoProducao>(
              opcoes: const [
                (valor: TipoProducao.propria, rotulo: 'Própria'),
                (valor: TipoProducao.terceirizada, rotulo: 'Terceirizada'),
              ],
              selecionado: _tipo,
              onChanged: (t) => setState(() => _tipo = t),
            ),
            if (proprio)
              ..._formularioProprio(carregados)
            else
              _formularioTerceirizado(),
            MolduraRecorte(
              erros: _erros([_erroAcrescimo]),
              filhos: [
                CampoInterno(
                  rotulo: 'Acréscimo',
                  controller: _acrescimo,
                  teclado: _teclado,
                  sufixo: '%',
                  placeholder: '0',
                  alturaMinima: 72,
                  erro: _erroAcrescimo != null,
                ),
                CampoInterno(
                  rotulo: 'Descrição',
                  rotuloSemantico: 'Descrição (opcional)',
                  controller: _descricao,
                  placeholder: 'opcional',
                  linha: true,
                  grande: false,
                  capitalizacao: TextCapitalization.sentences,
                ),
              ],
            ),
            _blocoResultado(_resultado(materiais), materiais),
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              RecorteEspaco.margemTela,
              8,
              RecorteEspaco.margemTela,
              24,
            ),
            children: [
              for (final b in blocos) ...[
                b,
                const SizedBox(height: RecorteEspaco.entreBlocos),
              ],
              FilledButton.icon(
                onPressed: rascunho == null || _salvando
                    ? null
                    : () => _salvar(rascunho),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar'),
              ),
              const SizedBox(height: RecorteEspaco.entreBotoes),
              OutlinedButton.icon(
                onPressed: rascunho == null || _salvando
                    ? null
                    : () => _salvar(rascunho, enviar: true),
                icon: const Icon(Icons.send),
                label: const Text('Salvar e enviar por WhatsApp'),
              ),
            ],
          );
        },
      ),
    );
  }
}
