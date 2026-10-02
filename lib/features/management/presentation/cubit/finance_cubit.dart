import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/safe_emit.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/management_repository.dart';
import '../../domain/finance_report.dart';
import '../../domain/finance_summary.dart';
import '../../domain/staff_revenue.dart';

/// Moliya sahifasi holati.
///
/// Davrga bog'liq bo'laklar (yig'ma, oldingi davr, kunlik qator, yopilgan
/// smenalar) davr almashganda qayta so'raladi; joriy holat bo'laklari
/// (kassalarda hozir qancha pul, qarzdorlar) — faqat ochilganda va
/// yangilanganda. Har bo'lak MUSTAQIL: biri yiqilsa qolganlari turadi.
class FinanceState extends Equatable {
  const FinanceState({
    required this.range,
    this.loading = true,
    this.periodLoading = false,
    this.summary,
    this.previous,
    this.days,
    this.cash,
    this.cashForbidden = false,
    this.debtors,
    this.shifts,
    this.staff,
    this.staffForbidden = false,
    this.error,
    this.failedSections = 0,
    this.updatedAt,
  });

  final FinanceRange range;

  /// Birinchi yuklash (hali hech narsa yo'q).
  final bool loading;

  /// Davr almashmoqda — davrga bog'liq kartalar xira ko'rinadi.
  final bool periodLoading;

  final FinanceSummary? summary;

  /// Solishtirish uchun oldingi davr yig'masi.
  final FinanceSummary? previous;
  final List<FinanceDay>? days;

  /// Kassalar holati; `cashForbidden` — ruxsat yo'q (menejer kodi yo'q),
  /// karta ko'rsatilmaydi.
  final CashOverview? cash;
  final bool cashForbidden;
  final DebtorsReport? debtors;
  final ShiftDiffSummary? shifts;

  /// Davr tushumi xodimlar kesimida; `staffForbidden` — ruxsat yo'q
  /// (moliya/kassa nazorati kodi yo'q), karta ko'rsatilmaydi.
  final StaffRevenueReport? staff;
  final bool staffForbidden;

  /// Hech narsa yuklanmagan holdagi xato — to'liq xato ekrani.
  final Object? error;
  final int failedSections;
  final DateTime? updatedAt;

  bool get hasData => summary != null;

