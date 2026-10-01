import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../domain/format.dart';
import '../../domain/shift_session.dart';
import '../cubit/team_cubit.dart';
import 'pressable.dart';

/// Smenani majburiy yopish: sanalgan summa (ixtiyoriy), izoh, topshirish
/// rejimi. Ochiq smenaning egasi bo'lmagan admin/menejer uchun.
Future<void> showForceCloseSheet(BuildContext context, ShiftSession session) {
  final cubit = context.read<TeamCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _ForceCloseSheet(session: session),
    ),
  );
}

class _ForceCloseSheet extends StatefulWidget {
  const _ForceCloseSheet({required this.session});

  final ShiftSession session;

  @override
  State<_ForceCloseSheet> createState() => _ForceCloseSheetState();
}

class _ForceCloseSheetState extends State<_ForceCloseSheet> {
  final _cash = TextEditingController();
  final _notes = TextEditingController();
  bool _handOver = true;
  bool _submitting = false;

  @override
  void dispose() {
    _cash.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final l10n = context.l10n;
    final raw = _cash.text.replaceAll(RegExp(r'[^\d.]'), '');
    final counted = raw.isEmpty ? null : double.tryParse(raw);
    setState(() => _submitting = true);
    try {
      await context.read<TeamCubit>().forceClose(
        sessionId: widget.session.id,
        countedCash: counted,
        notes: _notes.text,
        handOver: _handOver,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.showSnack(l10n.shiftForceClosedDone);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      context.showSnack(friendlyError(context, e), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final session = widget.session;
    final now = DateTime.now();

    return GlassSheet(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          bottom + MediaQuery.paddingOf(context).bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Sarlavha ---------------------------------------------------
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: c.danger,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    CupertinoIcons.lock_fill,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.shiftForceClose,
                    style: context.textStyles.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- Yopilayotgan smena ------------------------------------------
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      AppAvatar(name: session.userName ?? '?', size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              session.userName ?? '—',
                              style: context.textStyles.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (session.startedAt != null)
                              Text(
                                l10n.shiftStarted(
                                  formatWhen(session.startedAt!, now),
                                ),
                                style: context.textStyles.bodySmall!.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: c.outline),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _Fact(
                          label: l10n.shiftDurationLabel,
                          value: formatDuration(
                            session.elapsed(now),
                            h: l10n.hourShort,
                            m: l10n.minuteShort,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _Fact(
                          label: l10n.shiftOpeningCash,
                          value: formatMoney(session.openingCash),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.shiftForceCloseBody(session.userName ?? '—'),
              style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
            ),
            const SizedBox(height: 16),

            // --- Sanalgan naqd: katta raqam maydoni --------------------------
            TextField(
              controller: _cash,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: context.textStyles.headlineSmall,
              decoration: InputDecoration(
                labelText: l10n.shiftCountedCashLabel,
                suffixText: l10n.currencySuffix,
                fillColor: c.surface,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _notes,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: l10n.notesLabel,
                fillColor: c.surface,
              ),
            ),
            const SizedBox(height: 10),

            // --- Topshirish rejimi -------------------------------------------
            Pressable(
              scale: 0.98,
              onTap: () => setState(() => _handOver = !_handOver),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.shiftHandOver,
                            style: context.textStyles.titleSmall,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.shiftHandOverHint,
                            style: context.textStyles.bodySmall!.copyWith(
                              color: c.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _handOver,
                      onChanged: (v) => setState(() => _handOver = v),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(backgroundColor: c.danger),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.shiftForceClose),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.labelSmall!.copyWith(
            color: context.colors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: context.textStyles.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
