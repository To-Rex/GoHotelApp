import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/bookings_repository.dart';
import '../../domain/booking.dart';

class BookingsState extends Equatable {
  const BookingsState({
    required this.date,
    this.loading = true,
    this.bookings = const [],
    this.search = '',
    this.filter,
    this.error,
  });

  final DateTime date;
  final bool loading;
  final List<Booking> bookings;

  /// Qidiruv matni — server tomonida qidiriladi (mehmon, raqam, xona).
  final String search;

  /// Tanlangan guruh; null — hammasi.
  final BookingKind? filter;
  final Object? error;

  List<Booking> get visible => filter == null
      ? bookings
      : bookings.where((b) => b.kind == filter).toList();

  int countOf(BookingKind kind) =>
      bookings.where((b) => b.kind == kind).length;

  /// Qarzdor bronlar — resepsiya uchun eng muhim belgi.
  int get debtCount => bookings.where((b) => b.hasDebt).length;

  BookingsState copyWith({
    DateTime? date,
    bool? loading,
    List<Booking>? bookings,
    String? search,
    BookingKind? filter,
    bool clearFilter = false,
    Object? error,
    bool clearError = false,
  }) => BookingsState(
    date: date ?? this.date,
    loading: loading ?? this.loading,
    bookings: bookings ?? this.bookings,
    search: search ?? this.search,
    filter: clearFilter ? null : (filter ?? this.filter),
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [date, loading, bookings, search, filter, error];
}

/// Qabulxona bronlari: kun tanlash, qidiruv va guruh filtri.
class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._repository)
    : super(BookingsState(date: DateTime.now()));

  final BookingsRepository _repository;
  Timer? _poller;
  Timer? _searchDebounce;

  /// So'rovlar tartib raqami: kun tez-tez almashtirilganda yoki qidiruv
  /// bilan so'rov davri to'qnashganda ESKI javob YANGISINING ustidan
  /// yozmasligi uchun — faqat oxirgi so'rov natijasi qabul qilinadi.
  int _loadSeq = 0;

  /// Bron holati boshqa qurilmadan o'zgarishi mumkin — ro'yxat jim
  /// yangilanib turadi.
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
    final seq = ++_loadSeq;
    if (!silent) emit(state.copyWith(loading: true, clearError: true));
    try {
      final bookings = await _repository.getBookings(
        date: state.date,
        search: state.search,
      );
      if (seq != _loadSeq) return;
      emit(state.copyWith(loading: false, bookings: bookings, clearError: true));
    } catch (e) {
      if (seq != _loadSeq) return;
      emit(state.copyWith(loading: false, error: silent ? null : e));
    }
  }

  void selectDate(DateTime date) {
    emit(state.copyWith(date: date, loading: true));
    load(silent: true);
  }

  void shiftDay(int days) =>
      selectDate(state.date.add(Duration(days: days)));

  /// Qidiruv har harfda so'rov yubormaydi — yozib bo'lguncha kutiladi.
  void search(String value) {
    emit(state.copyWith(search: value));
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 400),
      () => load(silent: true),
    );
  }

  void setFilter(BookingKind? kind) => emit(
    kind == null
        ? state.copyWith(clearFilter: true)
        : state.copyWith(filter: kind),
  );

  @override
  Future<void> close() {
    _poller?.cancel();
    _searchDebounce?.cancel();
    return super.close();
  }
}
