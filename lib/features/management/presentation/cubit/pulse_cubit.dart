import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../reception/bookings/data/bookings_repository.dart';
import '../../data/management_repository.dart';
import '../../domain/hotel_pulse.dart';
import '../../domain/management_access.dart';
import '../../../../core/bloc/safe_emit.dart';

/// Moliya kartasidagi davr — tez tanlovlar.
enum PulsePeriod {
  today,
  week,
  month;

  (DateTime, DateTime) range(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      PulsePeriod.today => (today, today),
      PulsePeriod.week => (today.subtract(const Duration(days: 6)), today),
      PulsePeriod.month => (DateTime(now.year, now.month, 1), today),
    };
  }
}

class PulseState extends Equatable {
  const PulseState({
    this.loading = true,
    this.pulse = const HotelPulse(),
    this.period = PulsePeriod.today,
    this.financeLoading = false,
    this.error,
    this.updatedAt,
    this.failedSections = 0,
  });

  final bool loading;
  final HotelPulse pulse;
  final PulsePeriod period;

  /// Davr almashganda faqat moliya kartasi kutadi, qolganlari turadi.
  final bool financeLoading;

  /// Hech bir bo'lak yuklanmagan bo'lsa — butun ekran xatosi.
  final Object? error;
  final DateTime? updatedAt;

  /// Qismlarning nechtasi yuklanmadi (ogohlantirish chizig'i uchun).
  final int failedSections;

  bool get hasData =>
      pulse.rooms != null || pulse.bookings != null || pulse.finance != null;

  PulseState copyWith({
    bool? loading,
    HotelPulse? pulse,
    PulsePeriod? period,
    bool? financeLoading,
    Object? error,
    bool clearError = false,
    DateTime? updatedAt,
    int? failedSections,
  }) => PulseState(
    loading: loading ?? this.loading,
    pulse: pulse ?? this.pulse,
    period: period ?? this.period,
    financeLoading: financeLoading ?? this.financeLoading,
    error: clearError ? null : (error ?? this.error),
    updatedAt: updatedAt ?? this.updatedAt,
    failedSections: failedSections ?? this.failedSections,
  );

  @override
  List<Object?> get props => [
    loading,
    pulse,
    period,
    financeLoading,
    error,
    updatedAt,
    failedSections,
  ];
}

/// Mehmonxona pulsi: har bo'lak alohida so'raladi va kelishi bilan
/// ekranga tushadi — sekin bo'lak tez bo'laklarni ushlab turmaydi.
class PulseCubit extends Cubit<PulseState> with SafeEmit<PulseState> {
  PulseCubit(this._repository, this._bookings, {this.access})
    : super(const PulseState());

  final ManagementRepository _repository;
  final BookingsRepository _bookings;

  /// Ruxsati yo'q bo'laklar so'ralmaydi — server rad etishi aniq bo'lgan
  /// so'rov "yuklanmadi" ogohlantirishini bekorga chiqarmasin.
  final ManagementAccess? access;

  Timer? _poller;

  /// Eski so'rov javobi yangisining ustidan yozmasligi uchun.
  int _seq = 0;

  void startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(
      const Duration(seconds: 60),
      (_) => load(silent: true),
    );
  }

  void stopPolling() {
    _poller?.cancel();
    _poller = null;
  }

  Future<void> load({bool silent = false}) async {
    final seq = ++_seq;
    if (!silent) emit(state.copyWith(loading: true, clearError: true));
    final now = DateTime.now();
    final (from, to) = state.period.range(now);

    var failures = 0;
    var successes = 0;
    Object? firstError;

    /// Bo'lak kelishi bilan pulsga qo'shiladi; xatosi jim sanaladi.
    Future<void> part<T>(
      Future<T> future,
      HotelPulse Function(HotelPulse pulse, T value) merge,
    ) async {
      try {
        final value = await future;
        if (seq != _seq || isClosed) return;
        successes++;
        emit(state.copyWith(pulse: merge(state.pulse, value)));
      } catch (e) {
        if (seq != _seq || isClosed) return;
        failures++;
        firstError ??= e;
      }
    }

    await Future.wait([
      part(_repository.getRooms(), (p, v) => p.copyWith(rooms: v)),
      part(
        _bookings.getBookings(date: now),
        (p, v) => p.copyWith(bookings: v),
      ),
      part(_repository.getTasks(), (p, v) => p.copyWith(tasks: v)),
      part(
        _repository.getFinanceSummary(from: from, to: to),
        (p, v) => p.copyWith(finance: v),
      ),
      part(
        _repository.getIncomeDays(now),
        (p, v) => p.copyWith(incomeDays: v),
      ),
      part(
        _repository.getOverdueRoomCount(),
        (p, v) => p.copyWith(overdueRooms: v),
      ),
      if (access?.canViewFeedback ?? true)
        part(_repository.getFeedback(status: 'NEW'), (p, v) {
          final (items, total) = v;
          final complaints = items.where((f) => f.isComplaint).length;
          return p.copyWith(newComplaints: complaints, openFeedback: total);
        }),
      part(_repository.getDebtors(), (p, v) {
        final (count, total) = v;
        return p.copyWith(debtorCount: count, debtTotal: total);
      }),
      part(
        _repository.getProblems(status: 'OPEN'),
        (p, v) => p.copyWith(openProblems: v.length),
      ),
      part(_loadShifts(), (p, v) {
        final (open, pending) = v;
        return p.copyWith(openShifts: open, pendingHandovers: pending);
      }),
      part(_repository.getStaff(), (p, v) {
        final active = v.where((s) => s.isActive && !s.isAdmin).toList();
        return p.copyWith(
          staffTotal: active.length,
          staffOnDuty: active.where((s) => s.isOnDuty(now)).length,
        );
      }),
    ]);

    if (seq != _seq || isClosed) return;
    final total = failures + successes;
    emit(
      state.copyWith(
        loading: false,
        updatedAt: DateTime.now(),
        failedSections: failures,
        // Hamma bo'lak yiqilgan va ko'rsatadigan narsa yo'q — xato ekrani.
        // Bitta-ikkitasi yiqilsa ekran turadi, faqat chiziq ogohlantiradi.
        error: (failures == total && !state.hasData) ? firstError : null,
        clearError: !(failures == total && !state.hasData),
      ),
    );
  }

  /// Kassa rejimida ochiq va topshirilayotgan smenalar soni.
  Future<(int, int)> _loadShifts() async {
    final mode = await _repository.getShiftMode();
    if (mode != 'cash') return (0, 0);
    final sessions = await _repository.getShiftHistory(limit: 50);
    return (
      sessions.where((s) => s.isOpen).length,
      sessions.where((s) => s.isPendingHandover).length,
    );
  }

  Future<void> selectPeriod(PulsePeriod period) async {
    if (period == state.period) return;
    emit(state.copyWith(period: period, financeLoading: true));
    final (from, to) = period.range(DateTime.now());
    final seq = ++_seq;
    try {
      final finance = await _repository.getFinanceSummary(from: from, to: to);
      if (seq != _seq || isClosed) return;
      emit(
        state.copyWith(
          financeLoading: false,
          pulse: state.pulse.copyWith(finance: finance),
        ),
      );
    } catch (_) {
      if (seq != _seq || isClosed) return;
      emit(state.copyWith(financeLoading: false));
    }
  }

  @override
  Future<void> close() {
    _poller?.cancel();
    return super.close();
  }
}
