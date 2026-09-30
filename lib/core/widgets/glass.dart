import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../extensions/context_x.dart';

/// iOS 26 "Liquid Glass" uslubidagi shisha elementlar — hammasi bitta joyda,
/// blur/opacity/gradient/border qiymatlari parametrlar orqali boshqariladi.
///
/// - [ProgressiveGlass] — bir tekis blur + chetga qarab so'nuvchi rang
///   qatlami (kontent panel ostiga "erib" kiradi); blursiz, faqat rang
///   rejimi ham bor (`maxSigma: 0`).
/// - [GlassIsland] — suzuvchi yumaloq shisha karta (tab-bar kapsulasi).
/// - [GlassAppBar] — shisha shaffof appbar.
/// - [GlassSheet] — shisha modal sheet.
/// - [GlassScope] — ekrandagi barcha zonalar uchun BITTA fon o'qishi;
///   appbar va pastki panel bor har bir [Scaffold] shu bilan o'raladi.
///
/// NARX — nega aynan shunday: mobil GPU'da har [BackdropFilter] alohida
/// render o'tishi, har fon o'qishi esa butun ekranni teksturaga ko'chirish.
/// Ilgari zona 6 pog'onali "progressiv" blur edi — ekranda har kadrda
/// 13 blur va 3 o'qish, o'rta telefonlarda ilova qotib ishlardi. Endi
/// ekranda 2 blur (appbar + kapsula) va 1 o'qish; progressiv tuyg'u rang
/// gradientidan keladi.
class ProgressiveGlass extends StatelessWidget {
  const ProgressiveGlass({
    super.key,
    required this.strongEdge,
    this.child,
    this.maxSigma = 14,
    this.maxTintAlpha = 0.5,
    this.tint,
  });

  /// Rang qatlami qaysi chetda ENG kuchli: appbar uchun [VerticalDirection.up]
  /// (pastki cheti shaffof, yuqoriga qarab kuchayadi), pastki zona uchun
  /// [VerticalDirection.down] (yuqorisi shaffof, pastga qarab kuchayadi).
  final VerticalDirection strongEdge;

  final Widget? child;

  /// Blur kuchi (butun zona bo'ylab bir tekis). `0` — blur yo'q, faqat rang
  /// qatlami: fon o'qilmaydi, GPU uchun deyarli bepul.
  final double maxSigma;

  final double maxTintAlpha;

  /// Shisha rang qatlami (standart — sahifa foni).
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = tint ?? c.background;
    final strongTop = strongEdge == VerticalDirection.up;
    final strong = strongTop ? Alignment.topCenter : Alignment.bottomCenter;
    final weak = strongTop ? Alignment.bottomCenter : Alignment.topCenter;

    final Widget stack = ClipRect(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (maxSigma > 0)
            Positioned.fill(
              // grouped — tepada [GlassScope] bo'lsa ekranning boshqa
              // zonalari bilan bitta fon suratidan o'qiydi
              child: BackdropFilter.grouped(
                filter: ImageFilter.blur(sigmaX: maxSigma, sigmaY: maxSigma),
                child: const SizedBox.expand(),
              ),
            ),
          // Nozik rang qatlami — kuchli chetdan kuchsizga silliq so'nadi.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: strong,
                    end: weak,
                    colors: [
                      base.withValues(alpha: maxTintAlpha),
                      base.withValues(alpha: maxTintAlpha * 0.55),
                      base.withValues(alpha: 0),
                    ],
                    stops: const [0, 0.5, 0.95],
                  ),
                ),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );

    // Blur bo'lsa umumiy fon guruhi kerak. Tepada allaqachon guruh bo'lsa
    // (masalan butun ekran [GlassScope] ichida) yangisi ochilmaydi.
    if (maxSigma <= 0 || BackdropGroup.of(context) != null) return stack;
    return BackdropGroup(child: stack);
  }
}

/// Ekrandagi BARCHA shisha zonalar uchun bitta umumiy fon o'qishi.
///
/// Shisha element yolg'iz qolsa o'ziga guruh ochadi: appbar bitta, kapsula
/// ikkinchi. Bir ekranda ikkalasi bo'lsa GPU har kadrda IKKI marta to'xtab
/// butun ekranni teksturaga ko'chiradi — mobil GPU'da eng qimmat amal,
/// skroll va animatsiya paytida aynan shu "qotish" bo'lib seziladi.
/// [Scaffold]ni shu bilan o'rasangiz, ekrandagi hamma shisha bitta
/// o'qishdan foydalanadi.
///
/// [Scaffold] body'ni appbar va pastki paneldan OLDIN chizadi — umumiy
/// surat appbar blur'ida olinadi va kapsula uchun ham aynan o'sha kontent.
/// Kapsula pastki zona (blursiz rang) ustida turadi: u o'z blur'i va o'z
/// rangini chizgani uchun ostidagi zona rangi ko'rinmaydi — bu kutilgan.
///
/// Guruhni Navigator (butun ilova) ustiga qo'yib bo'lmaydi: ustki route'ning
/// shishasi ostki sahifani ko'rsatib qolardi — surat birinchi qatlamda
/// olinadi, ustki sahifa esa undan keyin chiziladi. Shuning uchun har
/// Scaffold o'zini o'raydi.
class GlassScope extends StatelessWidget {
  const GlassScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Ichma-ich o'ralsa (masalan sahifa va uning ichidagi zona) — bitta
    // guruh qoladi
    if (BackdropGroup.of(context) != null) return child;
    return BackdropGroup(child: child);
  }
}

/// Suzuvchi yumaloq shisha karta — iOS 26 tab-bar kapsulasi uslubida:
/// bir tekis kuchli blur, nozik shisha qirra (rim) va yumshoq soya.
///
/// Blur guruhli: [GlassScope] ichida ekranning boshqa zonalari bilan bitta
/// fon suratidan o'qiydi; guruh bo'lmasa oddiy filtr bo'lib ishlayveradi.
class GlassIsland extends StatelessWidget {
  const GlassIsland({
    super.key,
    required this.child,
    this.radius = 30,
    this.sigma = 22,
  });

  final Widget child;
  final double radius;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.14),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter.grouped(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1C1C1E).withValues(alpha: 0.55)
                  : Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(radius),
              // Shisha qirrasi — yorug'lik tushgan chekka effekti.
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.45),
                width: 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Shaffof appbar: pastki cheti tiniq, yuqoriga (status-bar tomon) rang
/// kuchayib boradi, ostida bir tekis blur — kontent uning ostiga "erib" kiradi.
class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.toolbarHeight = 68,
  });

  final Widget title;
  final List<Widget>? actions;
  final Widget? leading;
  final double toolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: toolbarHeight,
      titleSpacing: leading == null ? 20 : 4,
      title: title,
      actions: actions,
      leading: leading,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: const ProgressiveGlass(
        strongEdge: VerticalDirection.up,
        maxSigma: 14,
        maxTintAlpha: 0.5,
      ),
    );
  }
}

/// Shisha modal sheet: yarim shaffof sirt + blur + o'z tutqichi (drag handle).
/// `showModalBottomSheet` builder'ida kontentni shu bilan o'rang.
class GlassSheet extends StatelessWidget {
  const GlassSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          color: c.surface.withValues(alpha: context.isDark ? 0.86 : 0.82),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(top: 10, bottom: 4),
                decoration: BoxDecoration(
                  color: c.outline,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Flexible(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
