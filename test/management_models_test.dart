import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/features/auth/domain/staff_user.dart';
import 'package:gohotels/features/management/domain/finance_summary.dart';
import 'package:gohotels/features/management/domain/format.dart';
import 'package:gohotels/features/management/domain/guest_feedback.dart';
import 'package:gohotels/features/management/domain/hk_task.dart';
import 'package:gohotels/features/management/domain/hotel_pulse.dart';
import 'package:gohotels/features/management/domain/management_access.dart';
import 'package:gohotels/features/management/domain/room_tile.dart';
import 'package:gohotels/features/management/domain/shift_session.dart';
import 'package:gohotels/features/management/domain/staff_member.dart';
import 'package:gohotels/features/management/presentation/cubit/room_map_cubit.dart';
import 'package:gohotels/features/reception/bookings/domain/booking.dart';

/// Boshqaruv moduli: modellar backend javobini to'g'ri o'qiydimi, hisoblar
/// (bandlik, ish vaqti, joylashuv tartibi) va ruxsat xaritasi.
void main() {
  group('RoomTile / RoomState', () {
    test('backend javobi va noma\'lum holat', () {
      final room = RoomTile.fromJson({
        'id': 'r1',
        'room_number': '101',
        'current_status': 'CLEANING',
        'floor_id': 'f1',
        'branch_id': 'b1',
        'capacity': 2,
        'base_price': 350000,
        'status_changed_at': '2026-09-30T05:00:00+00:00',
      });
      expect(room.state, RoomState.cleaning);
      expect(room.capacity, 2);
      expect(room.statusChangedAt, isNotNull);
      expect(RoomState.fromApi('nimadir'), RoomState.other);
      expect(RoomState.fromApi(null), RoomState.other);
    });

    test('band va bron holatlari qo\'lda o\'rnatilmaydi', () {
      expect(RoomState.manual, isNot(contains(RoomState.occupied)));
      expect(RoomState.manual, isNot(contains(RoomState.reserved)));
      expect(RoomState.occupied.isBusy, isTrue);
      expect(RoomState.cleaning.isBusy, isFalse);
    });

    test('hamrohlardan ketganlari ko\'rinmaydi', () {
      final stay = RoomStay.fromJson({
        'id': 's1',
        'reservation_number': 'RES-1',
        'status': 'CHECKED_IN',
        'guest_name': 'Ali',
        'check_in_date': '2026-09-30',
        'check_out_date': '2026-10-02',
        'adults': 3,
        'total_amount': 100,
        'paid_amount': 40,
        'companions': [
          {'guest_id': 'g1', 'name': 'Vali'},
          {'guest_id': 'g2', 'name': 'Soli', 'left_at': '2026-09-30T10:00:00'},
        ],
      });
      expect(stay.companions, ['Vali']);
      expect(stay.debt, 60);
      expect(stay.isActive, isTrue);
    });
  });

  group('RoomMapState.groups', () {
    RoomTile room(String n, String floor, RoomState s) => RoomTile(
      id: n,
      number: n,
      state: s,
      floorId: floor,
      branchId: 'b',
    );

    test('qavatlar raqam bo\'yicha, xonalar raqamli tartibda', () {
      final state = RoomMapState(
        loading: false,
        rooms: [
          room('201', 'f2', RoomState.available),
          room('110', 'f1', RoomState.occupied),
          room('2', 'f1', RoomState.cleaning),
          room('999', 'yoq', RoomState.available),
        ],
        floors: const {
          'f1': FloorInfo(id: 'f1', number: 1),
          'f2': FloorInfo(id: 'f2', number: 2),
        },
      );
      final groups = state.groups;
      expect(groups.map((g) => g.floor?.number), [1, 2, null]);
      // 2 < 110 — matn tartibida ("110" < "2") teskari bo'lardi
      expect(groups.first.rooms.map((r) => r.number), ['2', '110']);
    });

    test('filtr faqat tanlangan holatni qoldiradi', () {
      final state = RoomMapState(
        loading: false,
        rooms: [
          room('1', 'f1', RoomState.available),
          room('2', 'f1', RoomState.occupied),
        ],
        filter: RoomState.occupied,
      );
      expect(state.groups.single.rooms.single.number, '2');
      expect(state.countOf(RoomState.available), 1);
    });
  });

  group('FinanceSummary', () {
    test('serverdagi maydonlar o\'qiladi, sof natija = tushum + do\'kon − xarajat (veb bilan bir xil)', () {
      final f = FinanceSummary.fromJson({
        'income': 1500000,
        'payment_count': 12,
        'refunds': 50000,
        'invoice_total': 2000000,
        'invoice_count': 10,
        'debt': 500000,
        'expense_total': 300000,
        'expense_count': 3,
        // Server do'konni shu nomlar bilan yuboradi
        'shop_revenue': 120000,
        'shop_paid_count': 4,
        'methods': [
          {'key': 'CASH', 'total': 1000000, 'count': 8},
          {'key': 'card', 'total': 500000, 'count': 4},
        ],
      });
      expect(f.shopTotal, 120000);
      expect(f.shopCount, 4);
      expect(f.revenue, 1620000);
      expect(f.net, 1320000);
      // Eski nom ham o'qiladi
      expect(FinanceSummary.fromJson({'shop_total': 5}).shopTotal, 5);
      expect(f.methods.first.key, 'cash');
      expect(f.methods.map((m) => m.total), [1000000, 500000]);
    });

    test('server shakli: pay + shop, eski kodlar o\'z usuliga yig\'iladi', () {
      final f = FinanceSummary.fromJson({
        'income': 900,
        'methods': [
          {'key': 'CASH', 'pay': 300.0, 'shop': 100.0, 'expense': 50.0},
          {'key': 'CREDIT_CARD', 'pay': 200.0, 'shop': 0.0, 'expense': 0.0},
          {'key': 'DEBIT_CARD', 'pay': 250.0, 'shop': 50.0, 'expense': 0.0},
          {'key': 'UNKNOWN', 'pay': 0.0, 'shop': 0.0, 'expense': 70.0},
        ],
      });
      final byKey = {for (final m in f.methods) m.key: m.total};
      // Xarajat tushum ulushiga kirmaydi
      expect(byKey['cash'], 400);
      // Ikkala eski karta kodi bitta "card" ga
      expect(byKey['card'], 500);
      expect(byKey['other'], 0);
      // Usul bo'yicha xarajat alohida saqlanadi; ulush faqat tushumdan
      expect(f.method('cash').expense, 50);
      expect(f.method('other').expense, 70);
      expect(f.methodsTotal, 900);
      // Harakat bo'lmagan usul — nol yozuv (qator baribir chiziladi)
      expect(f.method('online').total, 0);
      expect(f.method('bank_transfer').expense, 0);
    });

    test('bo\'sh javob nolga tushadi', () {
      expect(FinanceSummary.fromJson(const {}).income, 0);
      expect(FinanceSummary.fromJson(const {}).methods, isEmpty);
    });
  });

  group('HotelPulse hisoblari', () {
    RoomTile room(RoomState s) => RoomTile(
      id: s.name,
      number: '1',
      state: s,
      floorId: 'f',
      branchId: 'b',
    );
    Booking booking(BookingKind kind, {String status = 'CONFIRMED'}) => Booking(
      id: kind.name + status,
      reservationNumber: 'R',
      guestName: 'G',
      roomNumber: '1',
      bookingType: 'DAILY',
      checkInDate: '',
      checkOutDate: '',
      status: status,
      paymentStatus: 'PAID',
      totalAmount: 0,
      paidAmount: 0,
      adults: 1,
      children: 0,
      kind: kind,
    );

    test('bandlik = band xonalar / hamma xonalar', () {
      final pulse = HotelPulse(
        rooms: [
          room(RoomState.occupied),
          room(RoomState.occupied),
          room(RoomState.available),
          room(RoomState.cleaning),
        ],
      );
      expect(pulse.occupancy, 0.5);
      expect(pulse.cleaningRooms, 1);
      expect(const HotelPulse().occupancy, 0);
    });

    test('bekor qilingan bronlar kelish/chiqishga qo\'shilmaydi', () {
      final pulse = HotelPulse(
        bookings: [
          booking(BookingKind.arrival),
          booking(BookingKind.arrival, status: 'CANCELLED'),
          booking(BookingKind.departure),
        ],
      );
      expect(pulse.arrivals, 1);
      expect(pulse.departures, 1);
    });

    test('biriktirilmagan vazifalar va bugun bajarilganlar', () {
      final now = DateTime.now();
      HkTask task(String status, {String? to, DateTime? done}) => HkTask(
        id: '$status$to$done',
        roomId: 'r',
        roomNumber: '1',
        taskType: 'CLEANING',
        status: status,
        priority: 'MEDIUM',
        createdAt: now,
        checklistDone: 0,
        checklistTotal: 0,
        autoCompleted: false,
        assignedTo: to,
        completedAt: done,
      );
      final pulse = HotelPulse(
        tasks: [
          task('OPEN'),
          task('OPEN', to: 'u1'),
          task('IN_PROGRESS', to: 'u1'),
          task('COMPLETED', to: 'u1', done: now),
          task('COMPLETED', to: 'u1', done: now.subtract(const Duration(days: 2))),
        ],
      );
      expect(pulse.unassignedTasks, 1);
      expect(pulse.openTasks, 2);
      expect(pulse.tasksInProgress, 1);
      expect(pulse.completedTasksOn(now), 1);
    });
  });

  group('StaffMember', () {
    StaffMember member(String start, String end) => StaffMember(
      id: 'u',
      userType: 'EMPLOYEE',
      username: 'u',
      firstName: 'A',
      lastName: 'B',
      status: 'ACTIVE',
      workStart: start,
      workEnd: end,
    );

    test('kunduzgi va tungi smenada ish vaqti', () {
      final day = member('09:00', '18:00');
      expect(day.isOnDuty(DateTime(2026, 1, 1, 10)), isTrue);
      expect(day.isOnDuty(DateTime(2026, 1, 1, 20)), isFalse);
      final night = member('22:00', '06:00');
      expect(night.isOnDuty(DateTime(2026, 1, 1, 23)), isTrue);
      expect(night.isOnDuty(DateTime(2026, 1, 1, 3)), isTrue);
      expect(night.isOnDuty(DateTime(2026, 1, 1, 12)), isFalse);
    });

    test('buzuq vaqt — doim ish vaqtida deb olinadi', () {
      expect(member('', '').isOnDuty(DateTime.now()), isTrue);
    });

    test('backend javobi', () {
      final s = StaffMember.fromJson({
        'id': 'u1',
        'user_type': 'EMPLOYEE',
        'username': 'farrosh',
        'first_name': 'Ali',
        'last_name': 'Valiyev',
        'status': 'ACTIVE',
        'last_login_at': DateTime.now().toUtc().toIso8601String(),
      });
      expect(s.fullName, 'Ali Valiyev');
      expect(s.wasRecentlyOnline(DateTime.now()), isTrue);
      expect(s.isAdmin, isFalse);
    });
  });

  group('ShiftSession', () {
    test('ochiq smena davomiyligi hozirgacha, yopilgani tugash vaqtigacha', () {
      final start = DateTime(2026, 1, 1, 8);
      final open = ShiftSession(
        id: 's',
        userId: 'u',
        status: 'ACTIVE',
        openingCash: 0,
        forceClosed: false,
        startedAt: start,
      );
      expect(open.elapsed(DateTime(2026, 1, 1, 10, 30)), const Duration(hours: 2, minutes: 30));
      expect(open.isOpen, isTrue);
      final closed = ShiftSession.fromJson({
        'id': 's2',
        'user_id': 'u',
        'status': 'CLOSED',
        'started_at': '2026-01-01T08:00:00',
        'ended_at': '2026-01-01T09:00:00',
        'counted_cash': 100.0,
        'cash_diff': -5.0,
      });
      expect(closed.elapsed(DateTime(2026, 1, 2)), const Duration(hours: 1));
      expect(closed.cashDiff, -5);
      expect(closed.isOpen, isFalse);
    });
  });

  group('GuestFeedback / StaffProblem', () {
    test('holat va tur bayroqlari', () {
      final f = GuestFeedback.fromJson({
        'id': 'f1',
        'feedback_type': 'COMPLAINT',
        'status': 'NEW',
        'priority': 'HIGH',
        'subject': 'Shovqin',
        'body': '...',
        'created_at': '2026-09-30T10:00:00',
      });
      expect(f.isComplaint, isTrue);
      expect(f.isOpen, isTrue);
      expect(f.isNew, isTrue);
      final p = StaffProblem.fromJson({
        'id': 'p1',
        'category': 'Santexnika',
        'description': 'Kran oqadi',
        'status': 'OPEN',
      });
      expect(p.isOpen, isTrue);
      expect(p.withStatus('RESOLVED').isOpen, isFalse);
    });
  });

  group('ManagementAccess', () {
    StaffUser user(String type, List<String> perms) => StaffUser(
      id: 'u',
      userType: type,
      username: 'u',
      firstName: 'A',
      lastName: 'B',
      permissions: perms,
    );

    test('admin hamma amalga ruxsatli, e\'lon faqat adminda', () {
      final a = ManagementAccess.of(user('ADMIN', const []));
      expect(a.canBroadcast, isTrue);
      expect(a.canForceClose, isTrue);
      expect(a.canManageFeedback, isTrue);
    });

    test('menejer: ruxsat kodlariga qarab, e\'lonsiz', () {
      final m = ManagementAccess.of(
        user('EMPLOYEE', const [
          'shift.force_close',
          'housekeeping.task.assign',
          'housekeeping.task.update',
        ]),
      );
      expect(m.canBroadcast, isFalse);
      expect(m.canForceClose, isTrue);
      expect(m.canAssignTask, isTrue);
      expect(m.canResolveProblems, isTrue);
      expect(m.canManageFeedback, isTrue);
      expect(m.canSetRoomStatus, isFalse);
      expect(m.canCreateTask, isFalse);
    });
  });

  group('format', () {
    test('pul ming ajratgichi va qisqa shakl', () {
      expect(formatMoney(1250000), '1 250 000');
      expect(formatMoney(-5000), '-5 000');
      expect(compactMoney(1250000, thousand: 'ming', million: 'mln'), '1,3 mln');
      expect(compactMoney(850000, thousand: 'ming', million: 'mln'), '850 ming');
      expect(compactMoney(12500, thousand: 'ming', million: 'mln'), '12 500');
    });

    test('davomiylik, foiz, sana', () {
      expect(formatDuration(const Duration(minutes: 35), h: 's', m: 'd'), '35 d');
      expect(formatDuration(const Duration(hours: 2, minutes: 5), h: 's', m: 'd'), '2 s 5 d');
      expect(formatPercent(0.724), '72%');
      final now = DateTime(2026, 9, 30, 15);
      expect(formatWhen(DateTime(2026, 9, 30, 9, 5), now), '09:05');
      expect(formatWhen(DateTime(2026, 9, 2, 9, 5), now), '02.09, 09:05');
      expect(isoDate(DateTime(2026, 1, 9)), '2026-01-09');
    });
  });
}
