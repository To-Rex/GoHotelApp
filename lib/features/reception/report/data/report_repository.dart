import '../../../../core/network/api_client.dart';
import '../domain/my_report.dart';

/// Xodimning shaxsiy hisoboti (`/api/v1/reports/my-summary`).
///
/// Endpoint ruxsat talab qilmaydi va HAR DOIM faqat so'rovchining o'z
/// ma'lumotini qaytaradi — `user_id` tokendan olinadi, so'rovdan emas.
class ReportRepository {
  ReportRepository(this._api);

  final ApiClient _api;

  Future<MyReport> getMyReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/reports/my-summary',
      query: {'date_from': _isoDate(from), 'date_to': _isoDate(to)},
    );
    return MyReport.fromJson(data);
  }

  /// Sana MAHALLIY zonada: `toIso8601String()` UTC ga o'tkazib tungi
  /// soatlarda kunni bir kun orqaga surib yuborardi.
  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
