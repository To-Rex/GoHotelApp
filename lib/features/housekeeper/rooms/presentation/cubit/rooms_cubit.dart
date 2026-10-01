import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/bloc/safe_emit.dart';
import '../../data/rooms_repository.dart';
import '../../domain/occupied_room.dart';

class RoomsState extends Equatable {
  const RoomsState({this.loading = true, this.rooms = const [], this.error});

  final bool loading;
  final List<OccupiedRoom> rooms;
  final Object? error;

  /// Hozir band xonalar (mehmon ichkarida).
  List<OccupiedRoom> get occupied => rooms.where((r) => r.isCheckedIn).toList();

  /// Tozalashga yaqin: chiqish vaqti bo'yicha tartiblangan band xonalar
  /// (server allaqachon eng yaqinini birinchi qilib beradi).
  List<OccupiedRoom> get upcoming => occupied;

  RoomsState copyWith({
    bool? loading,
    List<OccupiedRoom>? rooms,
    Object? error,
    bool clearError = false,
  }) => RoomsState(
    loading: loading ?? this.loading,
    rooms: rooms ?? this.rooms,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loading, rooms, error];
}

class RoomsCubit extends Cubit<RoomsState> with SafeEmit<RoomsState> {
  RoomsCubit(this._repository) : super(const RoomsState());

  final RoomsRepository _repository;
  Timer? _poller;

  /// "Qancha vaqt qoldi" belgilari eskirmasligi uchun davriy jim yangilash.
  void startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(
      const Duration(seconds: 90),
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
      final rooms = await _repository.getOccupiedRooms(includeReserved: true);
      emit(state.copyWith(loading: false, rooms: rooms, clearError: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: silent ? null : e));
    }
  }

  @override
  Future<void> close() {
    _poller?.cancel();
    return super.close();
  }
}
