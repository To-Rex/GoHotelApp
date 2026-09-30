import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../call_watcher_service.dart';

/// "Qo'ng'iroq bo'yicha mehmonni aniqlash" imkoniyatini yoqish taklifi.
///
/// Ruxsat berilgan bo'lsa yoki qurilma qo'llab-quvvatlamasa (iOS) karta
/// umuman chizilmaydi — bir marta hal qilingan narsa har kuni ko'zga
/// tashlanib turmasligi kerak.
///
/// Rad etilgan taklif ham yopiladi: xodim "kerak emas" degan bo'lsa,
/// har ochilishida qayta so'rash bezovta qiladi. Kerak bo'lsa ilovani
/// qayta ochib yoqadi.
class CallPermissionCard extends StatefulWidget {
  const CallPermissionCard({super.key});

  @override
  State<CallPermissionCard> createState() => _CallPermissionCardState();
}

class _CallPermissionCardState extends State<CallPermissionCard> {
  final _service = getIt<CallWatcherService>();

  bool _visible = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    if (!_service.isSupported) return;
    final granted = await _service.hasPermission();
    if (!mounted) return;
    setState(() => _visible = !granted);
  }

  Future<void> _enable() async {
    setState(() => _busy = true);
    final granted = await _service.requestPermission();
    if (granted) await _service.start();
    if (!mounted) return;
    setState(() {
      _busy = false;
      _visible = !granted;
    });
    if (granted) context.showSnack(context.l10n.callWatchEnabled);
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final c = context.colors;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(14),
        color: c.infoSoft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.phone_arrow_down_left, color: c.info),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.callWatchTitle,
                    style: context.textStyles.titleSmall,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _visible = false),
                  icon: const Icon(CupertinoIcons.xmark, size: 16),
                  tooltip: l10n.dismiss,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              l10n.callWatchBody,
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _enable,
                child: Text(l10n.callWatchEnable),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
