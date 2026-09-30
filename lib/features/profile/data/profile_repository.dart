import 'package:dio/dio.dart';

import '../../../core/config/api_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_store.dart';
import '../domain/work_stats.dart';

/// Profil: surat va ish statistikasi.
class ProfileRepository {
  ProfileRepository({required this.api, required this.tokens});

  final ApiClient api;
  final TokenStore tokens;

  /// Xodimning profil surati (bo'lsa) — fayl ID qaytadi.
  ///
  /// Suratlar frontend bilan bir xil joyda saqlanadi:
  /// entity_type="user", category="photo".
  Future<String?> getMyPhotoFileId(String userId) async {
    final data = await api.get<List<dynamic>>(
      '/files/by-entity',
      query: {
        'entity_type': 'user',
        'entity_id': userId,
        'category': 'photo',
        'limit': 1,
      },
    );
    if (data.isEmpty) return null;
    return (data.first as Map<String, dynamic>)['id'] as String?;
  }

  /// O'z suratini yuklash (`file.upload` ruxsati kerak).
  Future<void> uploadMyPhoto(String userId, String imagePath) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(imagePath),
      'entity_type': 'user',
      'entity_id': userId,
      'category': 'photo',
    });
    await api.post<Map<String, dynamic>>('/files/upload', data: form);
  }

  String photoUrl(String fileId) =>
      '${ApiConfig.baseUrl}/files/$fileId/download';

  Map<String, String> photoHeaders() => {
    'Authorization': 'Bearer ${tokens.accessToken ?? ''}',
  };

  /// Statistika: xodimga biriktirilgan housekeeping vazifalaridan.
  ///
  /// `started_at`/`completed_at` maydonlari bor, shuning uchun o'rtacha
  /// tozalash vaqtini ham hisoblab beramiz.
  Future<WorkStats> getWorkStats(String userId) async {
    final data = await api.get<List<dynamic>>(
      '/housekeeping/tasks',
      query: {'assigned_to': userId, 'limit': 200},
    );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month);

    var completedToday = 0;
    var completedWeek = 0;
    var completedMonth = 0;
    var inProgress = 0;
    var durationTotalMinutes = 0;
    var durationCount = 0;

    for (final raw in data) {
      final task = raw as Map<String, dynamic>;
      final status = task['status'] as String? ?? '';
      if (status == 'IN_PROGRESS') inProgress++;
      if (status != 'COMPLETED') continue;

      final completedAt = DateTime.tryParse(
        task['completed_at'] as String? ?? '',
      );
      if (completedAt == null) continue;
      if (!completedAt.isBefore(monthStart)) completedMonth++;
      if (!completedAt.isBefore(weekStart)) completedWeek++;
      if (!completedAt.isBefore(today)) completedToday++;

      final startedAt = DateTime.tryParse(task['started_at'] as String? ?? '');
      if (startedAt != null && completedAt.isAfter(startedAt)) {
        final minutes = completedAt.difference(startedAt).inMinutes;
        // 8 soatdan uzun "tozalash" — unutilgan vazifa, o'rtachani buzmasin.
        if (minutes > 0 && minutes <= 480) {
          durationTotalMinutes += minutes;
          durationCount++;
        }
      }
    }

    return WorkStats(
      completedToday: completedToday,
      completedThisWeek: completedWeek,
      completedThisMonth: completedMonth,
      inProgress: inProgress,
      avgMinutes: durationCount == 0
          ? 0
          : (durationTotalMinutes ~/ durationCount),
    );
  }
}
