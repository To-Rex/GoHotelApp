import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/management_repository.dart';
import '../../domain/room_tile.dart';
import '../../../../core/bloc/safe_emit.dart';

/// Qavat bo'yicha xonalar guruhi.
class FloorGroup extends Equatable {
  const FloorGroup({required this.floor, required this.rooms});

  /// null — qavati aniqlanmagan xonalar ("Boshqa").
  final FloorInfo? floor;
  final List<RoomTile> rooms;

  @override
  List<Object?> get props => [floor, rooms];
}

class RoomMapState extends Equatable {
  const RoomMapState({
    this.loading = true,
    this.rooms = const [],
    this.floors = const {},
    this.filter,
    this.error,
  });

  final bool loading;
  final List<RoomTile> rooms;
  final Map<String, FloorInfo> floors;

  /// Tanlangan holat; null — hammasi.
  final RoomState? filter;
  final Object? error;

  int countOf(RoomState state) => rooms.where((r) => r.state == state).length;

  /// Filtr bo'yicha xonalar, qavatlarga bo'lingan. Qavatlar raqami bo'yicha,
  /// xonalar raqami bo'yicha (raqamli tartib: 101, 102, 110 — 1, 10, 2 emas).
  List<FloorGroup> get groups {
    final visible = filter == null
        ? rooms
        : rooms.where((r) => r.state == filter).toList();
    final byFloor = <String, List<RoomTile>>{};
    for (final room in visible) {
      (byFloor[room.floorId] ??= []).add(room);
    }
    final groups = [
      for (final entry in byFloor.entries)
        FloorGroup(
          floor: floors[entry.key],
          rooms: entry.value..sort(_byNumber),
        ),
    ];
    groups.sort((a, b) {
      if (a.floor == null) return 1;
      if (b.floor == null) return -1;
      return a.floor!.number.compareTo(b.floor!.number);
    });
    return groups;
  }

  static int _byNumber(RoomTile a, RoomTile b) {
    final na = int.tryParse(a.number);
    final nb = int.tryParse(b.number);
    if (na != null && nb != null) return na.compareTo(nb);
    return a.number.compareTo(b.number);
  }

  RoomMapState copyWith({
    bool? loading,
    List<RoomTile>? rooms,
    Map<String, FloorInfo>? floors,
    RoomState? filter,
    bool clearFilter = false,
    Object? error,
    bool clearError = false,
  }) => RoomMapState(
    loading: loading ?? this.loading,
    rooms: rooms ?? this.rooms,
    floors: floors ?? this.floors,
    filter: clearFilter ? null : (filter ?? this.filter),
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [loading, rooms, floors, filter, error];
}

/// Xonalar xaritasi: jonli holatlar, filtr, qo'lda holat o'zgartirish.
class RoomMapCubit extends Cubit<RoomMapState> with SafeEmit<RoomMapState> {
  RoomMapCubit(this._repository) : super(const RoomMapState());

  final ManagementRepository _repository;
  Timer? _poller;
  int _seq = 0;

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
    final seq = ++_seq;
    if (!silent) emit(state.copyWith(loading: true, clearError: true));
    try {
      // Qavatlar yo'q bo'lsa ham xonalar ko'rsatiladi ("Boshqa" guruhida)
      final floorsFuture = _repository.getFloors().then<List<FloorInfo>>(
        (f) => f,
        onError: (Object _) => const <FloorInfo>[],
      );
      final rooms = await _repository.getRooms();
      final floors = await floorsFuture;
      if (seq != _seq || isClosed) return;
      emit(
        state.copyWith(
          loading: false,
          rooms: rooms,
          floors: {for (final f in floors) f.id: f},
          clearError: true,
        ),
      );
    } catch (e) {
      if (seq != _seq || isClosed) return;
      emit(state.copyWith(loading: false, error: silent ? null : e));
    }
  }

  void setFilter(RoomState? filter) => emit(
    filter == null
        ? state.copyWith(clearFilter: true)
        : state.copyWith(filter: filter),
  );

  /// Holatni o'zgartirish. Javob kelishi bilan katak yangilanadi; xato
  /// bo'lsa istisno chaqiruvchiga qaytadi (matni snack'da ko'rsatiladi).
  Future<void> setRoomStatus(
    String roomId,
    RoomState newState, {
    String? notes,
  }) async {
    final updated = await _repository.setRoomStatus(
      roomId,
      newState,
      notes: notes,
    );
    _replace(updated);
  }

  void _replace(RoomTile room) {
    emit(
      state.copyWith(
        rooms: [for (final r in state.rooms) r.id == room.id ? room : r],
      ),
    );
  }

  Future<List<RoomStay>> getStays(String roomId) =>
      _repository.getRoomStays(roomId);

  @override
  Future<void> close() {
    _poller?.cancel();
    return super.close();
  }
}
