import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'marca.dart';
import 'tipografia.dart';
import 'tokens.dart';

/// Conteúdo de uma célula de campo (seção 3.2): rótulo em cima, valor
/// embaixo, prefixo/sufixo alinhados pela linha de base. Não desenha a borda
/// externa: use dentro de [MolduraRecorte] (ou de [CampoRecorte], que já traz
/// a moldura). Foco e erro aparecem como contorno interno de 2 px.
class CampoInterno extends StatefulWidget {
  final String rotulo;
  final Widget? icone;
  final TextEditingController controller;
  final TextInputType? teclado;
  final String? prefixo;
  final String? sufixo;
  final String? placeholder;
  final bool erro;

  /// Texto lido por leitores de tela no lugar de [rotulo] (quando difere).
  final String? rotuloSemantico;

  /// `true`: valor numérico grande (Schibsted 26). `false`: texto (Instrument).
  final bool grande;

  /// `true`: rótulo à esquerda e campo à direita, numa linha só (ex.: Descrição).
  final bool linha;
  final double? alturaMinima;
  final int? minLinhas;
  final int? maxLinhas;
  final TextCapitalization capitalizacao;
  final TextInputAction? acaoTeclado;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final List<TextInputFormatter>? formatadores;

  const CampoInterno({
    super.key,
    required this.rotulo,
    required this.controller,
    this.icone,
    this.teclado,
    this.prefixo,
    this.sufixo,
    this.placeholder,
    this.erro = false,
    this.rotuloSemantico,
    this.grande = true,
    this.linha = false,
    this.alturaMinima,
    this.minLinhas,
    this.maxLinhas,
    this.capitalizacao = TextCapitalization.none,
    this.acaoTeclado,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.formatadores,
  });

  @override
  State<CampoInterno> createState() => _CampoInternoState();
}

class _CampoInternoState extends State<CampoInterno> {
  final _foco = FocusNode();

  @override
  void initState() {
    super.initState();
    _foco.addListener(_mudouFoco);
  }

  @override
  void dispose() {
    _foco.removeListener(_mudouFoco);
    _foco.dispose();
    super.dispose();
  }

  void _mudouFoco() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final marca = context.marca;
    final focado = _foco.hasFocus;
    final w = widget;

    final Color corContorno = w.erro
        ? RecorteCores.erro
        : (focado ? marca.brandLinha : Colors.transparent);
    final rotuloEstilo = RecorteTexto.rotuloCelula.copyWith(
      color: w.erro
          ? RecorteCores.erro
          : (focado ? marca.brandTexto : RecorteCores.rotulo),
      fontWeight: focado ? FontWeight.w700 : FontWeight.w600,
      fontVariations: [FontVariation.weight(focado ? 700 : 600)],
    );

    final estiloValor = w.grande
        ? RecorteTexto.valorCelula
        : (w.linha
              ? RecorteTexto.corpo.copyWith(fontSize: 16)
              : RecorteTexto.valorTexto);

    final campo = TextField(
      controller: w.controller,
      focusNode: _foco,
      autofocus: w.autofocus,
      keyboardType: w.teclado,
      textCapitalization: w.capitalizacao,
      textInputAction: w.acaoTeclado,
      minLines: w.minLinhas,
      maxLines: w.maxLinhas ?? 1,
      inputFormatters: w.formatadores,
      onChanged: w.onChanged,
      onSubmitted: w.onSubmitted,
      style: estiloValor,
      cursorColor: marca.brandLinha,
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        hintText: w.placeholder,
        hintStyle: estiloValor.copyWith(color: RecorteCores.rotulo),
        contentPadding: EdgeInsets.zero,
      ),
    );

    final Widget corpo;
    if (w.linha) {
      corpo = Row(
        children: [
          Text(
            w.rotulo,
            style: RecorteTexto.rotuloLinha.copyWith(color: rotuloEstilo.color),
          ),
          const SizedBox(width: 12),
          Expanded(child: campo),
        ],
      );
    } else {
      corpo = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (w.icone != null) ...[
                IconTheme(
                  data: IconThemeData(color: rotuloEstilo.color),
                  child: w.icone!,
                ),
                const SizedBox(width: 6),
              ],
              Text(w.rotulo, style: rotuloEstilo),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (w.prefixo != null) ...[
                Text(w.prefixo!, style: RecorteTexto.unidade),
                const SizedBox(width: 5),
              ],
              Expanded(child: campo),
              if (w.sufixo != null) ...[
                const SizedBox(width: 5),
                Text(w.sufixo!, style: RecorteTexto.unidade),
              ],
            ],
          ),
        ],
      );
    }

    final alturaMinima =
        w.alturaMinima ??
        (w.linha
            ? RecorteEspaco.alturaCelulaSimples
            : RecorteEspaco.alturaCelulaGrande);

    return Semantics(
      container: true,
      label: w.rotuloSemantico ?? w.rotulo,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _foco.requestFocus,
        child: Container(
          constraints: BoxConstraints(minHeight: alturaMinima),
          padding: w.linha
              ? const EdgeInsets.symmetric(horizontal: 16)
              : RecorteEspaco.paddingCelula,
          alignment: Alignment.centerLeft,
          foregroundDecoration: BoxDecoration(
            border: Border.all(color: corContorno, width: 2),
          ),
          child: corpo,
        ),
      ),
    );
  }
}

