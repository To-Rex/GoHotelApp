import '../../../core/network/api_client.dart';
import '../domain/staff_notification.dart';

class NotificationsRepository {
  NotificationsRepository(this._api);

  final ApiClient _api;

  Future<List<StaffNotification>> getNotifications({int limit = 50}) async {
    final data = await _api.get<List<dynamic>>(
      '/notifications/',
      query: {'limit': limit},
    );
    return data
        .map((e) => StaffNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markRead(String id) async {
    await _api.put<Map<String, dynamic>>('/notifications/$id/read');
  }

  Future<void> markAllRead() async {
    await _api.put<Map<String, dynamic>>('/notifications/read-all');
  }
}
