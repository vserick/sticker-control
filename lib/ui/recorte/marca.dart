import 'package:flutter/material.dart';

import 'cor_marca.dart';
import 'tokens.dart';

/// Cor padrão da marca. É o único lugar onde o valor aparece: no futuro virá
/// da configuração da empresa (seção 7 do recorte.md).
const corMarcaPadrao = Color(0xFFC2185B);

/// A cor da marca e as derivadas da seção 2.2, calculadas a partir dela.
@immutable
class RecorteMarca extends ThemeExtension<RecorteMarca> {
  /// Cor da marca.
  final Color brand;

  /// Texto e ícone sobre [brand]: branco ou grafite, o de maior contraste.
  final Color onBrand;

  /// [brand] escurecida até 3:1 sobre branco (foco, arco, ficha "Própria").
  final Color brandLinha;

  /// [brand] escurecida até 4,5:1 sobre branco (rótulo da célula em foco).
  final Color brandTexto;

  /// [brand] com 72% de branco (preenchimento da ficha "Própria").
  final Color brandTint;

  /// [brand] com 50% de branco (a "ponta descolando" do adesivo).
  final Color brandDobra;

  const RecorteMarca._({
    required this.brand,
    required this.onBrand,
    required this.brandLinha,
    required this.brandTexto,
    required this.brandTint,
    required this.brandDobra,
  });

  factory RecorteMarca.de(Color brand) {
    const branco = Color(0xFFFFFFFF);
    final sobreBranco = contraste(brand, branco);
    final sobreGrafite = contraste(brand, RecorteCores.grafite);
    return RecorteMarca._(
      brand: brand,
      onBrand: sobreBranco >= sobreGrafite ? branco : RecorteCores.grafite,
      brandLinha: escurecerAteContraste(brand, branco, 3),
      brandTexto: escurecerAteContraste(brand, branco, 4.5),
      brandTint: misturar(brand, branco, 0.72),
      brandDobra: misturar(brand, branco, 0.5),
    );
  }

  @override
  RecorteMarca copyWith({Color? brand}) =>
      brand == null ? this : RecorteMarca.de(brand);

  @override
  RecorteMarca lerp(ThemeExtension<RecorteMarca>? other, double t) {
    if (other is! RecorteMarca) return this;
    return RecorteMarca.de(Color.lerp(brand, other.brand, t)!);
  }
}

final _marcaPadrao = RecorteMarca.de(corMarcaPadrao);

extension RecorteContext on BuildContext {
  /// Marca atual do tema. Sem a extensão no tema (ex.: um `MaterialApp` de
  /// teste sem [construirTema]), vale a cor padrão.
  RecorteMarca get marca =>
      Theme.of(this).extension<RecorteMarca>() ?? _marcaPadrao;
}
