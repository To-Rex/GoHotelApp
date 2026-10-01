import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/safe_emit.dart';
import '../../../../core/network/api_exception.dart';
import '../../data/chat_repository.dart';
import '../../domain/staff_message.dart';

class ChatState extends Equatable {
  const ChatState({
    this.loading = true,
    this.messages = const [],
    this.attachments = const {},
    this.sending = false,
    this.error,
    this.uploadDenied = false,
  });

  final bool loading;

  /// Eng eskisi birinchi (chat pastdan yuqoriga o'qiladi).
  final List<StaffMessage> messages;

  /// Xabar ID → rasm(lar).
  final Map<String, List<MessageAttachment>> attachments;
  final bool sending;
  final Object? error;

  /// `file.upload` ruxsati yo'qligi aniqlandi — rasm tugmasi shuni aytadi.
  final bool uploadDenied;

  ChatState copyWith({
    bool? loading,
    List<StaffMessage>? messages,
    Map<String, List<MessageAttachment>>? attachments,
    bool? sending,
    Object? error,
    bool clearError = false,
    bool? uploadDenied,
  }) => ChatState(
    loading: loading ?? this.loading,
    messages: messages ?? this.messages,
    attachments: attachments ?? this.attachments,
    sending: sending ?? this.sending,
    error: clearError ? null : (error ?? this.error),
    uploadDenied: uploadDenied ?? this.uploadDenied,
  );

  @override
  List<Object?> get props => [
    loading,
    messages,
    attachments,
    sending,
    error,
    uploadDenied,
  ];
}

/// Xodimlar chati. Ochiq turganda har 10 soniyada jim yangilanadi —
/// resepshn javobi kutdirmay ko'rinadi.
class ChatCubit extends Cubit<ChatState> with SafeEmit<ChatState> {
  ChatCubit(this._repository) : super(const ChatState());

  final ChatRepository _repository;
  Timer? _poller;

  static const _pollInterval = Duration(seconds: 10);

  void startPolling() {
    _poller?.cancel();
    _poller = Timer.periodic(_pollInterval, (_) => load(silent: true));
  }

  void stopPolling() {
    _poller?.cancel();
    _poller = null;
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) emit(state.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait([
        _repository.getMessages(),
        _repository.getAttachments(),
      ]);
      final messages = (results[0] as List<StaffMessage>).reversed.toList();
      final attachments = results[1] as Map<String, List<MessageAttachment>>;
      emit(
        state.copyWith(
          loading: false,
          messages: messages,
          attachments: attachments,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: silent ? null : e));
    }
  }

  Future<bool> send(String body, {String? roomId}) async {
    if (body.trim().isEmpty) return false;
    emit(state.copyWith(sending: true));
    try {
      final message = await _repository.sendMessage(
        body.trim(),
        roomId: roomId,
      );
      emit(
        state.copyWith(sending: false, messages: [...state.messages, message]),
      );
      return true;
    } catch (e) {
      emit(state.copyWith(sending: false, error: e));
      return false;
    }
  }

  /// Rasmli xabar: avval matnli xabar yaratiladi, so'ng fayl biriktiriladi.
  Future<bool> sendImage(String imagePath, String placeholderBody) async {
    emit(state.copyWith(sending: true));
    try {
      final message = await _repository.sendMessage(placeholderBody);
      await _repository.attachImage(
        messageId: message.id,
        imagePath: imagePath,
      );
      // Rasm darhol ko'rinishi uchun to'liq yangilaymiz.
      await load(silent: true);
      emit(state.copyWith(sending: false));
      return true;
    } on ApiException catch (e) {
      emit(
        state.copyWith(sending: false, error: e, uploadDenied: e.isForbidden),
      );
      // Ruxsat bo'lmasa ham matnli xabar allaqachon ketgan — ro'yxatni yangilab qo'yamiz.
      await load(silent: true);
      return false;
    } catch (e) {
      emit(state.copyWith(sending: false, error: e));
      return false;
    }
  }

  Future<void> markDone(String messageId) async {
    try {
      final updated = await _repository.markDone(messageId);
      emit(
        state.copyWith(
          messages: [
            for (final m in state.messages) m.id == updated.id ? updated : m,
          ],
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e));
    }
  }

  String imageUrl(String fileId) => _repository.imageUrl(fileId);

  Map<String, String> imageHeaders() => _repository.imageHeaders();

  @override
  Future<void> close() {
    _poller?.cancel();
    return super.close();
  }
}
