import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Kun/tun mavzulari — Apple iOS (HIG) uslubida.
///
/// Asosiy belgilar: Inter (SF Pro'ga eng yaqin) shrift manfiy tracking bilan,
/// soyasiz tekis oq kartalar, hairline ajratkichlar, iOS tizim ranglari,
/// Cupertino sahifa o'tishlari va "bounce" skroll. Bosish maydonlari katta
/// qoladi — yoshi katta foydalanuvchilar uchun.
abstract final class AppTheme {
  static const double radius = 18;
  static const double radiusSmall = 12;

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors c, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: c.brand,
      onPrimary: Colors.white,
      primaryContainer: c.brandSoft,
      onPrimaryContainer: c.onBrandSoft,
      secondary: c.info,
      onSecondary: Colors.white,
      error: c.danger,
      onError: Colors.white,
      errorContainer: c.dangerSoft,
      onErrorContainer: c.danger,
      surface: c.surface,
      onSurface: c.text,
      surfaceContainerHighest: c.surfaceAlt,
      onSurfaceVariant: c.textMuted,
      outline: c.outline,
      outlineVariant: c.outline,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: isDark ? AppPalette.surfaceLight : AppPalette.surfaceDark,
      onInverseSurface: isDark ? AppPalette.textLight : AppPalette.textDark,
      inversePrimary: c.brandSoft,
    );

    final textTheme = _textTheme(c);

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: c.background,
      textTheme: textTheme,
      extensions: [c],
      splashFactory: NoSplash.splashFactory,
      highlightColor: c.text.withValues(alpha: 0.06),

      // iOS xatti-harakati: "bounce" skroll, chetdan surib orqaga qaytish,
      // iOS uslubidagi matn tanlash.
      platform: TargetPlatform.iOS,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          backgroundColor: c.brand,
          foregroundColor: Colors.white,
          disabledBackgroundColor: c.surfaceAlt,
          disabledForegroundColor: c.textMuted,
          elevation: 0,
          textStyle: textTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: c.brand,
          backgroundColor: isDark ? c.surface : Colors.transparent,
          side: BorderSide(color: c.brand.withValues(alpha: 0.35), width: 1.2),
          textStyle: textTheme.titleMedium,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.brand,
          textStyle: textTheme.titleSmall,
        ),
      ),

      // iOS uslubidagi maydonlar: kulrang to'ldirilgan, chegarasiz,
      // fokus paytida brend halqa.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyLarge!.copyWith(color: c.textMuted),
        floatingLabelStyle: textTheme.labelLarge!.copyWith(color: c.brand),
        labelStyle: textTheme.bodyLarge!.copyWith(color: c.textMuted),
        prefixIconColor: c.textMuted,
        suffixIconColor: c.textMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: c.brand, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: c.danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
          borderSide: BorderSide(color: c.danger, width: 1.8),
        ),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceAlt,
        selectedColor: c.brand,
        labelStyle: textTheme.labelLarge,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      ),

      // iOS hairline ajratkich.
      dividerTheme: DividerThemeData(color: c.outline, thickness: 0.7),

      // Sheet fon bermaydi — har bir sheet GlassSheet (blur + shaffof sirt)
      // bilan o'raladi, tutqich ham o'shaniki.
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: false,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge!.copyWith(color: c.textMuted),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? c.surfaceAlt : const Color(0xEE1C1C1E),
        contentTextStyle: textTheme.bodyMedium!.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // iOS tumbleri: yoqilganda yashil (#34C759).
      switchTheme: SwitchThemeData(
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? c.success
              : (isDark ? c.surfaceAlt : const Color(0xFFE9E9EB)),
        ),
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        thumbIcon: const WidgetStatePropertyAll(null),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: c.textMuted,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodyMedium!.copyWith(color: c.textMuted),
      ),

      tabBarTheme: TabBarThemeData(
        labelStyle: textTheme.titleSmall,
        unselectedLabelStyle: textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.w500,
        ),
        labelColor: c.text,
        unselectedLabelColor: c.textMuted,
        indicatorColor: c.brand,
        dividerColor: Colors.transparent,
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.brand,
        linearTrackColor: c.surfaceAlt,
        circularTrackColor: c.surfaceAlt,
      ),
    );
  }

  /// iOS (SF Pro) uslubidagi tipografiya: manfiy tracking, muvozanatli
  /// og'irliklar (katta sarlavhalar bold, matn regular/medium).
  static TextTheme _textTheme(AppColors c) {
    TextStyle s(
      double size,
      FontWeight weight, {
      double? height,
      double spacing = 0,
    }) => TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: c.text,
      height: height ?? 1.3,
      letterSpacing: spacing,
      fontFamily: 'Inter',
    );

    return TextTheme(
      displayLarge: s(40, FontWeight.w700, height: 1.12, spacing: -0.8),
      displayMedium: s(34, FontWeight.w700, height: 1.15, spacing: -0.7),
      displaySmall: s(28, FontWeight.w700, height: 1.2, spacing: -0.6),
      headlineMedium: s(26, FontWeight.w700, height: 1.2, spacing: -0.5),
      headlineSmall: s(22, FontWeight.w700, height: 1.25, spacing: -0.45),
      titleLarge: s(19, FontWeight.w700, spacing: -0.35),
      titleMedium: s(17, FontWeight.w600, spacing: -0.3),
      titleSmall: s(15.5, FontWeight.w600, spacing: -0.2),
      bodyLarge: s(16, FontWeight.w400, height: 1.45, spacing: -0.2),
      bodyMedium: s(14.5, FontWeight.w400, height: 1.45, spacing: -0.1),
      bodySmall: s(13, FontWeight.w400, height: 1.4),
      labelLarge: s(14.5, FontWeight.w600, spacing: -0.1),
      labelMedium: s(13, FontWeight.w500),
      labelSmall: s(11.5, FontWeight.w500),
    );
  }
}
