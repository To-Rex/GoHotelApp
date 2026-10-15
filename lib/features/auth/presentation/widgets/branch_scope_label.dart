import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../cubit/auth_cubit.dart';
import 'branch_switch_sheet.dart';

/// Joriy filial qatori — sahifa sarlavhasi ostida (web'dagi navbar
/// ko'rsatkichi kabi).
///
/// Filiallar to'liq ajratilgan: har ekran joriy filial ma'lumotlarini
/// ko'rsatadi, shuning uchun "qaysi filialda ishlayapman" doim ko'rinib
/// turishi kerak. **Administrator** qatorni bosib filialni almashtiradi
/// (xuddi web'dagi kabi); oddiy xodim filialga qat'iy bog'langan — u uchun
/// faqat ma'lumot, bosilmaydi. Filial nomi bo'lmasa (eski javob) qator
/// umuman chiqmaydi — avvalgi ko'rinish saqlanadi.
class BranchScopeLabel extends StatelessWidget {
  const BranchScopeLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit a) => a.state.user);
    final branch = user?.branchName;
    if (branch == null || branch.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final c = context.colors;
    final canSwitch = user!.canSwitchBranch;

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(CupertinoIcons.location_fill, size: 11, color: c.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            branch,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.labelSmall!.copyWith(
              color: c.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (canSwitch) ...[
          const SizedBox(width: 2),
          Icon(CupertinoIcons.chevron_down, size: 10, color: c.textMuted),
        ],
      ],
    );

    if (!canSwitch) {
      // Xodim — faqat ma'lumot
      return Padding(padding: const EdgeInsets.only(top: 2), child: row);
    }

    // Administrator — bosiladi: filialni almashtirish oynasi
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Semantics(
        button: true,
        label: l10n.branchSwitchTitle,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => showBranchSwitchSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              border: Border.all(color: c.outline),
              borderRadius: BorderRadius.circular(100),
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}
