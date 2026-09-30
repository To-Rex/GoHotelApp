import 'package:flutter/material.dart';

import '../../core/extensions/context_x.dart';
import '../../core/widgets/role_scaffold.dart';

/// Administrator bo'limi.
///
/// Kelgusida shu papkada admin uchun to'liq modul quriladi (xodimlar,
/// qurilmalarni tasdiqlash, sozlamalar va h.k.). Hozircha umumiy skelet:
/// chat, bildirishnoma va profil ishlaydi.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleScaffold(
      roleLabel: (context) => context.l10n.roleAdmin,
      roleIcon: Icons.admin_panel_settings_outlined,
    );
  }
}
