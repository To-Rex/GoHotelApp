import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/presentation/cubit/auth_cubit.dart';
import '../management/home/management_shell.dart';

/// Administrator bo'limi — boshqaruv qobig'i to'liq ruxsatlar bilan:
/// puls, xonalar xaritasi, jamoa (smenalarni majburiy yopish, vazifa
/// biriktirish), murojaatlar, e'lon yuborish.
///
/// Qobiq `features/management` da — menejer bilan bitta, farq
/// [ManagementAccess] orqali.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    if (user == null) return const SizedBox.shrink();
    return ManagementShell(user: user);
  }
}
