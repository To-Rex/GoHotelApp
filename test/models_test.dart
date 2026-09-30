import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/features/chat/domain/staff_message.dart';
import 'package:gohotels/features/housekeeper/rooms/domain/occupied_room.dart';
import 'package:gohotels/features/housekeeper/tasks/domain/cleaning_task.dart';

void main() {
  group('CleaningTask.fromJson', () {
    test('backend mobil javobini to\'liq o\'qiydi', () {
      final task = CleaningTask.fromJson({
        'id': 't1',
        'room_number': '101',
        'floor': '1-qavat',
        'room_type': 'Standart',
        'guest': 'N. Norqulov',
        'guest_status': "Bo'shatilgan",
        'status': 'inProgress',
        'progress': 60,
        'deadline': '14:00',
        'note': 'General tozalash',
        'is_urgent': true,
        'checklist': [
          {'id': 'c1', 'title': "To'shak", 'is_completed': true},
          {'id': 'c2', 'title': 'Chang', 'is_completed': false},
        ],
      });

      expect(task.status, TaskStatus.inProgress);
      expect(task.progress, 60);
      expect(task.isUrgent, isTrue);
      expect(task.checklist, hasLength(2));
      expect(task.completedCount, 1);
    });

    test('yetishmagan maydonlarda yiqilmaydi', () {
      final task = CleaningTask.fromJson({'id': 't2', 'status': 'pending'});
      expect(task.roomNumber, '—');
      expect(task.checklist, isEmpty);
      expect(task.status, TaskStatus.pending);
    });
  });

  group('OccupiedRoom.fromJson', () {
    test('chiqish vaqti va kechikish o\'qiladi', () {
      final room = OccupiedRoom.fromJson({
        'room_id': 'r1',
        'room_number': '204',
        'room_status': 'OCCUPIED',
        'reservation_status': 'CHECKED_IN',
        'guest_name': 'A. Karimov',
        'booking_type': 'DAILY',
        'expected_checkout': '2026-09-03T12:00:00',
        'minutes_until_checkout': -30,
        'is_overdue': true,
      });

      expect(room.isCheckedIn, isTrue);
      expect(room.isOverdue, isTrue);
      expect(room.expectedCheckout, isNotNull);
    });
  });

  group('StaffMessage.fromJson', () {
    test('ochiq va bajarilgan holatlar', () {
      final open = StaffMessage.fromJson({
        'id': 'm1',
        'body': '104-xonani tekshiring',
        'status': 'OPEN',
        'created_by': 'u1',
        'created_by_name': 'Dilnoza',
        'room_number': '104',
      });
      expect(open.isOpen, isTrue);

      final done = StaffMessage.fromJson({
        'id': 'm2',
        'body': 'OK',
        'status': 'DONE',
        'created_by': 'u2',
        'created_by_name': 'Aziz',
        'done_by_name': 'Malika',
      });
      expect(done.isOpen, isFalse);
      expect(done.doneByName, 'Malika');
    });
  });
}
