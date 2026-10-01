import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../management/presentation/widgets/day_timeline.dart';
import '../../domain/staff_user.dart';
import '../cubit/auth_cubit.dart';

/// Ish vaqtidan tashqarida ko'rinadigan ekran.
///
/// Mehmonxona sozlamasida "ish vaqtidan tashqari ishlash" cheklangan
/// bo'lsa, server xodimning vaqti tugagach uning so'rovlarini
/// `403 OUTSIDE_WORK_HOURS` bilan qaytaradi. Bu ekransiz ilova bo'limlari
/// bittalab "ruxsat yo'q" deb qolib, buzilgandek ko'rinardi.
///
/// Sessiya TOZALANMAYDI. Ilova har daqiqada (va qayta ochilganda) serverdan
/// so'raydi — ish vaqti boshlanishi bilan ish o'zi davom etadi. Qaror
/// faqat serverniki: qurilma soati noto'g'ri bo'lsa ham xodim adashmaydi.
class OutsideWorkHoursPage extends StatefulWidget {
  const OutsideWorkHoursPage({super.key});

  /// Avtomatik tekshiruv oralig'i.
  static const recheckInterval = Duration(seconds: 60);

  @override
  State<OutsideWorkHoursPage> createState() => _OutsideWorkHoursPageState();
}

class _OutsideWorkHoursPageState extends State<OutsideWorkHoursPage>
    with WidgetsBindingObserver {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      OutsideWorkHoursPage.recheckInterval,
      (_) => _autoCheck(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        // Ertalab telefonni ochgan xodim bir daqiqa kutib o'tirmasin
        _autoCheck();
        _startTimer();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _timer?.cancel();
        _timer = null;
      default:
        break;
    }
  }

  /// Ekran almashish animatsiyasi paytida sahifa hali "mounted" — natija
  /// xabari faqat xodim haqiqatan shu ekranda qolgan bo'lsa ko'rsatiladi.
  bool get _blocked =>
      context.read<AuthCubit>().state.status == AuthStatus.outsideWorkHours;

  /// Jim tekshiruv: ish vaqti boshlangan bo'lsa ekran o'zi almashadi,
  /// xato esa keyingi urinishgacha e'tiborsiz qoladi.
  Future<void> _autoCheck() async {
    if (!mounted) return;
    setState(() {}); // "hozir" belgisi chiziqda siljiydi
    try {
      await context.read<AuthCubit>().recheckWorkHours(silent: true);
    } catch (_) {}
  }

  Future<void> _manualCheck() async {
    final l10n = context.l10n;
    try {
      final resumed = await context.read<AuthCubit>().recheckWorkHours();
      if (!mounted) return;
      if (resumed || !_blocked) return;
      context.showSnack(l10n.outsideHoursStill);
    } catch (e) {
      if (!mounted) return;
      // Sessiya tugagan bo'lsa ekran allaqachon login'ga o'tmoqda
      if (!_blocked) return;
      context.showSnack(friendlyError(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;

    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (a, b) =>
          a.user != b.user ||
          a.submitting != b.submitting ||
          a.error != b.error,
      builder: (context, state) {
        final user = state.user;
        // Serverning matni faqat soat noma'lum bo'lganda kerak — aks holda
        // u kartadagi soatni takrorlaydi (va faqat o'zbekcha).
        final detail = user == null ? state.error : null;

        return Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              // Kichik ekran yoki katta shriftda ham sig'adi: joy yetmasa
              // sahifa aylanadi, yetsa tugmalar pastga yopishadi.
              builder: (context, box) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              color: c.warningSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.schedule_rounded,
                              size: 44,
                              color: c.warning,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          l10n.outsideHoursTitle,
                          style: context.textStyles.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.outsideHoursBody,
                          style: context.textStyles.bodyLarge!.copyWith(
                            color: c.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (user != null) ...[
                          const SizedBox(height: 24),
                          _HoursCard(user: user, now: DateTime.now()),
                        ],
                        if (detail != null && detail.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: c.warningSoft,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              detail,
                              style: context.textStyles.bodyMedium!.copyWith(
                                color: c.warning,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Text(
                          l10n.outsideHoursHint,
                          style: context.textStyles.bodySmall!.copyWith(
                            color: c.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: state.submitting ? null : _manualCheck,
                          icon: state.submitting
                              ? Builder(
                                  // Tugmaning o'chirilgan holatdagi rangi
                                  builder: (context) => SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: IconTheme.of(context).color,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                          label: Text(l10n.outsideHoursRetry),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => context.read<AuthCubit>().logout(),
                          child: Text(l10n.logout),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Xodimning ish vaqti: "09:00 – 18:00" va 24 soatlik chiziqda oraliq bilan
/// "hozir" belgisi — bir qarashda vaqt qayerdaligi ko'rinadi.
class _HoursCard extends StatelessWidget {
  const _HoursCard({required this.user, required this.now});

  final StaffUser user;
  final DateTime now;

  /// Server "09:00:00" ko'rinishida ham yuborishi mumkin — soniyasiz.
  static String _hhmm(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return value;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final start = _hhmm(user.workStart);
    final end = _hhmm(user.workEnd);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: c.brandSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.work_history_outlined,
                  size: 20,
                  color: c.brand,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.outsideHoursScheduleLabel,
                      style: context.textStyles.bodySmall!.copyWith(
                        color: c.textMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text('$start – $end', style: context.textStyles.titleLarge),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DayTimeline(
            start: start,
            end: end,
            now: now,
            color: c.brand,
            trackColor: c.surfaceAlt,
            markerColor: c.warning,
            height: 8,
            labelStyle: context.textStyles.labelSmall!.copyWith(
              color: c.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
