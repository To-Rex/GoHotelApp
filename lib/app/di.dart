import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/services/biometric_service.dart';
import '../core/storage/app_prefs.dart';
import '../core/storage/token_store.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/face_repository.dart';
import '../features/chat/data/chat_repository.dart';
import '../features/housekeeper/rooms/data/rooms_repository.dart';
import '../features/housekeeper/tasks/data/tasks_repository.dart';
import '../features/management/data/management_repository.dart';
import '../features/notifications/data/notifications_repository.dart';
import '../features/profile/data/profile_repository.dart';
import '../features/reception/bookings/data/bookings_repository.dart';
import '../features/reception/calls/call_watcher_service.dart';
import '../features/reception/calls/data/calls_repository.dart';
import '../features/reception/report/data/report_repository.dart';
import '../core/services/push_service.dart';
import '../features/reception/scan/data/scan_repository.dart';

final getIt = GetIt.instance;

/// Bog'liqliklarni bir joyda yig'ish — testda osongina almashtiriladi.
Future<void> configureDependencies() async {
  // Ikkala o'qish ham diskka boradi va bir-biriga bog'liq emas. Ketma-ket
  // kutilganda ular startupning yarmini yeb qo'yardi; birga ishga tushirilsa
  // sekinrog'i qancha bo'lsa, shuncha vaqt ketadi.
  final tokenStore = TokenStore(
    const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );
  final results = await Future.wait([
    SharedPreferences.getInstance(),
    tokenStore.init(),
  ]);

  final prefs = AppPrefs(results.first as SharedPreferences);
  getIt.registerSingleton<AppPrefs>(prefs);
  getIt.registerSingleton<TokenStore>(tokenStore);

  getIt.registerSingleton<ApiClient>(
    ApiClient(tokenStore: tokenStore, prefs: prefs),
  );

  getIt.registerSingleton<BiometricService>(
    BiometricService(LocalAuthentication()),
  );

  // Repositorylar
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(api: getIt(), tokens: getIt()),
  );
  getIt.registerLazySingleton<FaceRepository>(() => FaceRepository(getIt()));
  getIt.registerLazySingleton<TasksRepository>(
    () => TasksRepository(getIt(), getIt()),
  );
  getIt.registerLazySingleton<RoomsRepository>(() => RoomsRepository(getIt()));
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepository(api: getIt(), tokens: getIt()),
  );
  getIt.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepository(getIt()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(api: getIt(), tokens: getIt()),
  );
  // Qabulxona: bronlar ro'yxati va shaxsiy hisobot
  getIt.registerLazySingleton<BookingsRepository>(
    () => BookingsRepository(getIt()),
  );
  getIt.registerLazySingleton<ReportRepository>(() => ReportRepository(getIt()));
  getIt.registerLazySingleton<CallsRepository>(() => CallsRepository(getIt()));
  getIt.registerLazySingleton<ScanRepository>(
    () => ScanRepository(getIt(), getIt()),
  );
  getIt.registerLazySingleton<PushService>(() => PushService(getIt()));
  // Kiruvchi qo'ng'iroq kuzatuvchisi — faqat qabulxona shellida
  // ishga tushiriladi, boshqa rollarda umuman tegilmaydi
  getIt.registerLazySingleton<CallWatcherService>(
    () => CallWatcherService(getIt()),
  );
  // Boshqaruv (admin/menejer): puls, xonalar xaritasi, jamoa, murojaatlar
  getIt.registerLazySingleton<ManagementRepository>(
    () => ManagementRepository(getIt()),
  );
}
