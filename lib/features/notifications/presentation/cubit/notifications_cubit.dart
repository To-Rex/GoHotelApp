import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/safe_emit.dart';
import '../../data/notifications_repository.dart';
import '../../domain/staff_notification.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.loading = true,
    this.items = const [],
    this.error,
  });

  final bool loading;
  final List<StaffNotification> items;
  final Object? error;

  int get unreadCount => items.where((n) => !n.isRead).length;

  NotificationsState copyWith({
    bool? loading,
    List<StaffNotification>? items,
    Object? error,
    bool clearError = false,
  }) => NotificationsState(
    loading: loading ?? this.loading,
    items: items ?? this.items,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loading, items, error];
}

/// Bildirishnomalar: ro'yxat + o'qilmaganlar soni (bell belgisidagi nuqta).
/// Fonda daqiqada bir marta jim yangilanadi.
class NotificationsCubit extends Cubit<NotificationsState>
    with SafeEmit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationsRepository _repository;
  Timer? _poller;

  void startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(
      const Duration(seconds: 60),
      (_) => load(silent: true),
    );
  }

  void stopPolling() {
    _poller?.cancel();
    _poller = null;
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(loading: true, clearError: true));
    try {
      final items = await _repository.getNotifications();
      emit(state.copyWith(loading: false, items: items, clearError: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: silent ? null : e));
    }
  }

  Future<void> markRead(String id) async {
    emit(
      state.copyWith(
        items: [
          for (final n in state.items)
            n.id == id
                ? StaffNotification(
                    id: n.id,
                    type: n.type,
                    title: n.title,
                    message: n.message,
                    isRead: true,
                    roomNumber: n.roomNumber,
                    timestamp: n.timestamp,
                  )
                : n,
        ],
      ),
    );
    try {
      await _repository.markRead(id);
    } catch (_) {
      // Optimistik belgilash — tarmoq xatosi ro'yxatni buzmasin.
    }
  }

  Future<void> markAllRead() async {
    emit(
      state.copyWith(
        items: [
          for (final n in state.items)
            StaffNotification(
              id: n.id,
              type: n.type,
              title: n.title,
              message: n.message,
              isRead: true,
              roomNumber: n.roomNumber,
              timestamp: n.timestamp,
            ),
        ],
      ),
    );
    try {
      await _repository.markAllRead();
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _poller?.cancel();
    return super.close();
  }
}
