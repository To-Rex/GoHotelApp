import '../../../../core/debt/debt_reason.dart';
import '../../../../core/network/api_client.dart';
import '../domain/booking.dart';

/// Qabulxona bronlari (`/api/v1/reception/bookings`).
///
/// Ro'yxat serverda boyitiladi: mehmon nomi va xona raqami bilan birga
/// keladi, ya'ni telefon tarmog'ida uch marta kutish shart emas.
class BookingsRepository {
  BookingsRepository(this._api);

  final ApiClient _api;

  Future<List<Booking>> getBookings({
    required DateTime date,
    String? search,
    bool includeCancelled = false,
  }) async {
    final data = await _api.get<List<dynamic>>(
      '/reception/bookings',
      query: {
        'date': _isoDate(date),
        'search': ?_trimmed(search),
        if (includeCancelled) 'include_cancelled': true,
      },
    );
    return data
        .map((e) => Booking.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Bron qarzi va uning SABABLARI (`GET /reservations/{id}/debt`).
  Future<BookingDebt> getDebt(String reservationId) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/reservations/$reservationId/debt',
    );
    return BookingDebt.fromJson(data);
  }

  static String? _trimmed(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }

  /// Sana MAHALLIY zonada yoziladi: `toIso8601String()` UTC ga o'tkazib
  /// tungi soatlarda kunni bir kun orqaga surib yuborardi.
  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
