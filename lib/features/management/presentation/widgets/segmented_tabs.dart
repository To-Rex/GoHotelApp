import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';

/// Bitta bo'lak: yozuv va ixtiyoriy sanoq belgisi.
class SegmentItem {
  const SegmentItem({required this.label, this.badge});

  final String label;
  final int? badge;
}

/// iOS uslubidagi segment tanlagich: tanlangan bo'lak ostida sirg'aluvchi
/// oq "tosh", qolganlari kulrang fonda. Bo'laklar teng kenglikda.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<SegmentItem> items;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        const pad = 3.0;
        final slot = (constraints.maxWidth - pad * 2) / items.length;
        return Container(
          height: 40,
          padding: const EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: c.surfaceAlt,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: slot * selected,
                top: 0,
                bottom: 0,
                width: slot,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: context.isDark ? 0.4 : 0.08,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelected(i),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 200),
                                  style: context.textStyles.labelLarge!.copyWith(
                                    color: i == selected ? c.text : c.textMuted,
                                    fontWeight: i == selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                  child: Text(
                                    items[i].label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if ((items[i].badge ?? 0) > 0) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: i == selected ? c.brand : c.textMuted,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    '${items[i].badge}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
