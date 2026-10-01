import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app/theme/app_theme.dart';
import '../../core/extensions/context_x.dart';
import '../auth/presentation/cubit/auth_cubit.dart';

/// Sozlovchi (CONFIGURATOR) — mehmonxonaga bog'lanmagan hisob: u istalgan
/// mehmonxona va filialni VEB-ilovada tanlab, uni sozlaydi.
///
/// Mobil ilovada mehmonxona tanlash yo'q va u mehmonxona xodimlari uchun —
/// mehmonxonasiz hisob bilan har bir bo'lim "ruxsat yo'q" bo'lib buzilgandek
/// ko'rinardi. Shuning uchun sozlovchiga qayerda ishlashini aytadigan
/// sodda sahifa va chiqish tugmasi ko'rsatiladi.
class ConfiguratorHomePage extends StatelessWidget {
  const ConfiguratorHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final user = context.select((AuthCubit cubit) => cubit.state.user);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    const SizedBox(height: 24),
                    Center(
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: c.violetSoft,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 42,
                          color: c.violet,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      l10n.configuratorTitle,
                      style: context.textStyles.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    if (user != null && user.fullName.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${user.fullName} · ${l10n.roleConfigurator}',
                        style: context.textStyles.titleSmall!.copyWith(
                          color: c.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.computer_rounded, color: c.violet),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.configuratorBody,
                              style: context.textStyles.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.configuratorHint,
                      style: context.textStyles.bodySmall!.copyWith(
                        color: c.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const Spacer(),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.read<AuthCubit>().logout(),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(l10n.logout),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
