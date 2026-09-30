import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/widgets/role_scaffold.dart';

/// Rol aniqlanmagan xodimlar uchun zaxira bo'lim: chat + profil baribir
/// ishlaydi, xodim tizimdan chetda qolmaydi.
class StaffHomePage extends StatelessWidget {
  const StaffHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      roleLabel: (context) => context.l10n.roleStaff,
      roleIcon: Icons.work_outline_rounded,
    );
  }
}
