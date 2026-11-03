import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../cubit/auth_cubit.dart';
import 'branch_switch_sheet.dart';

/// Administrator bosh sahifasining sarlavhasi: JORIY FILIAL — katta nom,
/// yonida kichik ochiluvchi belgi; tepasida salom va ism bir qatorda.
///
/// Filiallar to'liq ajratilgan: har ekran joriy filial ma'lumotlarini
/// ko'rsatadi, shuning uchun administrator uchun "qayerdaman" — sahifaning
/// asosiy sarlavhasi. Bosilsa filialni almashtirish oynasi
/// ([showBranchSwitchSheet]) ochiladi. Alohida chip yoki qator yo'q —
/// sarlavha avvalgidek ikki qatorli (app bar balandligi o'zgarmaydi).
///
/// Filial nomi bo'lmasa (eski javob) shell oddiy sarlavhani (salom, ism)
/// ko'rsatadi — bu vidjet chaqirilmaydi.
class BranchTitle extends StatelessWidget {
  const BranchTitle({super.key, required this.greeting});

  /// Yuqori qator: "Xayrli kun, Anna".
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final branch = context.select((AuthCubit a) => a.state.user?.branchName ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          greeting,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
        ),
        Semantics(
          button: true,
          label: '$branch · ${l10n.branchSwitchTitle}',
          excludeSemantics: true,
          child: InkWell(
            onTap: () => showBranchSwitchSheet(context),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              // Chap tomonda bo'shliq yo'q — sarlavha avvalgidek chapga tekis
              padding: const EdgeInsets.fromLTRB(0, 1, 6, 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      branch,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.headlineSmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Ochiluvchi belgi — brend rangli kichik doira: bu sarlavha
                  // bosiladi, boshqa filialga o'tish mumkin
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: c.brandSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.chevron_down,
                      size: 12,
                      color: c.brand,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
