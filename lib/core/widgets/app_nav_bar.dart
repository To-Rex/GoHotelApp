import 'package:flutter/material.dart';

import '../extensions/context_x.dart';
import 'glass.dart';

/// iOS 26 uslubidagi pastki navigatsiya:
///
/// - Tab'lar SUZUVCHI yumaloq shisha kapsula ([GlassIsland]) ichida —
///   chetlardan ajratilgan, pastdan ko'tarilgan, kontent ustida "suzadi".
/// - Kapsula orqasidagi zona [ProgressiveGlass] BLURSIZ rejimda: yuqorisi
///   butunlay shaffof, pastga (ekran chetiga) qarab rang kuchayib boradi.
///   iOS 26 da ham tab-bar ostida alohida blur yo'q — shisha faqat suzuvchi
///   kapsulaning o'zi; zona blur'i har kadrda qimmat turib, ko'zga deyarli
///   ilinmasdi.
///
/// API [NavigationBar] bilan mos ([NavigationDestination] ro'yxati) —
/// shell'lar o'zgarmaydi. `Scaffold.extendBody: true` bilan ishlaydi.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.destinations,
    this.centerAction,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<NavigationDestination> destinations;

  /// Tab'lar o'rtasidagi ASOSIY harakat (masalan hujjat skaneri).
  ///
  /// Bu tab emas — bosilganda bo'lim almashmaydi, balki amal bajariladi.
  /// Shuning uchun u boshqacha ko'rinadi: to'ldirilgan doira, kapsuladan
  /// biroz ko'tarilgan. Berilmasa panel avvalgidek ishlaydi.
  final NavBarAction? centerAction;

  /// Markaziy tugma qaysi tab'dan oldin turadi.
  int get _centerSlot => destinations.length ~/ 2;

  static const double _islandHeight = 62;
  static const double _sideMargin = 16;
  static const double _bottomGap = 10;

  /// Kapsula tepasidagi rang so'nadigan "havo" zonasi.
  static const double _fadeZone = 26;

  @override
  Widget build(BuildContext context) {
    // bottomNavigationBar slotida MediaQuery hali tizim insetini beradi.
    final systemInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: _fadeZone + _islandHeight + _bottomGap + systemInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Orqa zona: teginishlar ostidagi kontentga o'tib ketadi.
          // maxSigma: 0 — faqat rang gradienti, fon o'qilmaydi.
          const IgnorePointer(
            child: ProgressiveGlass(
              strongEdge: VerticalDirection.down,
              maxSigma: 0,
              maxTintAlpha: 0.38,
            ),
          ),
          Positioned(
            left: _sideMargin,
            right: _sideMargin,
            bottom: _bottomGap + systemInset,
            height: _islandHeight,
            child: GlassIsland(
              radius: _islandHeight / 2,
              child: Row(
                children: [
                  for (var i = 0; i < destinations.length; i++) ...[
                    // Markaziy tugma tab'larni teng ikkiga bo'ladi
                    if (centerAction != null && i == _centerSlot)
                      _CenterAction(action: centerAction!),
                    Expanded(
                      child: _TabItem(
                        destination: destinations[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastki paneldagi asosiy harakat.
class NavBarAction {
  const NavBarAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _CenterAction extends StatelessWidget {
  const _CenterAction({required this.action});

  final NavBarAction action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Tooltip(
        message: action.label,
        child: Material(
          color: c.brand,
          shape: const CircleBorder(),
          elevation: 3,
          shadowColor: c.brand.withValues(alpha: 0.5),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: action.onTap,
            child: SizedBox(
              width: 50,
              height: 50,
              child: Icon(action.icon, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.brand : c.textMuted;
    final icon = selected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;

    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            // Tanlangan tab — kapsula ichidagi yumshoq "linza" belgisi.
            color: selected
                ? c.brand.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(
                data: IconThemeData(size: 24, color: color),
                child: icon,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5,
                  fontFamily: 'Inter',
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: color,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
