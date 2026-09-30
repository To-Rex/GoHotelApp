import 'package:flutter/material.dart';

/// iOS (Apple HIG) tizim ranglariga moslangan palitra.
///
/// Brend ko'ki (#2563EB, GoHotel favicon) tint sifatida saqlanadi, qolgan
/// semantik ranglar — iOS system colors: yashil #34C759, qizil #FF3B30,
/// to'q sariq #FF9500 va h.k. Kunduzgi fon — systemGroupedBackground
/// (#F2F2F7), tungi rejim — haqiqiy qora (#000000) ustidagi #1C1C1E kartalar.
abstract final class AppPalette {
  // Brend
  static const brand = Color(0xFF2563EB); // GoHotel favicon ko'ki
  static const brandDark = Color(0xFF1D4ED8);
  static const brandLight = Color(0xFF3B82F6);
  static const brandSoft = Color(0xFFE3EDFF);
  static const brandSoftDark = Color(0xFF16294A);

  // Neytral (light — iOS grouped)
  static const bgLight = Color(0xFFF2F2F7);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceAltLight = Color(0xFFE8E8ED);
  static const outlineLight = Color(0xFFE3E3E8);
  static const textLight = Color(0xFF111114);
  static const textMutedLight = Color(0xFF8E8E93);

  // Neytral (dark — iOS grouped, haqiqiy qora)
  static const bgDark = Color(0xFF000000);
  static const surfaceDark = Color(0xFF1C1C1E);
  static const surfaceAltDark = Color(0xFF2C2C2E);
  static const outlineDark = Color(0xFF38383A);
  static const textDark = Color(0xFFF5F5F7);
  static const textMutedDark = Color(0xFF98989F);

  // Semantik (iOS system colors)
  static const success = Color(0xFF34C759);
  static const successSoft = Color(0xFFE2F7E8);
  static const successSoftDark = Color(0xFF10331C);
  static const warning = Color(0xFFFF9500);
  static const warningSoft = Color(0xFFFFF0DC);
  static const warningSoftDark = Color(0xFF382712);
  static const danger = Color(0xFFFF3B30);
  static const dangerSoft = Color(0xFFFFE5E3);
  static const dangerSoftDark = Color(0xFF3B1715);
  static const info = Color(0xFF32ADE6);
  static const infoSoft = Color(0xFFE0F3FC);
  static const infoSoftDark = Color(0xFF11303F);
  static const violet = Color(0xFFAF52DE);
  static const violetSoft = Color(0xFFF4E7FB);
  static const violetSoftDark = Color(0xFF2E1A3E);
}

/// Mavzuga bog'liq semantik ranglar to'plami.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.outline,
    required this.text,
    required this.textMuted,
    required this.brand,
    required this.brandSoft,
    required this.onBrandSoft,
    required this.success,
    required this.successSoft,
    required this.warning,
    required this.warningSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.violet,
    required this.violetSoft,
  });

  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color outline;
  final Color text;
  final Color textMuted;
  final Color brand;
  final Color brandSoft;
  final Color onBrandSoft;
  final Color success;
  final Color successSoft;
  final Color warning;
  final Color warningSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Color violet;
  final Color violetSoft;

  static const light = AppColors(
    background: AppPalette.bgLight,
    surface: AppPalette.surfaceLight,
    surfaceAlt: AppPalette.surfaceAltLight,
    outline: AppPalette.outlineLight,
    text: AppPalette.textLight,
    textMuted: AppPalette.textMutedLight,
    brand: AppPalette.brand,
    brandSoft: AppPalette.brandSoft,
    onBrandSoft: AppPalette.brandDark,
    success: AppPalette.success,
    successSoft: AppPalette.successSoft,
    warning: AppPalette.warning,
    warningSoft: AppPalette.warningSoft,
    danger: AppPalette.danger,
    dangerSoft: AppPalette.dangerSoft,
    info: AppPalette.info,
    infoSoft: AppPalette.infoSoft,
    violet: AppPalette.violet,
    violetSoft: AppPalette.violetSoft,
  );

  static const dark = AppColors(
    background: AppPalette.bgDark,
    surface: AppPalette.surfaceDark,
    surfaceAlt: AppPalette.surfaceAltDark,
    outline: AppPalette.outlineDark,
    text: AppPalette.textDark,
    textMuted: AppPalette.textMutedDark,
    brand: AppPalette.brandLight,
    brandSoft: AppPalette.brandSoftDark,
    onBrandSoft: Color(0xFF8AB4FF),
    success: Color(0xFF30D158),
    successSoft: AppPalette.successSoftDark,
    warning: Color(0xFFFF9F0A),
    warningSoft: AppPalette.warningSoftDark,
    danger: Color(0xFFFF453A),
    dangerSoft: AppPalette.dangerSoftDark,
    info: Color(0xFF64D2FF),
    infoSoft: AppPalette.infoSoftDark,
    violet: Color(0xFFBF5AF2),
    violetSoft: AppPalette.violetSoftDark,
  );

  @override
  AppColors copyWith() => this;

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceAlt: l(surfaceAlt, other.surfaceAlt),
      outline: l(outline, other.outline),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      brand: l(brand, other.brand),
      brandSoft: l(brandSoft, other.brandSoft),
      onBrandSoft: l(onBrandSoft, other.onBrandSoft),
      success: l(success, other.success),
      successSoft: l(successSoft, other.successSoft),
      warning: l(warning, other.warning),
      warningSoft: l(warningSoft, other.warningSoft),
      danger: l(danger, other.danger),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      info: l(info, other.info),
      infoSoft: l(infoSoft, other.infoSoft),
      violet: l(violet, other.violet),
      violetSoft: l(violetSoft, other.violetSoft),
    );
  }
}
