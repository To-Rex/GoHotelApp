import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/report_repository.dart';
import '../../domain/my_report.dart';

/// Hisobot davri — vebdagi tez tanlovlar bilan bir xil.
enum ReportPeriod {
  today,
  yesterday,
  last7,
  thisMonth;

  /// (boshlanish, tugash) — mahalliy kun bo'yicha.
  (DateTime, DateTime) range(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    return switch (this) {
      ReportPeriod.today => (today, today),
      ReportPeriod.yesterday => (
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 1)),
      ),
      ReportPeriod.last7 => (today.subtract(const Duration(days: 6)), today),
      ReportPeriod.thisMonth => (DateTime(now.year, now.month, 1), today),
    };
  }
}

class ReportState extends Equatable {
  const ReportState({
    this.loading = true,
    this.period = ReportPeriod.today,
    this.report,
    this.error,
  });

  final bool loading;
  final ReportPeriod period;
  final MyReport? report;
  final Object? error;

  ReportState copyWith({
    bool? loading,
    ReportPeriod? period,
    MyReport? report,
    Object? error,
    bool clearError = false,
  }) => ReportState(
    loading: loading ?? this.loading,
    period: period ?? this.period,
    report: report ?? this.report,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loading, period, report, error];
}

/// Shaxsiy hisobot: davr tanlanadi, raqamlar serverdan keladi.
///
/// Davr KALIT sifatida saqlanadi, sanalar esa har so'rovda qaytadan
/// hisoblanadi — ilova yarim tundan o'tib ochiq qolsa ham "Bugun"
/// haqiqiy bugunni bildiradi.
class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._repository) : super(const ReportState());

  final ReportRepository _repository;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(loading: true, clearError: true));
    final (from, to) = state.period.range(DateTime.now());
    try {
      final report = await _repository.getMyReport(from: from, to: to);
      emit(state.copyWith(loading: false, report: report, clearError: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: silent ? null : e));
    }
  }

  void selectPeriod(ReportPeriod period) {
    emit(state.copyWith(period: period, loading: true));
    load(silent: true);
  }
}
