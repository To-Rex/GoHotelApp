import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../cubit/auth_cubit.dart';

/// Mehmonxona xizmati to'xtatilganda ko'rinadigan ekran.
///
/// Ilgari bu holat hech qanday ko'rinishga ega emasdi: panel obyektni
/// to'xtatgach xodim kiraverardi, lekin har bir so'rov 403 bilan qaytar,
/// ekranlar esa bo'sh qolib ilova buzilgandek ko'rinardi.
///
/// Sessiya TOZALANMAYDI — xizmat tiklangach "Qayta tekshirish" ishni
/// o'sha joyidan davom ettiradi.
class ServiceStoppedPage extends StatelessWidget {
  const ServiceStoppedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (a, b) => a.error != b.error || a.errorCode != b.errorCode,
      builder: (context, state) {
        // Serverning matni mehmonxona nomini ham o'z ichiga oladi —
        // umumiy izohdan ko'ra aniqroq
        final detail = state.error;

        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: c.warningSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pause_circle_outline_rounded,
                        size: 44,
                        color: c.warning,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    l10n.serviceStoppedTitle,
                    style: context.textStyles.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.serviceStoppedBody,
                    style: context.textStyles.bodyLarge!.copyWith(
                      color: c.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (detail != null && detail.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.warningSoft,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        detail,
                        style: context.textStyles.bodyMedium!.copyWith(
                          color: c.warning,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    l10n.serviceStoppedHint,
                    style: context.textStyles.bodySmall!.copyWith(
                      color: c.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: () => context.read<AuthCubit>().retryService(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.serviceStoppedRetry),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => context.read<AuthCubit>().logout(),
                    child: Text(l10n.logout),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
