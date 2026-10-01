import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/safe_emit.dart';
import '../../data/tasks_repository.dart';
import '../../domain/cleaning_task.dart';

/// Bitta vazifa sahifasi: boshlash, checklist, yakunlash, foto hisobot.
class TaskDetailState extends Equatable {
  const TaskDetailState({
    required this.task,
    this.busy = false,
    this.error,
    this.justCompleted = false,
    this.photoIds = const [],
  });

  final CleaningTask task;

  /// Server bilan amal ketmoqda (tugmalar bloklanadi).
  final bool busy;
  final Object? error;

  /// Hozirgina 100% ga yetdi — UI bayramona xabar ko'rsatadi.
  final bool justCompleted;

  /// Avval yuborilgan foto hisobot rasmlari.
  final List<String> photoIds;

  TaskDetailState copyWith({
    CleaningTask? task,
    bool? busy,
    Object? error,
    bool clearError = false,
    bool justCompleted = false,
    List<String>? photoIds,
  }) => TaskDetailState(
    task: task ?? this.task,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
    justCompleted: justCompleted,
    photoIds: photoIds ?? this.photoIds,
  );

  @override
  List<Object?> get props => [task, busy, error, justCompleted, photoIds];
}

class TaskDetailCubit extends Cubit<TaskDetailState>
    with SafeEmit<TaskDetailState> {
  TaskDetailCubit(this._repository, CleaningTask initial)
    : super(TaskDetailState(task: initial));

  final TasksRepository _repository;

  Future<void> refresh() async {
    // Rasm ro'yxati vazifa ma'lumotiga bog'liq emas — ikkala so'rov birga
    // ketadi; ilgari rasm lentasi ikkinchi RTT'ni bekorga kutardi.
    final photosFuture = loadPhotos();
    try {
      final task = await _repository.getTask(state.task.id);
      emit(state.copyWith(task: task, clearError: true));
    } catch (_) {
      // Jim yangilash — mavjud ma'lumot qoladi.
    }
    await photosFuture;
  }

  Future<void> loadPhotos() async {
    try {
      final ids = await _repository.getTaskPhotoIds(state.task.id);
      emit(state.copyWith(photoIds: ids));
    } catch (_) {
      // Rasm ro'yxati ikkinchi darajali — xatoda jim qolamiz.
    }
  }

  String photoUrl(String photoId) =>
      _repository.taskPhotoUrl(state.task.id, photoId);

  Map<String, String> photoHeaders() => _repository.photoHeaders();

  Future<void> start() => _run(() => _repository.startTask(state.task.id));

  Future<void> toggleItem(String itemId) async {
    final wasCompleted = state.task.status == TaskStatus.completed;
    await _run(
      () => _repository.toggleChecklistItem(state.task.id, itemId),
      celebrateIfCompleted: !wasCompleted,
    );
  }

  /// "Tozalashni yakunlash" — progress 100 (server statusni o'zi yopadi).
  Future<void> finish() => _run(
    () => _repository.updateProgress(state.task.id, 100),
    celebrateIfCompleted: true,
  );

  Future<bool> submitReport({
    required List<String> photoPaths,
    String? comment,
  }) async {
    emit(state.copyWith(busy: true, clearError: true));
    try {
      await _repository.submitPhotoReport(
        taskId: state.task.id,
        photoPaths: photoPaths,
        comment: comment,
      );
      emit(state.copyWith(busy: false));
      await loadPhotos(); // yangi rasmlar darhol ko'rinsin
      return true;
    } catch (e) {
      emit(state.copyWith(busy: false, error: e));
      return false;
    }
  }

  Future<void> _run(
    Future<CleaningTask> Function() action, {
    bool celebrateIfCompleted = false,
  }) async {
    if (state.busy) return;
    emit(state.copyWith(busy: true, clearError: true));
    try {
      final task = await action();
      emit(
        state.copyWith(
          task: task,
          busy: false,
          justCompleted:
              celebrateIfCompleted && task.status == TaskStatus.completed,
        ),
      );
    } catch (e) {
      emit(state.copyWith(busy: false, error: e));
    }
  }
}
