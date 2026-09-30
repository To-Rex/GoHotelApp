import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_store.dart';
import '../domain/staff_message.dart';

/// Xodimlar chati (staff messages taxtasi) + xabarga rasm biriktirish.
class ChatRepository {
  ChatRepository({required this.api, required this.tokens});

  final ApiClient api;
  final TokenStore tokens;

  static const _entityType = 'staff_message';

  Future<List<StaffMessage>> getMessages({int days = 2}) async {
    final data = await api.get<List<dynamic>>(
      '/messages/',
      query: {'days': days, 'limit': 200},
    );
    return data
        .map((e) => StaffMessage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<StaffMessage> sendMessage(String body, {String? roomId}) async {
    final data = await api.post<Map<String, dynamic>>(
      '/messages/',
      data: {'body': body, 'room_id': ?roomId},
    );
    return StaffMessage.fromJson(data);
  }

  Future<StaffMessage> markDone(String messageId) async {
    final data = await api.post<Map<String, dynamic>>(
      '/messages/$messageId/done',
    );
    return StaffMessage.fromJson(data);
  }

  /// Xabarga rasm biriktirish. `file.upload` ruxsati bo'lmasa 403 qaytadi —
  /// UI buni tushunarli xabar bilan ko'rsatadi.
  Future<void> attachImage({
    required String messageId,
    required String imagePath,
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
      'entity_type': _entityType,
      'entity_id': messageId,
      'category': 'photo',
    });
    await api.post<Map<String, dynamic>>('/files/upload', data: form);
  }

  /// Taxtadagi barcha xabar-rasmlari bitta so'rovda (xabar id → fayllar).
  Future<Map<String, List<MessageAttachment>>> getAttachments() async {
    final data = await api.get<List<dynamic>>(
      '/files/by-entity',
      query: {'entity_type': _entityType},
    );
    final result = <String, List<MessageAttachment>>{};
    for (final row in data) {
      final attachment = MessageAttachment.fromJson(
        row as Map<String, dynamic>,
      );
      if (!attachment.isImage) continue;
      result.putIfAbsent(attachment.entityId, () => []).add(attachment);
    }
    return result;
  }

  /// Rasmni backend orqali (avtorizatsiya bilan) ko'rsatish uchun URL.
  String imageUrl(String fileId) =>
      '${ApiConfig.baseUrl}/files/$fileId/download';

  /// Rasm so'roviga qo'shiladigan sarlavhalar.
  Map<String, String> imageHeaders() => {
    'Authorization': 'Bearer ${tokens.accessToken ?? ''}',
  };
}
