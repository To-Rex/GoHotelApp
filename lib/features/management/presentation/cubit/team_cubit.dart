import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/management_repository.dart';
import '../../domain/finance_report.dart';
import '../../domain/guest_feedback.dart';
import '../../domain/hk_task.dart';
import '../../domain/shift_handover.dart';
import '../../domain/shift_session.dart';
import '../../domain/staff_member.dart';
import '../../../../core/bloc/safe_emit.dart';
import '../../../../core/network/api_exception.dart';

/// "Jamoa" bo'limining ichki sahifalari.
enum TeamSegment { staff, shifts, tasks, problems }

/// Bitta bo'lakning yuklanish holati — to'rt bo'lak bir xil qolipda.
class Section<T> extends Equatable {
  const Section({this.items = const [], this.loading = true, this.error});

  final List<T> items;
  final bool loading;
  final Object? error;

  Section<T> copyWith({List<T>? items, bool? loading, Object? error, bool clearError = false}) =>
      Section(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
      );

  @override
  List<Object?> get props => [items, loading, error];
}

class TeamState extends Equatable {
  const TeamState({
    this.segment = TeamSegment.staff,
    this.staff = const Section(),
    this.shifts = const Section(),
    this.tasks = const Section(),
    this.problems = const Section(),
    this.shiftMode,
    this.query = '',
    this.cash,
    this.handovers,
    this.cashForbidden = false,
  });

  final TeamSegment segment;
  final Section<StaffMember> staff;
  final Section<ShiftSession> shifts;
  final Section<HkTask> tasks;
  final Section<StaffProblem> problems;

  /// `cash` — kassa smenalari yuritiladi; boshqa qiymatda bo'lim yo'q.
  final String? shiftMode;
  final String query;

  /// Kassada hozir (ochiq smenalar kassasi) va smenadan smenaga o'tgan
  /// pullar — admin yoki `shift.force_close`. `cashForbidden` — ruxsat yo'q,
  /// bo'limlar ko'rsatilmaydi. Yuklanmagan (eski server, tarmoq) — `null`.
  final CashOverview? cash;
  final HandoverReport? handovers;
  final bool cashForbidden;

  /// Ochiq smena kassasida hozir bo'lishi kerak bo'lgan summa.
  double? expectedCashOf(String sessionId) {
    for (final d in cash?.drawers ?? const <CashDrawer>[]) {
      if (d.id == sessionId) return d.expectedCash;
    }
    return null;
  }

  bool get cashMode => shiftMode == 'cash';

  /// Qidiruv bo'yicha xodimlar: faol va ishdan bo'shaganlar alohida
  /// tartibda — faollar birinchi.
  List<StaffMember> get visibleStaff {
    final q = query.trim().toLowerCase();
    final list = staff.items.where((s) {
      if (q.isEmpty) return true;
      return s.fullName.toLowerCase().contains(q) ||
          s.username.toLowerCase().contains(q) ||
          (s.phone ?? '').contains(q);
    }).toList();
    list.sort((a, b) {
      if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
      return a.fullName.compareTo(b.fullName);
    });
    return list;
  }

  List<ShiftSession> get openShifts => shifts.items.where((s) => s.isOpen).toList();
  List<ShiftSession> get closedShifts =>
      shifts.items.where((s) => !s.isOpen).toList();

  List<HkTask> tasksWith(String status) =>
      tasks.items.where((t) => t.status == status).toList();

  List<StaffProblem> get openProblems =>
      problems.items.where((p) => p.isOpen).toList();
  List<StaffProblem> get resolvedProblems =>
      problems.items.where((p) => !p.isOpen).toList();

  TeamState copyWith({
    TeamSegment? segment,
    Section<StaffMember>? staff,
    Section<ShiftSession>? shifts,
    Section<HkTask>? tasks,
    Section<StaffProblem>? problems,
    String? shiftMode,
    String? query,
    CashOverview? cash,
    HandoverReport? handovers,
    bool? cashForbidden,
  }) => TeamState(
    segment: segment ?? this.segment,
    staff: staff ?? this.staff,
    shifts: shifts ?? this.shifts,
    tasks: tasks ?? this.tasks,
    problems: problems ?? this.problems,
    shiftMode: shiftMode ?? this.shiftMode,
    query: query ?? this.query,
    cash: cash ?? this.cash,
    handovers: handovers ?? this.handovers,
    cashForbidden: cashForbidden ?? this.cashForbidden,
  );

