import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/widgets/role_scaffold.dart';

/// Menejer bo'limi.
///
/// Kelgusida: vazifalarni yaratish/taqsimlash, farroshlar nazorati,
/// hisobotlar. Hozircha umumiy skelet (chat + bildirishnoma + profil).
class ManagerHomePage extends StatelessWidget {
  const ManagerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      roleLabel: (context) => context.l10n.roleManager,
      roleIcon: Icons.business_center_outlined,
    );
  }
}
