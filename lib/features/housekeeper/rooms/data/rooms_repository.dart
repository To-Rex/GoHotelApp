import '../../../../core/network/api_client.dart';
import '../domain/occupied_room.dart';

/// Band xonalar ro'yxati — farrosh "qaysi xona qachon bo'shaydi"ni ko'radi.
class RoomsRepository {
  RoomsRepository(this._api);

  final ApiClient _api;

  /// Chiqishga eng yaqin xona birinchi keladi (kechikkanlar eng boshida).
  /// `includeReserved` — hali kirmagan (CONFIRMED) bronlar ham qo'shiladi.
  Future<List<OccupiedRoom>> getOccupiedRooms({
    bool includeReserved = true,
  }) async {
    final data = await _api.get<List<dynamic>>(
      '/housekeeping/occupied-rooms',
      query: {'include_reserved': includeReserved},
    );
    return data
        .map((e) => OccupiedRoom.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
