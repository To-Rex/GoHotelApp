import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/tasks_repository.dart';
import '../../domain/cleaning_task.dart';

/// Ro'yxat filtri.
enum TaskFilter { all, pending, inProgress, completed }

class TasksState extends Equatable {
  const TasksState({
    this.loading = true,
    this.tasks = const [],
    // Farrosh ilovani ochganda avval YANGI vazifalarni ko'radi —
    // "nima qilishim kerak" degan savolga darhol javob.
    this.filter = TaskFilter.pending,
    this.error,
  });

  final bool loading;
  final List<CleaningTask> tasks;
  final TaskFilter filter;
  final Object? error;

  List<CleaningTask> get visible {
    final filtered = switch (filter) {
      TaskFilter.all => tasks,
      TaskFilter.pending =>
        tasks.where((t) => t.status == TaskStatus.pending).toList(),
      TaskFilter.inProgress =>
        tasks.where((t) => t.status == TaskStatus.inProgress).toList(),
      TaskFilter.completed =>
        tasks.where((t) => t.status == TaskStatus.completed).toList(),
    };
    // Shoshilinch va boshlanganlar tepada, bajarilganlar pastda.
    final order = [...filtered]
      ..sort((a, b) {
        int rank(CleaningTask t) => switch (t.status) {
          TaskStatus.inProgress => 0,
          TaskStatus.pending => 1,
          TaskStatus.completed => 2,
        };
        final byStatus = rank(a).compareTo(rank(b));
        if (byStatus != 0) return byStatus;
        if (a.isUrgent != b.isUrgent) return a.isUrgent ? -1 : 1;
        return a.roomNumber.compareTo(b.roomNumber);
      });
    return order;
  }

  int get doneCount =>
      tasks.where((t) => t.status == TaskStatus.completed).length;

  TasksState copyWith({
    bool? loading,
    List<CleaningTask>? tasks,
    TaskFilter? filter,
    Object? error,
    bool clearError = false,
  }) => TasksState(
    loading: loading ?? this.loading,
    tasks: tasks ?? this.tasks,
    filter: filter ?? this.filter,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loading, tasks, filter, error];
}

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this._repository) : super(const TasksState());

  final TasksRepository _repository;

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(loading: true, clearError: true));
    try {
      final tasks = await _repository.getTasks();
      emit(state.copyWith(loading: false, tasks: tasks, clearError: true));
    } catch (e) {
      // Jim yangilashda eski ro'yxat qoladi — ekran "sakramaydi".
      emit(state.copyWith(loading: false, error: silent ? null : e));
    }
  }

  void setFilter(TaskFilter filter) => emit(state.copyWith(filter: filter));

  /// Detal sahifadan qaytgan yangilangan vazifani ro'yxatga joylash.
  void applyUpdated(CleaningTask task) {
    final tasks = [for (final t in state.tasks) t.id == task.id ? task : t];
    emit(state.copyWith(tasks: tasks));
  }
}
