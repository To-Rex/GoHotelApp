import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/glass.dart';
import '../../../../core/widgets/loading_state.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../domain/format.dart';
import '../../domain/guest_feedback.dart';
import '../../domain/management_access.dart';
import '../cubit/feedback_cubit.dart';
import '../widgets/stagger_in.dart';
import '../widgets/state_palette.dart';

/// Mehmon murojaatlari: talab, taklif, shikoyat — holatini boshqarish.
///
/// Puls ekranidagi "Diqqat" qatoridan ochiladi. O'z cubit'i bor: ro'yxat
/// ochilganda yuklanadi, yopilganda unutiladi.
class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key, required this.access});

  final ManagementAccess access;

  static Future<void> open(BuildContext context, {ManagementAccess? access}) {
    final resolved = access ?? ManagementAccessScope.of(context);
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => FeedbackCubit(getIt())..load(),
          child: FeedbackPage(access: resolved),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: Text(l10n.feedbackTitle)),
      body: Builder(
        builder: (context) {
          final topPad = MediaQuery.paddingOf(context).top;
          final cubit = context.read<FeedbackCubit>();
          return BlocBuilder<FeedbackCubit, FeedbackState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, topPad + 8, 0, 6),
                    child: _Filters(state: state),
                  ),
                  Expanded(
                    child: switch (state) {
                      FeedbackState(loading: true, items: []) => const Padding(
                        padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: ListSkeleton(count: 4, itemHeight: 120),
                      ),
                      FeedbackState(error: final e?, items: []) => ErrorState(
                        error: e,
                        onRetry: cubit.load,
                      ),
                      _ => RefreshIndicator(
                        onRefresh: cubit.load,
                        child: state.visible.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  const SizedBox(height: 40),
                                  EmptyState(
                                    icon: CupertinoIcons.text_bubble,
                                    title: l10n.feedbackEmptyTitle,
                                    body: l10n.feedbackEmptyBody,
                                  ),
                                ],
                              )
                            : ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.fromLTRB(
                                  20,
                                  8,
                                  20,
                                  MediaQuery.paddingOf(context).bottom + 24,
                                ),
                                children: [
                                  StaggerIn(
                                    spacing: 10,
                                    children: [
                                      for (final f in state.visible)
                                        _FeedbackCard(
                                          item: f,
                                          onTap: () =>
                                              _showFeedbackSheet(context, f, access),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                      ),
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// Ruxsatlar shell'dan pastga uzatiladi; route'da provider bo'lmasa
/// (masalan test) hamma narsa faqat ko'rish rejimida bo'ladi.
class ManagementAccessScope extends InheritedWidget {
  const ManagementAccessScope({
    super.key,
    required this.access,
    required super.child,
  });

  final ManagementAccess access;

  static ManagementAccess of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<ManagementAccessScope>();
    return scope?.access ?? _viewOnly;
  }

  static const _viewOnly = ManagementAccess(
    isAdmin: false,
    canBroadcast: false,
    canSetRoomStatus: false,
    canCreateTask: false,
    canAssignTask: false,
    canUpdateTask: false,
    canForceClose: false,
    canViewFeedback: true,
    canManageFeedback: false,
    canResolveProblems: false,
  );

  @override
  bool updateShouldNotify(ManagementAccessScope oldWidget) =>
      oldWidget.access != access;
}

class _Filters extends StatelessWidget {
  const _Filters({required this.state});

  final FeedbackState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final cubit = context.read<FeedbackCubit>();

    String label(FeedbackFilter f) => switch (f) {
      FeedbackFilter.open => l10n.feedbackFilterOpen,
      FeedbackFilter.complaints => l10n.feedbackFilterComplaints,
      FeedbackFilter.resolved => l10n.feedbackFilterResolved,
      FeedbackFilter.all => l10n.all,
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          for (final f in FeedbackFilter.values) ...[
            GestureDetector(
              onTap: () => cubit.setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: state.filter == f ? c.brand : c.surfaceAlt,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${label(f)} · ${state.countOf(f)}',
                  style: context.textStyles.bodyMedium!.copyWith(
                    color: state.filter == f ? Colors.white : c.textMuted,
                    fontWeight: state.filter == f ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.item, required this.onTap});

  final GuestFeedback item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final typeColor = FeedbackPalette.typeColor(c, item.type);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 38,
                decoration: BoxDecoration(
                  color: typeColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.subject,
                      style: context.textStyles.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (item.guestName?.isNotEmpty == true) item.guestName!,
                        if (item.roomNumber?.isNotEmpty == true)
                          l10n.feedbackRoom(item.roomNumber!),
                        formatWhen(item.createdAt, DateTime.now()),
                      ].join(' · '),
                      style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.body,
            style: context.textStyles.bodyMedium!.copyWith(color: c.textMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              StatusChip(
                label: FeedbackPalette.typeLabel(l10n, item.type),
                background: FeedbackPalette.typeSoft(c, item.type),
                foreground: typeColor,
              ),
              StatusChip(
                label: FeedbackPalette.statusLabel(l10n, item.status),
                background: FeedbackPalette.statusSoft(c, item.status),
                foreground: FeedbackPalette.statusColor(c, item.status),
              ),
              if (item.priority == 'HIGH')
                StatusChip(
                  label: l10n.priorityHigh,
                  background: c.dangerSoft,
                  foreground: c.danger,
                  icon: CupertinoIcons.exclamationmark,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _showFeedbackSheet(
  BuildContext context,
  GuestFeedback item,
  ManagementAccess access,
) {
  final cubit = context.read<FeedbackCubit>();
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: cubit,
      child: _FeedbackSheet(id: item.id, access: access),
    ),
  );
}

class _FeedbackSheet extends StatefulWidget {
  const _FeedbackSheet({required this.id, required this.access});

  final String id;
  final ManagementAccess access;

  @override
  State<_FeedbackSheet> createState() => _FeedbackSheetState();
}

class _FeedbackSheetState extends State<_FeedbackSheet> {
  final _resolution = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _resolution.dispose();
    super.dispose();
  }

  Future<void> _set(String status) async {
    final l10n = context.l10n;
    final closing = status == 'RESOLVED' || status == 'REJECTED';
    if (closing && _resolution.text.trim().isEmpty) {
      context.showSnack(l10n.feedbackResolutionRequired, isError: true);
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<FeedbackCubit>().setStatus(
        widget.id,
        status,
        resolution: closing ? _resolution.text : null,
      );
      if (!mounted) return;
      context.showSnack(l10n.feedbackStatusUpdated);
      if (closing) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      context.showSnack(friendlyError(context, e), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final item = context.select(
      (FeedbackCubit cubit) => cubit.state.items.firstWhere(
        (f) => f.id == widget.id,
        orElse: () => cubit.state.items.first,
      ),
    );
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final now = DateTime.now();

    return GlassSheet(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            bottom + MediaQuery.paddingOf(context).bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  StatusChip(
                    label: FeedbackPalette.typeLabel(l10n, item.type),
                    background: FeedbackPalette.typeSoft(c, item.type),
                    foreground: FeedbackPalette.typeColor(c, item.type),
                  ),
                  StatusChip(
                    label: FeedbackPalette.statusLabel(l10n, item.status),
                    background: FeedbackPalette.statusSoft(c, item.status),
                    foreground: FeedbackPalette.statusColor(c, item.status),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(item.subject, style: context.textStyles.titleLarge),
              const SizedBox(height: 8),
              Text(item.body, style: context.textStyles.bodyLarge),
              const SizedBox(height: 14),
              Text(
                [
                  if (item.guestName?.isNotEmpty == true) item.guestName!,
                  if (item.guestPhone?.isNotEmpty == true) item.guestPhone!,
                  if (item.roomNumber?.isNotEmpty == true)
                    l10n.feedbackRoom(item.roomNumber!),
                  if (item.reservationNumber?.isNotEmpty == true)
                    item.reservationNumber!,
                  formatWhen(item.createdAt, now),
                  if (item.createdByName?.isNotEmpty == true) item.createdByName!,
                ].join(' · '),
                style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
              ),
              if (item.assignedToName?.isNotEmpty == true)
                Text(
                  l10n.feedbackAssigned(item.assignedToName!),
                  style: context.textStyles.bodySmall!.copyWith(color: c.textMuted),
                ),
              if (item.resolution?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: c.successSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.feedbackResolutionLabel,
                        style: context.textStyles.labelMedium!.copyWith(
                          color: c.success,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(item.resolution!, style: context.textStyles.bodyMedium),
                      if (item.resolvedByName != null && item.resolvedAt != null)
                        Text(
                          '${item.resolvedByName} · ${formatWhen(item.resolvedAt!, now)}',
                          style: context.textStyles.bodySmall!.copyWith(
                            color: c.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (widget.access.canManageFeedback) ...[
                const SizedBox(height: 18),
                if (item.isOpen) ...[
                  TextField(
                    controller: _resolution,
                    minLines: 2,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: l10n.feedbackResolutionLabel,
                      hintText: l10n.feedbackResolutionRequired,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (item.isNew) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy ? null : () => _set('IN_PROGRESS'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(46),
                            ),
                            child: Text(l10n.problemTake),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: _busy ? null : () => _set('RESOLVED'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                            backgroundColor: c.success,
                          ),
                          child: Text(l10n.feedbackResolveAction),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _busy ? null : () => _set('REJECTED'),
                    style: TextButton.styleFrom(foregroundColor: c.danger),
                    child: Text(l10n.feedbackRejectAction),
                  ),
                ] else
                  OutlinedButton.icon(
                    onPressed: _busy ? null : () => _set('IN_PROGRESS'),
                    icon: const Icon(CupertinoIcons.arrow_counterclockwise),
                    label: Text(l10n.feedbackReopen),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
