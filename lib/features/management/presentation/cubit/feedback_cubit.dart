import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/management_repository.dart';
import '../../domain/guest_feedback.dart';
import '../../../../core/bloc/safe_emit.dart';

/// Murojaatlar ro'yxati filtri.
enum FeedbackFilter { open, complaints, resolved, all }

class FeedbackState extends Equatable {
  const FeedbackState({
    this.loading = true,
    this.items = const [],
    this.filter = FeedbackFilter.open,
    this.error,
  });

  final bool loading;
  final List<GuestFeedback> items;
  final FeedbackFilter filter;
  final Object? error;

  List<GuestFeedback> get visible => switch (filter) {
    FeedbackFilter.open => items.where((f) => f.isOpen).toList(),
    FeedbackFilter.complaints =>
      items.where((f) => f.isComplaint && f.isOpen).toList(),
    FeedbackFilter.resolved => items.where((f) => !f.isOpen).toList(),
    FeedbackFilter.all => items,
  };

  int countOf(FeedbackFilter filter) => switch (filter) {
    FeedbackFilter.open => items.where((f) => f.isOpen).length,
    FeedbackFilter.complaints =>
      items.where((f) => f.isComplaint && f.isOpen).length,
    FeedbackFilter.resolved => items.where((f) => !f.isOpen).length,
    FeedbackFilter.all => items.length,
  };

  FeedbackState copyWith({
    bool? loading,
    List<GuestFeedback>? items,
    FeedbackFilter? filter,
    Object? error,
    bool clearError = false,
  }) => FeedbackState(
    loading: loading ?? this.loading,
    items: items ?? this.items,
    filter: filter ?? this.filter,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loading, items, filter, error];
}

/// Mehmon murojaatlari: talab, taklif, shikoyat — holatini boshqarish.
class FeedbackCubit extends Cubit<FeedbackState> with SafeEmit<FeedbackState> {
  FeedbackCubit(this._repository) : super(const FeedbackState());

  final ManagementRepository _repository;
  int _seq = 0;

  Future<void> load({bool silent = false}) async {
    final seq = ++_seq;
    if (!silent) emit(state.copyWith(loading: true, clearError: true));
    try {
      final (items, _) = await _repository.getFeedback(limit: 200);
      if (seq != _seq || isClosed) return;
      emit(state.copyWith(loading: false, items: items, clearError: true));
    } catch (e) {
      if (seq != _seq || isClosed) return;
      emit(state.copyWith(loading: false, error: silent ? null : e));
    }
  }

  void setFilter(FeedbackFilter filter) => emit(state.copyWith(filter: filter));

  /// Holatni o'zgartirish; yopishda (RESOLVED/REJECTED) izoh shart —
  /// server tekshiradi, xato chaqiruvchiga qaytadi.
  Future<void> setStatus(String id, String status, {String? resolution}) async {
    final updated = await _repository.setFeedbackStatus(
      id,
      status,
      resolution: resolution,
    );
    emit(
      state.copyWith(
        items: [for (final f in state.items) f.id == id ? updated : f],
      ),
    );
  }
}
