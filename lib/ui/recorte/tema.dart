import 'package:flutter/material.dart';

import 'marca.dart';
import 'tipografia.dart';
import 'tokens.dart';

/// Tema do app com a identidade "Recorte". Tudo que depende da marca lê
/// [RecorteMarca] da extensão; o resto vem de [RecorteCores].
ThemeData construirTema({Color brand = corMarcaPadrao}) {
  final marca = RecorteMarca.de(brand);
  final esquema = ColorScheme.fromSeed(seedColor: brand).copyWith(
    primary: RecorteCores.grafite,
    onPrimary: Colors.white,
    secondary: RecorteCores.textoSecundario,
    onSecondary: Colors.white,
    surface: RecorteCores.superficie,
    onSurface: RecorteCores.grafite,
    onSurfaceVariant: RecorteCores.rotulo,
    outline: RecorteCores.borda,
    outlineVariant: RecorteCores.divisoria,
    error: RecorteCores.erro,
    onError: Colors.white,
    surfaceTint: Colors.transparent,
    scrim: RecorteCores.scrim,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    fontFamily: familiaCorpo,
    scaffoldBackgroundColor: RecorteCores.liner,
    canvasColor: RecorteCores.superficie,
    splashFactory: InkSparkle.splashFactory,
  );

  final textos = base.textTheme
      .apply(
        fontFamily: familiaCorpo,
        bodyColor: RecorteCores.grafite,
        displayColor: RecorteCores.grafite,
      )
      .copyWith(
        titleLarge: RecorteTexto.tituloBarra,
        titleMedium: RecorteTexto.tituloItem,
        titleSmall: RecorteTexto.tituloSecao,
        bodyLarge: RecorteTexto.corpo,
        bodyMedium: RecorteTexto.corpo,
        bodySmall: RecorteTexto.metadado,
        labelLarge: RecorteTexto.botao,
        labelMedium: RecorteTexto.rotuloCelula,
        labelSmall: RecorteTexto.ajudaCampo,
      );

  const forma12 = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(RecorteRaio.celula)),
  );

  ButtonStyle botao({
    required Color fundo,
    required Color texto,
    required Color fundoDesativado,
    required Color textoDesativado,
    BorderSide? borda,
    BorderSide? bordaDesativada,
    double altura = RecorteEspaco.alturaBotaoPrincipal,
    TextStyle? estilo,
  }) => ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(64, altura)),
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20)),
    elevation: const WidgetStatePropertyAll(0),
    shape: const WidgetStatePropertyAll(forma12),
    textStyle: WidgetStatePropertyAll(estilo ?? RecorteTexto.botao),
    iconSize: const WidgetStatePropertyAll(22),
    backgroundColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled) ? fundoDesativado : fundo,
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.disabled) ? textoDesativado : texto,
    ),
    side: borda == null
        ? null
        : WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.disabled) ? bordaDesativada : borda,
          ),
  );

  return base.copyWith(
    extensions: [marca],
    textTheme: textos,
    primaryTextTheme: textos,
    dividerTheme: const DividerThemeData(
      color: RecorteCores.divisoria,
      thickness: 1,
      space: 1,
    ),
    appBarTheme: AppBarTheme(
      toolbarHeight: RecorteEspaco.alturaBarra,
      backgroundColor: WidgetStateColor.resolveWith(
        (s) => s.contains(WidgetState.scrolledUnder)
            ? RecorteCores.trilho
            : Colors.transparent,
      ),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      foregroundColor: RecorteCores.grafite,
      titleTextStyle: RecorteTexto.tituloBarra,
      iconTheme: const IconThemeData(color: RecorteCores.grafite, size: 24),
      actionsIconTheme: const IconThemeData(
        color: RecorteCores.grafite,
        size: 24,
      ),
      actionsPadding: const EdgeInsets.only(right: 4),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        fixedSize: const WidgetStatePropertyAll(Size(48, 48)),
        shape: const WidgetStatePropertyAll(forma12),
        foregroundColor: const WidgetStatePropertyAll(RecorteCores.grafite),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: botao(
        fundo: RecorteCores.grafite,
        texto: Colors.white,
        fundoDesativado: RecorteCores.trilho,
        textoDesativado: RecorteCores.desativadoTexto,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: botao(
        fundo: RecorteCores.superficie,
        texto: RecorteCores.grafite,
        fundoDesativado: RecorteCores.superficie,
        textoDesativado: RecorteCores.desativadoTexto,
        borda: const BorderSide(color: RecorteCores.grafite),
        bordaDesativada: const BorderSide(color: RecorteCores.desativadoBorda),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: botao(
        fundo: Colors.transparent,
        texto: RecorteCores.grafite,
        fundoDesativado: Colors.transparent,
        textoDesativado: RecorteCores.desativadoTexto,
        altura: RecorteEspaco.alturaBotaoTexto,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: RecorteCores.superficie,
      surfaceTintColor: Colors.transparent,
      shadowColor: RecorteCores.grafite,
      elevation: 24,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(RecorteRaio.dialogo)),
      ),
      titleTextStyle: RecorteTexto.tituloDialogo,
      contentTextStyle: RecorteTexto.corpo.copyWith(
        color: RecorteCores.textoSecundario,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: RecorteCores.grafite,
      contentTextStyle: RecorteTexto.avisoRodape,
      elevation: 6,
      shape: forma12,
      insetPadding: const EdgeInsets.all(16),
      actionTextColor: Colors.white,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: RecorteCores.superficie,
      surfaceTintColor: Colors.transparent,
      shadowColor: RecorteCores.grafite,
      elevation: 8,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(RecorteRaio.menu)),
        side: BorderSide(color: RecorteCores.borda),
      ),
      textStyle: RecorteTexto.itemMenu,
      menuPadding: const EdgeInsets.all(6),
      iconColor: RecorteCores.grafite,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: RecorteCores.superficie,
      side: const BorderSide(color: RecorteCores.borda),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(RecorteRaio.chip)),
      ),
      labelStyle: RecorteTexto.chipVariavel,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pressElevation: 0,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: RecorteCores.grafite,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: RecorteTexto.avisoRodape.copyWith(fontSize: 13),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: marca.brandLinha,
      selectionColor: marca.brandTint,
      selectionHandleColor: marca.brandLinha,
    ),
  );
}
