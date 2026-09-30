import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/roles/role_registry.dart';
import 'package:gohotels/features/auth/domain/staff_user.dart';

StaffUser _user({
  String userType = 'EMPLOYEE',
  List<String> permissions = const [],
}) => StaffUser(
  id: 'u1',
  userType: userType,
  username: 'test',
  firstName: 'Test',
  lastName: 'User',
  permissions: permissions,
);

void main() {
  group('StaffUser.hasPermission', () {
    test('aniq kod mos keladi', () {
      final user = _user(permissions: ['room.view']);
      expect(user.hasPermission('room.view'), isTrue);
      expect(user.hasPermission('room.manage'), isFalse);
    });

    test('yulduzchali naqsh xodim kodlariga mos keladi', () {
      final user = _user(permissions: ['housekeeping.task.update']);
      expect(user.hasPermission('housekeeping.*'), isTrue);
      expect(user.hasPermission('reservation.*'), isFalse);
    });

    test('admin hamma narsaga ruxsatli', () {
      final admin = _user(userType: 'ADMIN');
      expect(admin.hasPermission('istalgan.kod'), isTrue);
    });
  });

  group('RoleRegistry.resolve', () {
    test('farrosh: housekeeping ruxsatlari bilan', () {
      // Frontend'dagi "Farrosh" shabloni bilan bir xil to'plam.
      final user = _user(
        permissions: [
          'room.view',
          'room.status.update',
          'housekeeping.task.update',
        ],
      );
      expect(RoleRegistry.resolve(user).id, 'housekeeper');
    });

    test('menejer farrosh emas (housekeeping.* bo\'lsa ham)', () {
      final user = _user(
        permissions: [
          'housekeeping.task.update',
          'housekeeping.task.assign',
          'shift.view',
          'employee.create',
        ],
      );
      expect(RoleRegistry.resolve(user).id, 'manager');
    });

    test('resepshn: reservation.create bilan', () {
      final user = _user(
        permissions: [
          'reservation.create',
          'reservation.view',
          'guest.create',
          'room.view',
          'room.status.update',
        ],
      );
      expect(RoleRegistry.resolve(user).id, 'reception');
    });

    test('usta: task.create bor, assign yo\'q', () {
      final user = _user(
        permissions: [
          'room.view',
          'room.status.update',
          'housekeeping.task.create',
          'housekeeping.task.update',
        ],
      );
      expect(RoleRegistry.resolve(user).id, 'maintenance');
    });

    test('admin har doim admin', () {
      expect(RoleRegistry.resolve(_user(userType: 'ADMIN')).id, 'admin');
      expect(RoleRegistry.resolve(_user(userType: 'SUPER_ADMIN')).id, 'admin');
    });

    test('ruxsatsiz xodim zaxira bo\'limga tushadi', () {
      expect(RoleRegistry.resolve(_user()).id, 'staff');
    });
  });
}
