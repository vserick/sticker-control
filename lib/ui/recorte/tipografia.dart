import 'package:flutter/painting.dart';

import 'tokens.dart';

/// Famílias embutidas como assets (pubspec.yaml). São fontes variáveis: o
/// peso é aplicado pelo eixo `wght` via [FontVariation], além do `fontWeight`.
const familiaTitulos = 'SchibstedGrotesk';
const familiaCorpo = 'InstrumentSans';

const _tabular = [FontFeature.tabularFigures()];

TextStyle _estilo(
  String familia,
  double tamanho,
  double altura,
  int peso, {
  double espacoEm = 0,
  Color cor = RecorteCores.grafite,
  bool tabular = false,
}) => TextStyle(
  fontFamily: familia,
  fontSize: tamanho,
  height: altura / tamanho,
  fontWeight: FontWeight.values[peso ~/ 100 - 1],
  fontVariations: [FontVariation.weight(peso.toDouble())],
  letterSpacing: espacoEm * tamanho,
  color: cor,
  fontFeatures: tabular ? _tabular : null,
);

/// Papéis tipográficos da seção 2.3 do recorte.md.
abstract final class RecorteTexto {
  static TextStyle _titulo(
    double t,
    double a,
    int p, {
    double em = 0,
    Color cor = RecorteCores.grafite,
    bool tabular = false,
  }) => _estilo(
    familiaTitulos,
    t,
    a,
    p,
    espacoEm: em,
    cor: cor,
    tabular: tabular,
  );

  static TextStyle _corpoBase(
    double t,
    double a,
    int p, {
    Color cor = RecorteCores.grafite,
    bool tabular = false,
  }) => _estilo(familiaCorpo, t, a, p, cor: cor, tabular: tabular);

  static final tituloInicio = _titulo(36, 40, 800, em: -0.035);
  static final tituloBarra = _titulo(21, 28, 800, em: -0.025);
  static final wordmark = _titulo(20, 26, 800, em: -0.03);
  static final nomeEmpresaTopo = _titulo(18, 24, 700, em: -0.02);
  static final precoFinal = _titulo(38, 46, 800, em: -0.035, tabular: true);
  static final valorCelula = _titulo(26, 34, 600, tabular: true);
  static final precoLista = _titulo(17, 22, 700, tabular: true);
  static final valorResultado = _titulo(14, 20, 600, tabular: true);
  static final tituloCartao = _titulo(19, 24, 700, em: -0.015);
  static final tituloDialogo = _titulo(22, 28, 800, em: -0.03);
  static final tituloEstado = _titulo(18, 24, 700);
  static final botao = _titulo(16, 20, 700);
  static final botaoDialogo = _titulo(15, 20, 700);
  static final botaoFlutuante = _titulo(16, 20, 700);
  static final tituloSecao = _titulo(15, 20, 700);
  static final chipVariavel = _titulo(14, 20, 600);
  static final rotuloPrecoMaterial = _titulo(
    14,
    20,
    600,
    cor: RecorteCores.rotulo,
    tabular: true,
  );
  static final rotuloPrecoFinal = _corpoBase(13, 18, 700);

  static final tituloItem = _corpoBase(16, 21, 600);
  static final corpo = _corpoBase(15, 22, 400);
  static final corpoSecundario = _corpoBase(
    14,
    20,
    400,
    cor: RecorteCores.textoSecundario,
  );
  static final corpoSecundario21 = _corpoBase(
    14,
    21,
    400,
    cor: RecorteCores.textoSecundario,
  );
  static final metadado = _corpoBase(
    13,
    17,
    400,
    cor: RecorteCores.rotulo,
    tabular: true,
  );
  static final rotuloCelula = _corpoBase(12, 16, 600, cor: RecorteCores.rotulo);
  static final ajudaCampo = _corpoBase(12, 16, 400, cor: RecorteCores.rotulo);
  static final erroCampo = _corpoBase(12, 16, 600, cor: RecorteCores.erro);
  static final unidade = _corpoBase(15, 20, 600, cor: RecorteCores.rotulo);
  static final rotuloLinha = _corpoBase(14, 20, 600, cor: RecorteCores.rotulo);
  static final valorLinha = _corpoBase(15, 20, 600, tabular: true);
  static final valorTexto = _corpoBase(17, 22, 400);
  static final itemMenu = _corpoBase(15, 20, 600);
  static final avisoRodape = _corpoBase(
    14,
    20,
    400,
    cor: const Color(0xFFFFFFFF),
  );
  static final aviso = _corpoBase(14, 20, 400, cor: RecorteCores.avisoTexto);
}
