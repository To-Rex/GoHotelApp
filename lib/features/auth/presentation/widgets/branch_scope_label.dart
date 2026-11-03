import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../cubit/auth_cubit.dart';
import 'branch_switch_sheet.dart';

/// Joriy filial — sahifa sarlavhasi ostidagi chip (web'dagi navbar
/// ko'rsatkichi kabi).
///
/// Filiallar to'liq ajratilgan: har ekran joriy filial ma'lumotlarini
/// ko'rsatadi, shuning uchun "qaysi filialda ishlayapman" doim ko'rinib
/// turishi kerak. **Administrator** uchun bu bosiladigan tugma — brend
/// rangida, bino belgisi va pastga strelka bilan, bosilsa filialni
/// almashtirish oynasi ochiladi. Oddiy xodim filialga qat'iy bog'langan —
/// unga xuddi shu shakldagi, lekin neytral rangdagi ko'rsatkich, strelkasiz
/// va bosilmaydi. Filial nomi bo'lmasa (eski javob) chip umuman chiqmaydi.
///
/// Balandligi ~34 (6 bo'shliq + 28 chip): sarlavha ustuniga (salom, ism)
/// qo'shilganda app bar [toolbarHeight] bo'lishi kerak — shell'lar bosh
/// sahifada shuni beradi.
class BranchScopeLabel extends StatelessWidget {
  const BranchScopeLabel({super.key});

  /// Chip bilan birga sarlavha (salom + ism + chip) sig'adigan app bar
  /// balandligi.
  static const double toolbarHeight = 84;

  @override
  Widget build(BuildContext context) {
    final user = context.select((AuthCubit a) => a.state.user);
    final branch = user?.branchName;
    if (branch == null || branch.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final c = context.colors;
    final canSwitch = user!.canSwitchBranch;
    final fg = canSwitch ? c.onBrandSoft : c.textMuted;

    final content = Padding(
      padding: EdgeInsets.fromLTRB(10, 5, canSwitch ? 8 : 10, 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CupertinoIcons.building_2_fill, size: 13, color: fg),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              branch,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.labelMedium!.copyWith(
                color: fg,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
          if (canSwitch) ...[
            const SizedBox(width: 4),
            Icon(CupertinoIcons.chevron_down, size: 11, color: fg),
          ],
        ],
      ),
    );

    final chip = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Material(
        color: canSwitch ? c.brandSoft : c.surfaceAlt,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: canSwitch
            // Administrator — bosiladi: filialni almashtirish oynasi
            ? InkWell(
                onTap: () => showBranchSwitchSheet(context),
                child: content,
              )
            // Xodim — faqat ma'lumot
            : content,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: canSwitch
          ? Semantics(button: true, label: l10n.branchSwitchTitle, child: chip)
          : chip,
    );
  }
}
