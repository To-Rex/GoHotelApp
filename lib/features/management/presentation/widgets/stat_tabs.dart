import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import 'animated_counter.dart';

/// Bitta bo'lak: son va uning nomi.
class StatTab {
  const StatTab({required this.label, required this.count});

  final String label;
  final int count;
}

/// Sonli bo'lak tanlagich: har bo'lakda KATTA son va ostida nomi — tab ham,
/// ko'rsatkich ham. Tanlangan bo'lak ostida sirg'aluvchi oq "tosh".
///
/// Oddiy segment tanlagichdan farqi: son yozuv yonida emas, ustida turadi —
/// tor ekranda ham to'rt bo'lakning nomi qisqarmay sig'adi.
class StatTabs extends StatelessWidget {
  const StatTabs({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
  });

  final List<StatTab> items;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        const pad = 4.0;
        final slot = (constraints.maxWidth - pad * 2) / items.length;
        return Container(
          height: 62,
          padding: const EdgeInsets.all(pad),
          decoration: BoxDecoration(
            color: c.surfaceAlt,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                left: slot * selected,
                top: 0,
                bottom: 0,
                width: slot,
                child: Container(
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(16),
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
                      child: Semantics(
                        button: true,
                        selected: i == selected,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onSelected(i),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedCounter(
                                  value: items[i].count.toDouble(),
                                  format: (v) => '${v.round()}',
                                  duration: const Duration(milliseconds: 500),
                                  style: context.textStyles.titleMedium!
                                      .copyWith(
                                        color: i == selected
                                            ? c.brand
                                            : (items[i].count > 0
                                                  ? c.text
                                                  : c.textMuted),
                                        fontWeight: FontWeight.w800,
                                        height: 1.15,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      height: 1.2,
                                      color: i == selected
                                          ? c.text
                                          : c.textMuted,
                                      fontWeight: i == selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                    child: Text(items[i].label, maxLines: 1),
                                  ),
                                ),
                              ],
                            ),
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
