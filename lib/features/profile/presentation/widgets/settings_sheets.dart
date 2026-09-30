import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/settings/settings_cubit.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/glass.dart';

/// Til nomlari — har biri O'Z tilida yoziladi (foydalanuvchi adashmasligi uchun).
const supportedLanguages = [
  (code: 'uz', label: "O'zbekcha", flag: '🇺🇿'),
  (code: 'ru', label: 'Русский', flag: '🇷🇺'),
  (code: 'en', label: 'English', flag: '🇬🇧'),
];

String localeLabel(Locale? locale) {
  final code = locale?.languageCode ?? 'uz';
  return supportedLanguages
      .firstWhere(
        (lang) => lang.code == code,
        orElse: () => supportedLanguages.first,
      )
      .label;
}

/// Til tanlash oynasi.
Future<void> showLanguageSheet(BuildContext context) {
  final cubit = context.read<SettingsCubit>();
  return showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      final current = cubit.state.locale?.languageCode ?? 'uz';
      final c = sheetContext.colors;
      return GlassSheet(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  sheetContext.l10n.languageLabel,
                  style: sheetContext.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                for (final lang in supportedLanguages)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionTile(
                      selected: current == lang.code,
                      leading: Text(
                        lang.flag,
                        style: const TextStyle(fontSize: 26),
                      ),
                      label: lang.label,
                      onTap: () {
                        cubit.setLocale(Locale(lang.code));
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  'GoHotel Staff',
                  textAlign: TextAlign.center,
                  style: sheetContext.textStyles.labelSmall!.copyWith(
                    color: c.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Mavzu tanlash oynasi: kunduzgi / tungi / tizim.
Future<void> showThemeSheet(BuildContext context) {
  final cubit = context.read<SettingsCubit>();
  return showModalBottomSheet(
    context: context,
    builder: (sheetContext) {
      final l10n = sheetContext.l10n;
      final current = cubit.state.themeMode;
      final options = [
        (
          mode: ThemeMode.light,
          label: l10n.themeLight,
          icon: Icons.light_mode_rounded,
        ),
        (
          mode: ThemeMode.dark,
          label: l10n.themeDark,
          icon: Icons.dark_mode_rounded,
        ),
        (
          mode: ThemeMode.system,
          label: l10n.themeSystem,
          icon: Icons.settings_suggest_rounded,
        ),
      ];
      return GlassSheet(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.themeLabel,
                  style: sheetContext.textStyles.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                for (final option in options)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OptionTile(
                      selected: current == option.mode,
                      leading: Icon(
                        option.icon,
                        size: 26,
                        color: sheetContext.colors.textMuted,
                      ),
                      label: option.label,
                      onTap: () {
                        cubit.setThemeMode(option.mode);
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.selected,
    required this.leading,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final Widget leading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: selected ? c.brandSoft : c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? c.brand : c.outline, width: 1.4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 14),
              Expanded(
                child: Text(label, style: context.textStyles.titleSmall),
              ),
              if (selected) Icon(Icons.check_circle_rounded, color: c.brand),
            ],
          ),
        ),
      ),
    );
  }
}
