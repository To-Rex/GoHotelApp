import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/widgets/role_scaffold.dart';

/// Texnik xizmat (usta) bo'limi.
///
/// Kelgusida: ta'mirlash vazifalari, muammolar ro'yxati. Hozircha umumiy
/// skelet (chat + bildirishnoma + profil).
class MaintenanceHomePage extends StatelessWidget {
  const MaintenanceHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      roleLabel: (context) => context.l10n.roleMaintenance,
      roleIcon: Icons.handyman_outlined,
    );
  }
}