/// Moldura compartilhada (seção 3.2): campos relacionados dividem a mesma
/// célula, separados por divisória de 1 px. [mensagens] aparecem abaixo,
/// recuadas 16: os erros têm prioridade sobre a [ajuda].
class MolduraRecorte extends StatelessWidget {
  final List<Widget> filhos;
  final Axis eixo;
  final List<String> erros;
  final String? ajuda;

  const MolduraRecorte({
    super.key,
    required this.filhos,
    this.eixo = Axis.vertical,
    this.erros = const [],
    this.ajuda,
  });

  @override
  Widget build(BuildContext context) {
    final divisoria = eixo == Axis.vertical
        ? const Divider(height: 1, thickness: 1, color: RecorteCores.divisoria)
        : const VerticalDivider(
            width: 1,
            thickness: 1,
            color: RecorteCores.divisoria,
          );
    final itens = <Widget>[];
    for (var i = 0; i < filhos.length; i++) {
      if (i > 0) itens.add(divisoria);
      itens.add(eixo == Axis.vertical ? filhos[i] : Expanded(child: filhos[i]));
    }

    final moldura = DecoratedBox(
      decoration: BoxDecoration(
        color: RecorteCores.superficie,
        border: Border.all(color: RecorteCores.borda),
        borderRadius: BorderRadius.circular(RecorteRaio.celula),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(RecorteRaio.celula - 1),
        child: eixo == Axis.vertical
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: itens,
              )
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: itens,
                ),
              ),
      ),
    );

    final mensagens = [
      for (final e in erros) Text(e, style: RecorteTexto.erroCampo),
      if (erros.isEmpty && ajuda != null)
        Text(ajuda!, style: RecorteTexto.ajudaCampo),
    ];
    if (mensagens.isEmpty) return moldura;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        moldura,
        for (final m in mensagens)
          Padding(padding: const EdgeInsets.fromLTRB(16, 4, 4, 0), child: m),
      ],
    );
  }
}

/// Célula de campo avulsa: [CampoInterno] dentro da sua própria moldura. Com
/// [validator], participa do `Form` mais próximo e mostra a mensagem abaixo
/// da célula.
class CampoRecorte extends StatelessWidget {
  final String rotulo;
  final Widget? icone;
  final TextEditingController controller;
  final TextInputType? teclado;
  final String? prefixo;
  final String? sufixo;
  final String? placeholder;
  final String? erro;
  final String? ajuda;
  final bool grande;
  final int? minLinhas;
  final int? maxLinhas;
  final double? alturaMinima;
  final TextCapitalization capitalizacao;
  final TextInputAction? acaoTeclado;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final FormFieldValidator<String>? validator;

  const CampoRecorte({
    super.key,
    required this.rotulo,
    required this.controller,
    this.icone,
    this.teclado,
    this.prefixo,
    this.sufixo,
    this.placeholder,
    this.erro,
    this.ajuda,
    this.grande = true,
    this.minLinhas,
    this.maxLinhas,
    this.alturaMinima,
    this.capitalizacao = TextCapitalization.none,
    this.acaoTeclado,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
    this.validator,
  });

  Widget _construir(String? mensagem, ValueChanged<String>? aoMudar) {
    return MolduraRecorte(
      erros: [?mensagem],
      ajuda: ajuda,
      filhos: [
        CampoInterno(
          rotulo: rotulo,
          icone: icone,
          controller: controller,
          teclado: teclado,
          prefixo: prefixo,
          sufixo: sufixo,
          placeholder: placeholder,
          erro: mensagem != null,
          grande: grande,
          alturaMinima: alturaMinima,
          minLinhas: minLinhas,
          maxLinhas: maxLinhas,
          capitalizacao: capitalizacao,
          acaoTeclado: acaoTeclado,
          onChanged: aoMudar,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (validator == null) return _construir(erro, onChanged);
    return FormField<String>(
      initialValue: controller.text,
      validator: validator,
      builder: (estado) => _construir(estado.errorText ?? erro, (v) {
        estado.didChange(v);
        onChanged?.call(v);
      }),
    );
  }
}
