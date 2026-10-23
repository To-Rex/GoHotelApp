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

/// Bosh sahifadagi eslatma: topshirilgan kassalar admin/menejer tasdig'ini
/// kutmoqda. Tugma to'g'ridan-to'g'ri qabul qilish oynasini ochadi.
class PendingHandoverCard extends StatelessWidget {
  const PendingHandoverCard({
    super.key,
    required this.sessions,
    required this.expectedCashOf,
    required this.onOpen,
  });

  final List<ShiftSession> sessions;
  final double? Function(String sessionId) expectedCashOf;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final total = sessions.fold<double>(
      0,
      (sum, s) => sum + (s.countedCash ?? expectedCashOf(s.id) ?? 0),
    );
    final amount = formatMoney(total);
    final body = sessions.length == 1
        ? l10n.handoverBannerOne(sessions.single.userName ?? '—', amount)
        : l10n.handoverBannerMany(sessions.length, amount);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: c.warningSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.warning.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: c.warning.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.payments_rounded, size: 22, color: c.warning),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.shiftApprovePending,
                      style: context.textStyles.titleMedium!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      body,
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
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                backgroundColor: c.success,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
              label: Text(l10n.shiftApproveBtn),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tasdiqlash oynasi. Ro'yxat TeamCubit'dan jonli yangilanadi: bitta kassa
/// tasdiqlangach qolganlari joyida qoladi, oxirgisi yopilgach oyna yopiladi.
Future<void> showShiftApprovalSheet(
  BuildContext context, {
  required TeamCubit team,
  VoidCallback? onApproved,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: team,
      child: _ShiftApprovalSheet(onApproved: onApproved),
    ),
  );
}

class _ShiftApprovalSheet extends StatefulWidget {
  const _ShiftApprovalSheet({this.onApproved});

  final VoidCallback? onApproved;

  @override
  State<_ShiftApprovalSheet> createState() => _ShiftApprovalSheetState();
}

class _ShiftApprovalSheetState extends State<_ShiftApprovalSheet> {
  final _approving = <String>{};
  bool _closing = false;

  Future<void> _approve(ShiftSession session) async {
    if (_approving.contains(session.id)) return;
    setState(() => _approving.add(session.id));
    final team = context.read<TeamCubit>();
    final l10n = context.l10n;
    try {
      await team.approveHandover(session.id);
      widget.onApproved?.call();
      if (!mounted) return;
      context.showSnack(l10n.shiftApproveDone);
      final remaining = team.state.openShifts
          .where((s) => s.isPendingApproval)
          .length;
      if (remaining == 0) {
        _closing = true;
        Navigator.of(context).maybePop();
        return;
      }
    } catch (e) {
      if (!mounted) return;
      context.showSnack(friendlyError(context, e), isError: true);
    } finally {
      if (mounted && !_closing) {
        setState(() => _approving.remove(session.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    return BlocBuilder<TeamCubit, TeamState>(
      builder: (context, state) {
        final pending = state.openShifts
            .where((s) => s.isPendingApproval)
            .toList();
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.86,
          ),
          child: GlassSheet(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c.warningSoft,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.payments_rounded,
                            size: 22,
                            color: c.warning,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.handoverSheetTitle,
                                style: context.textStyles.titleLarge,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                l10n.handoverSheetHint,
                                style: context.textStyles.bodySmall!.copyWith(
                                  color: c.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (pending.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        child: Row(
                          children: [
                            Icon(
                              CupertinoIcons.checkmark_seal_fill,
                              size: 22,
                              color: c.success,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                l10n.handoverLastDone,
                                style: context.textStyles.titleSmall!.copyWith(
                                  color: c.success,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: pending.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final session = pending[index];
                            return _PendingHandoverTile(
                              session: session,
                              expectedCash: state.expectedCashOf(session.id),
                              busy: _approving.contains(session.id),
                              onApprove: () => _approve(session),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text(l10n.close),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PendingHandoverTile extends StatelessWidget {
  const _PendingHandoverTile({
    required this.session,
    required this.expectedCash,
    required this.busy,
    required this.onApprove,
  });

  final ShiftSession session;
  final double? expectedCash;
  final bool busy;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final counted = session.countedCash;
    final diff = counted != null && expectedCash != null
        ? counted - expectedCash!
        : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppAvatar(name: session.userName ?? '?', size: 38),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.userName ?? '—',
                      style: context.textStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.shiftApprovePending,
                      style: context.textStyles.labelSmall!.copyWith(
                        color: c.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (counted != null || expectedCash != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                if (counted != null)
                  Expanded(
                    child: _Amount(label: l10n.shiftCounted, value: counted),
                  ),
                if (counted != null && expectedCash != null)
                  const SizedBox(width: 10),
                if (expectedCash != null)
                  Expanded(
                    child: _Amount(
                      label: l10n.cashNowTitle,
                      value: expectedCash!,
                    ),
                  ),
              ],
            ),
            if (diff != null && diff.abs() >= 1) ...[
              const SizedBox(height: 6),
              Text(
                '${l10n.shiftDiff}: ${diff > 0 ? '+' : ''}${formatMoney(diff)}',
                style: context.textStyles.labelSmall!.copyWith(
                  color: diff < 0 ? c.danger : c.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: busy ? null : onApprove,
              style: FilledButton.styleFrom(
                backgroundColor: c.success,
                foregroundColor: Colors.white,
                disabledBackgroundColor: c.success.withValues(alpha: 0.4),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              icon: busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(CupertinoIcons.checkmark_seal_fill, size: 17),
              label: Text(l10n.confirm),
            ),
          ),
        ],
      ),
    );
  }
}

class _Amount extends StatelessWidget {
  const _Amount({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.textStyles.labelSmall!.copyWith(color: c.textMuted),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            formatMoney(value),
            style: context.textStyles.titleSmall!.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
