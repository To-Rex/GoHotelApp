import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/brand_mark.dart';

/// Biometrik qulf ekrani — "Tez kirish" yoqilgan bo'lsa ilova shu yerdan
/// ochiladi.
class LockedPage extends StatefulWidget {
  const LockedPage({super.key});

  @override
  State<LockedPage> createState() => _LockedPageState();
}

class _LockedPageState extends State<LockedPage> {
  @override
  void initState() {
    super.initState();
    // Ekran ochilishi bilan darhol biometrik so'rov ko'rsatiladi.
    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
  }

  void _unlock() {
    context.read<AuthCubit>().unlock(context.l10n.biometricReason);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),
              const BrandMark(size: 84),
              const SizedBox(height: 28),
              Text(l10n.unlockTitle, style: context.textStyles.headlineSmall),
              const SizedBox(height: 8),
              Text(
                l10n.unlockBody,
                style: context.textStyles.bodyLarge!.copyWith(
                  color: c.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: _unlock,
                icon: const Icon(Icons.fingerprint_rounded),
                label: Text(l10n.unlock),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.read<AuthCubit>().switchAccount(),
                child: Text(l10n.loginAsOther),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
