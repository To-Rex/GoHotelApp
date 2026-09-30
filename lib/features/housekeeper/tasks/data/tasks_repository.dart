import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/storage/token_store.dart';
import '../domain/cleaning_task.dart';

/// Farrosh vazifalari bilan ishlash (`/api/v1/tasks` — mobil API).
class TasksRepository {
  TasksRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  Future<List<CleaningTask>> getTasks({String? status, String? date}) async {
    final data = await _api.get<List<dynamic>>(
      '/tasks',
      query: {'status': ?status, 'date': ?date},
    );
    return data
        .map((e) => CleaningTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CleaningTask> getTask(String id) async {
    final data = await _api.get<Map<String, dynamic>>('/tasks/$id');
    return CleaningTask.fromJson(data);
  }

  Future<CleaningTask> startTask(String id) async {
    final data = await _api.put<Map<String, dynamic>>('/tasks/$id/start');
    return CleaningTask.fromJson(data);
  }

  /// Progress 100 bo'lsa server vazifani avtomatik yakunlaydi va (CLEANING
  /// turlarida) xonani AVAILABLE holatiga o'tkazadi.
  Future<CleaningTask> updateProgress(String id, int progress) async {
    final data = await _api.put<Map<String, dynamic>>(
      '/tasks/$id/progress',
      data: {'progress': progress},
    );
    return CleaningTask.fromJson(data);
  }

  Future<CleaningTask> toggleChecklistItem(String taskId, String itemId) async {
    final data = await _api.put<Map<String, dynamic>>(
      '/tasks/$taskId/checklist/$itemId/toggle',
    );
    return CleaningTask.fromJson(data);
  }

  Future<void> submitPhotoReport({
    required String taskId,
    required List<String> photoPaths,
    String? comment,
  }) async {
    final form = FormData();
    for (final path in photoPaths) {
      form.files.add(MapEntry('photos', await MultipartFile.fromFile(path)));
    }
    if (comment != null && comment.trim().isNotEmpty) {
      form.fields.add(MapEntry('comment', comment.trim()));
    }
    await _api.post<Map<String, dynamic>>('/tasks/$taskId/report', data: form);
  }

  /// Vazifaga avval yuborilgan hisobot rasmlarining ID ro'yxati.
  Future<List<String>> getTaskPhotoIds(String taskId) async {
    final data = await _api.get<List<dynamic>>('/tasks/$taskId/photos');
    return data
        .map((e) => (e as Map<String, dynamic>)['id'] as String)
        .toList();
  }

  /// Hisobot rasmini backend orqali (stream) ko'rsatish uchun URL.
  String taskPhotoUrl(String taskId, String photoId) =>
      '${ApiConfig.baseUrl}/tasks/$taskId/photos/$photoId/view';

  Map<String, String> photoHeaders() => {
    'Authorization': 'Bearer ${_tokens.accessToken ?? ''}',
  };

  Future<void> reportProblem({
    required String category,
    required String description,
    List<String> photoPaths = const [],
    String? taskId,
    String? roomNumber,
  }) async {
    final form = FormData.fromMap({
      'category': category,
      'description': description,
      'task_id': ?taskId,
      'room_number': ?roomNumber,
    });
    for (final path in photoPaths) {
      form.files.add(MapEntry('photos', await MultipartFile.fromFile(path)));
    }
    await _api.post<Map<String, dynamic>>('/problems', data: form);
  }
}
