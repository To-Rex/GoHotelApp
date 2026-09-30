import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../l10n/gen/app_localizations.dart';

/// Kontekstdan tez-tez kerak bo'ladigan narsalarga qisqa yo'llar.
extension ContextX on BuildContext {
  S get l10n => S.of(this);

  ThemeData get theme => Theme.of(this);

  TextTheme get textStyles => Theme.of(this).textTheme;

  AppColors get colors => Theme.of(this).extension<AppColors>()!;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.danger : null,
        ),
      );
  }
}