  FinanceState copyWith({
    FinanceRange? range,
    bool? loading,
    bool? periodLoading,
    FinanceSummary? summary,
    FinanceSummary? previous,
    List<FinanceDay>? days,
    CashOverview? cash,
    bool? cashForbidden,
    DebtorsReport? debtors,
    ShiftDiffSummary? shifts,
    StaffRevenueReport? staff,
    bool? staffForbidden,
    Object? error,
    bool clearError = false,
    bool clearPeriodData = false,
    int? failedSections,
    DateTime? updatedAt,
  }) => FinanceState(
    range: range ?? this.range,
    loading: loading ?? this.loading,
    periodLoading: periodLoading ?? this.periodLoading,
    summary: summary ?? this.summary,
    previous: clearPeriodData ? null : (previous ?? this.previous),
    days: clearPeriodData ? null : (days ?? this.days),
    cash: cash ?? this.cash,
    cashForbidden: cashForbidden ?? this.cashForbidden,
    debtors: debtors ?? this.debtors,
    shifts: clearPeriodData ? null : (shifts ?? this.shifts),
    staff: clearPeriodData ? null : (staff ?? this.staff),
    staffForbidden: staffForbidden ?? this.staffForbidden,
    error: clearError ? null : (error ?? this.error),
    failedSections: failedSections ?? this.failedSections,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  List<Object?> get props => [
    range,
    loading,
    periodLoading,
    summary,
    previous,
    days,
    cash,
    cashForbidden,
    debtors,
    shifts,
    staff,
    staffForbidden,
    error,
    failedSections,
    updatedAt,
  ];
}

class FinanceCubit extends Cubit<FinanceState> with SafeEmit<FinanceState> {
  FinanceCubit(this._repository, {FinanceRangeKind initial = FinanceRangeKind.today, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(FinanceState(range: FinanceRange.of(initial, (clock ?? DateTime.now)())));

  final ManagementRepository _repository;
  final DateTime Function() _clock;

  /// Eski so'rov javobi yangisining ustidan yozmasligi uchun.
  int _seq = 0;

  /// Hammasini yuklash (ochilganda va pastga tortib yangilaganda).
  Future<void> load({bool silent = false}) async {
    final seq = ++_seq;
    if (!silent && !state.hasData) {
      emit(state.copyWith(loading: true, clearError: true));
    }
    final outcome = await Future.wait([
      _loadPeriod(seq, state.range),
      _loadCurrent(seq),
    ]);
    if (seq != _seq) return;
    final failures = outcome[0].$1 + outcome[1].$1;
    final firstError = outcome[0].$2 ?? outcome[1].$2;
    emit(
      state.copyWith(
        loading: false,
        periodLoading: false,
        failedSections: failures,
        updatedAt: _clock(),
        error: state.hasData ? null : firstError,
        clearError: state.hasData,
      ),
    );
  }

  /// Tez tanlov: bugun, kecha, 7 kun, shu oy.
  Future<void> selectKind(FinanceRangeKind kind) async {
    if (kind == FinanceRangeKind.custom) return;
    await _selectRange(FinanceRange.of(kind, _clock()));
  }

  /// Ixtiyoriy davr (sanalar tartibi muhim emas).
  Future<void> selectCustom(DateTime from, DateTime to) =>
      _selectRange(FinanceRange.custom(from, to));

  Future<void> _selectRange(FinanceRange range) async {
    if (range == state.range) return;
    final seq = ++_seq;
    emit(state.copyWith(range: range, periodLoading: true, clearPeriodData: true));
    final (failures, error) = await _loadPeriod(seq, range);
    if (seq != _seq) return;
    emit(
      state.copyWith(
        periodLoading: false,
        loading: false,
        failedSections: failures,
        updatedAt: _clock(),
        error: state.hasData ? null : error,
        clearError: state.hasData,
      ),
    );
  }

  /// Davrga bog'liq bo'laklar. Natija: (yiqilganlar soni, birinchi xato).
  Future<(int, Object?)> _loadPeriod(int seq, FinanceRange range) async {
    var failures = 0;
    Object? firstError;
    final previousRange = range.previous();

    Future<void> part<T>(Future<T> future, FinanceState Function(FinanceState, T) apply) async {
      try {
        final value = await future;
        if (seq != _seq) return;
        emit(apply(state, value));
      } catch (e) {
        failures++;
        firstError ??= e;
      }
    }

    await Future.wait([
      part(
        _repository.getFinanceSummary(from: range.from, to: range.to),
        (s, v) => s.copyWith(summary: v, loading: false),
      ),
      part(
        _repository.getFinanceSummary(from: previousRange.from, to: previousRange.to),
        (s, v) => s.copyWith(previous: v),
      ),
      // Bir kunlik davrda grafik kerak emas; bir yildan uzun davr uchun
      // server kunlik qator bermaydi (grafik ham o'qib bo'lmas darajada zich)
      if (!range.isSingleDay && range.days <= 366)
        part(
          _repository.getFinanceDaily(from: range.from, to: range.to),
          (s, v) => s.copyWith(days: v),
        ),
      part(_loadShifts(range), (s, v) => s.copyWith(shifts: v)),
      _loadStaff(seq, range).then((error) {
        if (error != null) {
          failures++;
          firstError ??= error;
        }
      }),
    ]);
    return (failures, firstError);
  }

  /// Tushum xodimlar kesimida. Ruxsat yo'q (403) — xato emas, karta
  /// yashiriladi va keyingi davrlarda qayta so'ralmaydi.
  Future<Object?> _loadStaff(int seq, FinanceRange range) async {
    if (state.staffForbidden) return null;
    try {
      final staff = await _repository.getFinanceByStaff(from: range.from, to: range.to);
      if (seq == _seq) emit(state.copyWith(staff: staff));
      return null;
    } on ApiException catch (e) {
      if (e.isForbidden) {
        if (seq == _seq) emit(state.copyWith(staffForbidden: true));
        return null;
      }
      return e;
    } catch (e) {
      return e;
    }
  }

  /// Joriy holat: kassalar va qarzdorlar (davrga bog'liq emas).
  Future<(int, Object?)> _loadCurrent(int seq) async {
    var failures = 0;
    Object? firstError;

    try {
      final cash = await _repository.getCashOverview();
      if (seq == _seq) emit(state.copyWith(cash: cash, cashForbidden: false));
    } on ApiException catch (e) {
      // Menejerda kassa nazorati ruxsati bo'lmasa — karta yashiriladi,
      // bu xato emas
      if (e.isForbidden) {
        if (seq == _seq) emit(state.copyWith(cashForbidden: true));
      } else {
        failures++;
        firstError ??= e;
      }
    } catch (e) {
      failures++;
      firstError ??= e;
    }

    try {
      final debtors = await _repository.getDebtorsReport();
      if (seq == _seq) emit(state.copyWith(debtors: debtors));
    } catch (e) {
      failures++;
      firstError ??= e;
    }
    return (failures, firstError);
  }

  /// Davrda yopilgan smenalar (kassa rejimida). Oddiy rejimda — bo'sh.
  Future<ShiftDiffSummary> _loadShifts(FinanceRange range) async {
    final mode = await _repository.getShiftMode();
    if (mode != 'cash') {
      return ShiftDiffSummary.of(const [], range);
    }
    final sessions = await _repository.getShiftHistory(limit: 200);
    return ShiftDiffSummary.of(sessions, range);
  }
}