  @override
  List<Object?> get props => [
    segment,
    staff,
    shifts,
    tasks,
    problems,
    shiftMode,
    query,
    cash,
    handovers,
    cashForbidden,
  ];
}

/// Jamoa: xodimlar, kassa smenalari, xo'jalik vazifalari, muammolar.
///
/// Har bo'lak o'zi yuklanadi — ochilganda va har daqiqada (faqat ochiq
/// bo'lak). Amallar serverdan qaytgan yozuv bilan ro'yxatni joyida
/// yangilaydi; xato istisno bo'lib chaqiruvchiga qaytadi (UI snack qiladi).
class TeamCubit extends Cubit<TeamState> with SafeEmit<TeamState> {
  TeamCubit(this._repository) : super(const TeamState());

  final ManagementRepository _repository;
  Timer? _poller;
  final _seq = <TeamSegment, int>{};

  void startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(
      const Duration(seconds: 60),
      (_) => loadSegment(state.segment, silent: true),
    );
  }

  void stopPolling() {
    _poller?.cancel();
    _poller = null;
  }

  /// Boshlang'ich yuklash: hamma bo'lak — tanlagichdagi sonlar (ochiq
  /// smena, biriktirilmagan vazifa, ochiq muammo) bo'limga kirmasdan ham
  /// to'g'ri tursin. Skelet faqat ochiq bo'lakda ko'rinadi.
  Future<void> load({bool silent = false}) => Future.wait([
    for (final segment in TeamSegment.values)
      loadSegment(segment, silent: silent || segment != state.segment),
  ]);

  void selectSegment(TeamSegment segment) {
    if (segment == state.segment) return;
    emit(state.copyWith(segment: segment));
    final section = switch (segment) {
      TeamSegment.staff => state.staff,
      TeamSegment.shifts => state.shifts,
      TeamSegment.tasks => state.tasks,
      TeamSegment.problems => state.problems,
    };
    // Bo'lak birinchi marta ochilsa to'liq yuklash, aks holda jim yangilash
    loadSegment(segment, silent: section.items.isNotEmpty);
  }

  void search(String value) => emit(state.copyWith(query: value));

  Future<void> loadSegment(TeamSegment segment, {bool silent = false}) async {
    final seq = (_seq[segment] ?? 0) + 1;
    _seq[segment] = seq;
    bool stale() => _seq[segment] != seq || isClosed;

    switch (segment) {
      case TeamSegment.staff:
        if (!silent) emit(state.copyWith(staff: state.staff.copyWith(loading: true, clearError: true)));
        try {
          final items = await _repository.getStaff();
          if (stale()) return;
          emit(state.copyWith(staff: Section(items: items, loading: false)));
        } catch (e) {
          if (stale()) return;
          emit(state.copyWith(staff: state.staff.copyWith(loading: false, error: silent ? null : e)));
        }
      case TeamSegment.shifts:
        if (!silent) emit(state.copyWith(shifts: state.shifts.copyWith(loading: true, clearError: true)));
        try {
          final mode = await _repository.getShiftMode();
          final items = mode == 'cash'
              ? await _repository.getShiftHistory(limit: 50)
              : const <ShiftSession>[];
          if (stale()) return;
          emit(state.copyWith(shiftMode: mode, shifts: Section(items: items, loading: false)));
          // Kassada hozir va smenadan smenaga o'tgan pullar — qo'shimcha:
          // yiqilsa ham smenalar ro'yxati turaveradi
          if (mode == 'cash' && !state.cashForbidden) await _loadCash(stale);
        } catch (e) {
          if (stale()) return;
          emit(state.copyWith(shifts: state.shifts.copyWith(loading: false, error: silent ? null : e)));
        }
      case TeamSegment.tasks:
        if (!silent) emit(state.copyWith(tasks: state.tasks.copyWith(loading: true, clearError: true)));
        try {
          final items = await _repository.getTasks();
          if (stale()) return;
          // Yangi va shoshilinchlar tepada: ochiq → jarayonda → yakunlangan
          items.sort(_taskOrder);
          emit(state.copyWith(tasks: Section(items: items, loading: false)));
        } catch (e) {
          if (stale()) return;
          emit(state.copyWith(tasks: state.tasks.copyWith(loading: false, error: silent ? null : e)));
        }
      case TeamSegment.problems:
        if (!silent) emit(state.copyWith(problems: state.problems.copyWith(loading: true, clearError: true)));
        try {
          final items = await _repository.getProblems();
          if (stale()) return;
          emit(state.copyWith(problems: Section(items: items, loading: false)));
        } catch (e) {
          if (stale()) return;
          emit(state.copyWith(problems: state.problems.copyWith(loading: false, error: silent ? null : e)));
        }
    }
  }

  /// Kassalar holati va topshirishlar. Ruxsat yo'q (403) — xato emas,
  /// bo'limlar yashiriladi va qayta so'ralmaydi; boshqa xato (masalan eski
  /// server) — oxirgi ma'lum qiymat qoladi.
  Future<void> _loadCash(bool Function() stale) async {
    Future<T?> attempt<T>(Future<T> Function() call) async {
      try {
        return await call();
      } on ApiException catch (e) {
        if (e.isForbidden && !stale()) emit(state.copyWith(cashForbidden: true));
        return null;
      } catch (_) {
        return null;
      }
    }

    final results = await Future.wait([
      attempt(_repository.getCashOverview),
      attempt(() => _repository.getShiftHandovers(limit: 30)),
    ]);
    if (stale() || state.cashForbidden) return;
    emit(
      state.copyWith(
        cash: results[0] as CashOverview?,
        handovers: results[1] as HandoverReport?,
      ),
    );
  }

  static int _taskOrder(HkTask a, HkTask b) {
    int rank(HkTask t) => switch (t.status) {
      'OPEN' => 0,
      'IN_PROGRESS' => 1,
      'COMPLETED' => 2,
      _ => 3,
    };
    final byStatus = rank(a).compareTo(rank(b));
    if (byStatus != 0) return byStatus;
    if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
    return b.createdAt.compareTo(a.createdAt);
  }

  // --- Amallar --------------------------------------------------------------

  Future<void> forceClose({
    required String sessionId,
    double? countedCash,
    String? notes,
    bool handOver = true,
  }) async {
    await _repository.forceCloseShift(
      sessionId: sessionId,
      countedCash: countedCash,
      notes: notes,
      handOver: handOver,
    );
    await loadSegment(TeamSegment.shifts, silent: true);
  }

  Future<void> assignTask(String taskId, String userId) async {
    final updated = await _repository.assignTask(taskId, userId);
    _replaceTask(updated);
  }

  Future<void> setTaskStatus(String taskId, String status) async {
    final updated = await _repository.setTaskStatus(taskId, status);
    _replaceTask(updated);
  }

  Future<void> createTask({
    required String branchId,
    required String roomId,
    required String taskType,
    String priority = 'MEDIUM',
    String? assignedTo,
    String? notes,
  }) async {
    final created = await _repository.createTask(
      branchId: branchId,
      roomId: roomId,
      taskType: taskType,
      priority: priority,
      assignedTo: assignedTo,
      notes: notes,
    );
    final items = [created, ...state.tasks.items]..sort(_taskOrder);
    emit(state.copyWith(tasks: state.tasks.copyWith(items: items)));
  }

  Future<void> setProblemStatus(String id, String status) async {
    await _repository.setProblemStatus(id, status);
    emit(
      state.copyWith(
        problems: state.problems.copyWith(
          items: [
            for (final p in state.problems.items)
              p.id == id ? p.withStatus(status) : p,
          ],
        ),
      ),
    );
  }

  void _replaceTask(HkTask task) {
    final items = [
      for (final t in state.tasks.items) t.id == task.id ? task : t,
    ]..sort(_taskOrder);
    emit(state.copyWith(tasks: state.tasks.copyWith(items: items)));
  }

  @override
  Future<void> close() {
    _poller?.cancel();
    return super.close();
  }
}
