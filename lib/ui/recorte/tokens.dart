import 'package:flutter/material.dart';

/// Cores fixas do Recorte (seção 2.1 do recorte.md). Só as cores que não
/// dependem da marca; a marca e suas derivadas ficam em [RecorteMarca].
abstract final class RecorteCores {
  static const liner = Color(0xFFEEF0EC);
  static const superficie = Color(0xFFFFFFFF);
  static const trilho = Color(0xFFE2E5DF);
  static const borda = Color(0xFFCDD0C9);
  static const divisoria = Color(0xFFE4E6E1);
  static const grafite = Color(0xFF17181B);
  static const textoSecundario = Color(0xFF4A4E55);
  static const rotulo = Color(0xFF5A5E66);
  static const contornoNeutro = Color(0xFF8A8E95);
  static const desativadoTexto = Color(0xFF8A8E95);
  static const desativadoBorda = Color(0xFFD5D8D1);
  static const pontilhado = Color(0xFFB4B8B0);
  static const grade = Color(0xFFDDE0D8);
  static const erro = Color(0xFFB3261E);
  static const avisoFundo = Color(0xFFFFF1B8);
  static const avisoBorda = Color(0xFF6B5100);
  static const avisoTexto = Color(0xFF3D2E00);
  static const alertaEscuro = Color(0xFFF2C94C);
  static const okEscuro = Color(0xFF9BE0BC);

  /// `grafite` a 48%: fundo atrás de diálogos.
  static const scrim = Color(0x7A17181B);
}

/// Espaços (seção 2.4).
abstract final class RecorteEspaco {
  static const margemTela = 16.0;
  static const entreBlocos = 14.0;
  static const entreBotoes = 8.0;
  static const alturaBarra = 64.0;
  static const alturaBotaoPrincipal = 52.0;
  static const alturaBotaoTexto = 48.0;
  static const alturaBotaoDialogo = 44.0;
  static const alturaBotaoFlutuante = 56.0;
  static const alturaItemLista = 66.0;
  static const alturaCelulaGrande = 76.0;
  static const alturaCelulaSimples = 58.0;
  static const alturaCelulaLinha = 66.0;
  static const paddingCelula = EdgeInsets.symmetric(
    vertical: 10,
    horizontal: 16,
  );
}

/// Raios (seção 2.4).
abstract final class RecorteRaio {
  static const celula = 12.0;
  static const adesivo = 14.0;
  static const segmento = 9.0;
  static const trilho = 12.0;
  static const dialogo = 20.0;
  static const chip = 10.0;
  static const menu = 14.0;
  static const menuItem = 10.0;
}

/// Sombras (seção 2.4), todas na cor `grafite`.
abstract final class RecorteSombra {
  static BoxShadow _s(double y, double blur, double opacidade) => BoxShadow(
    color: RecorteCores.grafite.withValues(alpha: opacidade),
    offset: Offset(0, y),
    blurRadius: blur,
  );

  static List<BoxShadow> get botaoFlutuante => [_s(6, 14, 0.22)];
  static List<BoxShadow> get adesivo => [_s(6, 14, 0.18)];
  static List<BoxShadow> get segmento => [_s(1, 3, 0.20)];
  static List<BoxShadow> get menu => [_s(10, 28, 0.20)];
  static List<BoxShadow> get dialogo => [_s(18, 40, 0.30)];
  static List<BoxShadow> get avisoRodape => [_s(6, 16, 0.25)];
}
