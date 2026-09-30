import '../../../../core/network/api_client.dart';
import '../domain/incoming_call.dart';

/// Kiruvchi qo'ng'iroqlar (`/api/v1/reception/calls`).
class CallsRepository {
  CallsRepository(this._api);

  final ApiClient _api;

  /// Qo'ng'iroq haqida xabar beradi va topilgan mehmonni qaytaradi.
  Future<IncomingCall> report(String phone, {String? deviceId}) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/reception/calls',
      data: {'phone': phone, 'device_id': ?deviceId},
    );
    return IncomingCall.fromJson(data);
  }
}
