import 'package:equatable/equatable.dart';

import '../../reception/bookings/domain/booking.dart';
import 'finance_summary.dart';
import 'hk_task.dart';
import 'room_tile.dart';

/// Mehmonxonaning bugungi "pulsi" — boshqaruv ekrani uchun yig'ma.
///
/// Har bo'lak MUSTAQIL yuklanadi: moliya yiqilsa xonalar baribir
/// ko'rinadi. Shu sababli hammasi ixtiyoriy, hisoblar esa borini
/// hisoblaydi.
class HotelPulse extends Equatable {
  const HotelPulse({
    this.rooms,
    this.bookings,
    this.tasks,
    this.finance,
    this.incomeDays,
    this.overdueRooms = 0,
    this.newComplaints = 0,
    this.openFeedback = 0,
    this.debtorCount = 0,
    this.debtTotal = 0,
    this.openProblems = 0,
    this.openShifts = 0,
    this.pendingHandovers = 0,
    this.staffOnDuty = 0,
    this.staffTotal = 0,
  });

  final List<RoomTile>? rooms;
  final List<Booking>? bookings;
  final List<HkTask>? tasks;
  final FinanceSummary? finance;
  final List<IncomeDay>? incomeDays;

  /// Chiqish vaqti o'tib ketgan xonalar.
  final int overdueRooms;
  final int newComplaints;
  final int openFeedback;
  final int debtorCount;
  final double debtTotal;
  final int openProblems;
  final int openShifts;
  final int pendingHandovers;
  final int staffOnDuty;
  final int staffTotal;

  // --- Xonalar ------------------------------------------------------------

  int get roomCount => rooms?.length ?? 0;

  int countRooms(RoomState state) =>
      rooms?.where((r) => r.state == state).length ?? 0;

  int get occupiedRooms => countRooms(RoomState.occupied);
  int get reservedRooms => countRooms(RoomState.reserved);
  int get cleaningRooms => countRooms(RoomState.cleaning);
  int get availableRooms => countRooms(RoomState.available);

  /// Xizmatdan tashqari/ta'mir/tekshiruvdagi xonalar.
  int get blockedRooms =>
      countRooms(RoomState.maintenance) +
      countRooms(RoomState.inspection) +
      countRooms(RoomState.outOfService);

  /// Bandlik: mehmon bor xonalar / hamma xonalar (0..1).
  double get occupancy => roomCount == 0 ? 0 : occupiedRooms / roomCount;

  // --- Bronlar ------------------------------------------------------------

  int countBookings(BookingKind kind) =>
      bookings?.where((b) => b.kind == kind && b.status != 'CANCELLED').length ??
      0;

  int get arrivals => countBookings(BookingKind.arrival);
  int get departures => countBookings(BookingKind.departure);
  int get inHouse => countBookings(BookingKind.inhouse);

  // --- Vazifalar ----------------------------------------------------------

  int get openTasks => tasks?.where((t) => t.isOpen).length ?? 0;
  int get tasksInProgress => tasks?.where((t) => t.isInProgress).length ?? 0;

  /// Hali hech kimga biriktirilmagan ochiq vazifalar.
  int get unassignedTasks =>
      tasks?.where((t) => t.isOpen && t.assignedTo == null).length ?? 0;

  int completedTasksOn(DateTime day) =>
      tasks
          ?.where(
            (t) =>
                t.isDone &&
                t.completedAt != null &&
                t.completedAt!.year == day.year &&
                t.completedAt!.month == day.month &&
                t.completedAt!.day == day.day,
          )
          .length ??
      0;

  /// E'tibor talab qiladigan holatlar soni — sarlavhadagi belgi uchun.
  int get attentionCount =>
      newComplaints +
      overdueRooms +
      openProblems +
      pendingHandovers +
      (debtorCount > 0 ? 1 : 0);

  HotelPulse copyWith({
    List<RoomTile>? rooms,
    List<Booking>? bookings,
    List<HkTask>? tasks,
    FinanceSummary? finance,
    List<IncomeDay>? incomeDays,
    int? overdueRooms,
    int? newComplaints,
    int? openFeedback,
    int? debtorCount,
    double? debtTotal,
    int? openProblems,
    int? openShifts,
    int? pendingHandovers,
    int? staffOnDuty,
    int? staffTotal,
  }) => HotelPulse(
    rooms: rooms ?? this.rooms,
    bookings: bookings ?? this.bookings,
    tasks: tasks ?? this.tasks,
    finance: finance ?? this.finance,
    incomeDays: incomeDays ?? this.incomeDays,
    overdueRooms: overdueRooms ?? this.overdueRooms,
    newComplaints: newComplaints ?? this.newComplaints,
    openFeedback: openFeedback ?? this.openFeedback,
    debtorCount: debtorCount ?? this.debtorCount,
    debtTotal: debtTotal ?? this.debtTotal,
    openProblems: openProblems ?? this.openProblems,
    openShifts: openShifts ?? this.openShifts,
    pendingHandovers: pendingHandovers ?? this.pendingHandovers,
    staffOnDuty: staffOnDuty ?? this.staffOnDuty,
    staffTotal: staffTotal ?? this.staffTotal,
  );

  @override
  List<Object?> get props => [
    rooms,
    bookings,
    tasks,
    finance,
    incomeDays,
    overdueRooms,
    newComplaints,
    openFeedback,
    debtorCount,
    debtTotal,
    openProblems,
    openShifts,
    pendingHandovers,
    staffOnDuty,
    staffTotal,
  ];
}
