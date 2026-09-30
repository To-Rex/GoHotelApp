import 'package:equatable/equatable.dart';

/// Xodimning ish statistikasi — housekeeping vazifalaridan hisoblanadi.
class WorkStats extends Equatable {
  const WorkStats({
    required this.completedToday,
    required this.completedThisWeek,
    required this.completedThisMonth,
    required this.inProgress,
    required this.avgMinutes,
  });

  static const empty = WorkStats(
    completedToday: 0,
    completedThisWeek: 0,
    completedThisMonth: 0,
    inProgress: 0,
    avgMinutes: 0,
  );

  final int completedToday;
  final int completedThisWeek;
  final int completedThisMonth;
  final int inProgress;

  /// O'rtacha tozalash vaqti (started_at → completed_at), daqiqada.
  final int avgMinutes;

  @override
  List<Object?> get props => [
    completedToday,
    completedThisWeek,
    completedThisMonth,
    inProgress,
    avgMinutes,
  ];
}
