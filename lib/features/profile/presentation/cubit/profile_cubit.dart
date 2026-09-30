import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/profile_repository.dart';
import '../../domain/work_stats.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.photoFileId,
    this.stats,
    this.statsLoading = true,
    this.uploadingPhoto = false,
    this.error,
  });

  final String? photoFileId;
  final WorkStats? stats;
  final bool statsLoading;
  final bool uploadingPhoto;
  final Object? error;

  ProfileState copyWith({
    String? photoFileId,
    WorkStats? stats,
    bool? statsLoading,
    bool? uploadingPhoto,
    Object? error,
    bool clearError = false,
  }) => ProfileState(
    photoFileId: photoFileId ?? this.photoFileId,
    stats: stats ?? this.stats,
    statsLoading: statsLoading ?? this.statsLoading,
    uploadingPhoto: uploadingPhoto ?? this.uploadingPhoto,
    error: clearError ? null : (error ?? this.error),
  );

  @override
  List<Object?> get props => [
    photoFileId,
    stats,
    statsLoading,
    uploadingPhoto,
    error,
  ];
}

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> load(String userId) async {
    emit(state.copyWith(statsLoading: true, clearError: true));
    /* Surat va statistika mustaqil — biri yiqilsa ikkinchisi ko'rinaveradi.
       Ikkalasi BIRGA so'raladi: ketma-ket kutilganda skelet sekin tarmoqda
       ikki barobar uzoq turardi. Xato ushlagichlar future yaratilishi
       bilanoq ulanadi — birinchisi kutilayotganda ikkinchisi yiqilsa,
       egasiz xato bo'lib qolmasin. */
    final photoFuture = _repository
        .getMyPhotoFileId(userId)
        .then<String?>((id) => id, onError: (Object _) => null);
    final statsFuture = _repository
        .getWorkStats(userId)
        .then<Object>((stats) => stats, onError: (Object e) => e);

    final photoId = await photoFuture;
    if (photoId != null) emit(state.copyWith(photoFileId: photoId));

    final statsResult = await statsFuture;
    if (statsResult is WorkStats) {
      emit(state.copyWith(stats: statsResult, statsLoading: false));
    } else {
      emit(state.copyWith(statsLoading: false, error: statsResult));
    }
  }

  /// true — muvaffaqiyatli; ruxsat yo'q bo'lsa ApiException.forbidden otiladi.
  Future<bool> uploadPhoto(String userId, String imagePath) async {
    emit(state.copyWith(uploadingPhoto: true, clearError: true));
    try {
      await _repository.uploadMyPhoto(userId, imagePath);
      final photoId = await _repository.getMyPhotoFileId(userId);
      emit(state.copyWith(uploadingPhoto: false, photoFileId: photoId));
      return true;
    } on ApiException catch (e) {
      emit(state.copyWith(uploadingPhoto: false, error: e));
      return false;
    } catch (e) {
      emit(state.copyWith(uploadingPhoto: false, error: e));
      return false;
    }
  }

  String? photoUrl() => state.photoFileId == null
      ? null
      : _repository.photoUrl(state.photoFileId!);

  Map<String, String> photoHeaders() => _repository.photoHeaders();
}
