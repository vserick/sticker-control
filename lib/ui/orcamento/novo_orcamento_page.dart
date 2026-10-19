import 'package:flutter/material.dart';

import '../../data/material_repository.dart';
import '../../logic/calculo.dart';
import '../../logic/dinheiro.dart';
import '../../logic/formatacao.dart';
import '../../logic/orcamento.dart';
import '../../servicos.dart';
import '../materiais/materiais_page.dart';
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
      SnackBar(
        content: Text(
          enviado
              ? 'Orçamento salvo.'
              : 'Orçamento salvo, mas não foi possível abrir o WhatsApp.',
        ),
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

  Widget _campo({
    required TextEditingController controller,
    required String label,
    String? prefixo,
    String? sufixo,
    String? erro,
    String? ajuda,
    TextInputType teclado = _teclado,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: teclado,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefixo,
          suffixText: sufixo,
          helperText: ajuda,
          errorText: erro,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _formularioProprio(List<MaterialAdesivo> materiais) {
    if (materiais.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Nenhum material cadastrado'),
          subtitle: const Text('Cadastre um material para calcular.'),
          trailing: TextButton(
            onPressed: _abrirMateriais,
            child: const Text('Cadastrar'),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<int>(
            initialValue: materiais.any((m) => m.id == _materialId)
                ? _materialId
                : null,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Material',
              border: OutlineInputBorder(),
            ),
            items: [
              for (final m in materiais)
                DropdownMenuItem(
                  value: m.id,
                  child: Text(
                    '${m.nome} · ${formatarBrl(m.precoPorMetroCentavos)} / m',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: (id) => setState(() => _materialId = id),
          ),
        ),
        _campo(
          controller: _comprimento,
          label: 'Comprimento',
          sufixo: 'm',
          erro: _erroMedida(_comprimento),
        ),
        _campo(
          controller: _largura,
          label: 'Largura',
          sufixo: 'm',
          erro: _erroMedida(_largura),
        ),
      ],
    );
  }

  Widget _formularioTerceirizado() => _campo(
    controller: _fornecedor,
    label: 'Valor do fornecedor',
    prefixo: r'R$ ',
    erro: _erroFornecedor,
  );

  Widget _resultadoCard(ResultadoCalculo? r) {
    final tema = Theme.of(context);
    if (r == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Preencha os campos para ver o preço.',
            style: tema.textTheme.bodyMedium,
          ),
        ),
      );
    }
    final acrescimo = r.finalCentavos - r.custoCentavos;
    Widget linha(String rotulo, String valor, {TextStyle? estilo}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rotulo, style: estilo),
          Text(valor, style: estilo),
        ],
      ),
    );
    return Card(
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            linha('Custo', formatarBrl(r.custoCentavos)),
            linha('Acréscimo', formatarBrl(acrescimo)),
            const Divider(),
            linha(
              'Preço final',
              formatarBrl(r.finalCentavos),
              estilo: tema.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (r.avisoLargura) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber, color: tema.colorScheme.error),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Largura acima de 1,10 m: a produção própria não '
                      'comporta. Considere terceirizar.',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo orçamento'),
        actions: [
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
          final materiais = snapshot.data ?? const <MaterialAdesivo>[];
          _resolverMaterialBase(materiais);
          final proprio = _tipo == TipoProducao.propria;
          final rascunho = _rascunho(materiais);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<TipoProducao>(
                segments: const [
                  ButtonSegment(
                    value: TipoProducao.propria,
                    label: Text('Própria'),
                  ),
                  ButtonSegment(
                    value: TipoProducao.terceirizada,
                    label: Text('Terceirizada'),
                  ),
                ],
                selected: {_tipo},
                onSelectionChanged: (s) => setState(() => _tipo = s.first),
              ),
              const SizedBox(height: 16),
              if (proprio)
                _formularioProprio(materiais)
              else
                _formularioTerceirizado(),
              if (!proprio)
                _campo(
                  controller: _largura,
                  label: 'Largura (informativa)',
                  sufixo: 'm',
                  erro: _erroMedida(_largura),
                  ajuda: 'Não altera o preço.',
                ),
              _campo(
                controller: _acrescimo,
                label: 'Acréscimo',
                sufixo: '%',
                erro: _erroAcrescimo,
              ),
              _campo(
                controller: _descricao,
                label: 'Descrição (opcional)',
                teclado: TextInputType.text,
              ),
              _resultadoCard(_resultado(materiais)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: rascunho == null || _salvando
                    ? null
                    : () => _salvar(rascunho),
                icon: const Icon(Icons.save_outlined),
                label: const Text('Salvar'),
              ),
              const SizedBox(height: 8),
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
