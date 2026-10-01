import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/presentation/cubit/auth_cubit.dart';
import '../management/home/management_shell.dart';

/// Menejer bo'limi — boshqaruv qobig'i, amallar ruxsat kodlariga qarab:
/// smenani majburiy yopish (`shift.force_close`), vazifa biriktirish
/// (`housekeeping.task.assign`), xona holati (`room.update`) va h.k.
/// E'lon yuborish ko'rinmaydi — server uni faqat adminga beradi.
class ManagerHomePage extends StatelessWidget {
  const ManagerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit cubit) => cubit.state.user);
    if (user == null) return const SizedBox.shrink();
    return ManagementShell(user: user);
  }
}
