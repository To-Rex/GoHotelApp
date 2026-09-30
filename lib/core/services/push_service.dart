import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../firebase_options.dart';

/// FCM push'larini serverga ulab turuvchi xizmat.
///
/// Backend tayyor: `/notifications/register-device` tokenni saqlaydi va
/// bildirishnoma yaratilganda shu tokenga push yuboradi. Bu xizmat esa
/// yetishmayotgan yopishtiruvchi qism edi — token OLINMAS va serverga
/// YUBORILMAS edi, shuning uchun pushlar hech kimga bormasdi.
///
/// Har bir qadam himoyalangan: Firebase sozlanmagan yoki Play Services
/// yo'q qurilmada xizmat jimgina o'chadi — ilovaning qolgan qismi bunga
/// bog'lanmaydi.
///
/// Ko'rsatish mantiqi ATAYLAB sinf tashqarisida: yangi vazifa pushlari
/// ilova YOPIQ paytda ham kelishi kerak, ular alohida izolatda
/// ishlaydigan fon ishlovchisiga tushadi va u sinf nusxasiga (DI'ga)
/// yeta olmaydi.

/// Oddiy xabarlar kanali — backend `high_importance_channel` deb yuboradi.
const _alertsChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'Muhim bildirishnomalar',
  description: "Bron va tizim xabarlari",
  importance: Importance.max,
);

/// Yangi vazifa kanali — BUDILNIK kabi: tovush budilnik oqimidan chiqadi
/// (telefon ovozsiz rejimda ham eshitiladi) va bildirishnoma QO'LDA
/// yopilmaguncha jiringlayveradi.
const _taskAlarmChannel = AndroidNotificationChannel(
  'task_alarm_channel',
  'Yangi vazifa (budilnik)',
  description: "Yangi vazifa tushganda to'xtovsiz jiringlaydi",
  importance: Importance.max,
  audioAttributesUsage: AudioAttributesUsage.alarm,
);

/// Android'ning FLAG_INSISTENT bayrog'i: tovush bildirishnoma yopilmaguncha
/// qayta-qayta chalinadi — budilnikning o'zi.
const _flagInsistent = 4;

final _local = FlutterLocalNotificationsPlugin();
bool _localReady = false;

Future<void> _ensureLocalReady() async {
  if (_localReady) return;
  await _local.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  final android = _local
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await android?.createNotificationChannel(_alertsChannel);
  await android?.createNotificationChannel(_taskAlarmChannel);
  _localReady = true;
}

/// Kelgan xabarni ekranga chiqaradi: yangi vazifa — budilnik kanalida
/// (yopilmaguncha jiringlaydi), qolgani — oddiy kanalda.
Future<void> _display(RemoteMessage message) async {
  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] as String?;
  final body = notification?.body ?? message.data['body'] as String?;
  if (title == null && body == null) return;

  final isTaskAlarm = message.data['kind'] == 'task_alarm';
  await _local.show(
    id: message.hashCode,
    title: title ?? 'GoHotel',
    body: body ?? '',
    notificationDetails: NotificationDetails(
      android: isTaskAlarm
          ? AndroidNotificationDetails(
              _taskAlarmChannel.id,
              _taskAlarmChannel.name,
              channelDescription: _taskAlarmChannel.description,
              importance: Importance.max,
              priority: Priority.max,
              category: AndroidNotificationCategory.alarm,
              audioAttributesUsage: AudioAttributesUsage.alarm,
              // Qulflangan ekranda ham to'liq ko'rinadi
              fullScreenIntent: true,
              visibility: NotificationVisibility.public,
              // Yopilmaguncha jiringlayveradi; bosilganda yoki surib
              // tashlanganda (QO'LDA) to'xtaydi
              additionalFlags: Int32List.fromList([_flagInsistent]),
              autoCancel: true,
              icon: '@mipmap/ic_launcher',
            )
          : AndroidNotificationDetails(
              _alertsChannel.id,
              _alertsChannel.name,
              channelDescription: _alertsChannel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
      iOS: const DarwinNotificationDetails(),
    ),
  );
}

/// Ilova YOPIQ yoki fonda paytida kelgan data-push'lar shu yerga tushadi.
///
/// Alohida izolatda ishlaydi — Firebase va kanallar shu yerning o'zida
/// tayyorlanadi. Yangi vazifa serverdan ataylab data-push bo'lib keladi:
/// tizim uni o'zi chizsa, tovush bir marta chalinib qo'yardi; bu yerda
/// esa budilnik kanalida ko'rsatiladi.
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Allaqachon ishga tushgan bo'lishi mumkin — davom etamiz
  }
  try {
    await _ensureLocalReady();
    await _display(message);
  } catch (_) {
    // Ko'rsatib bo'lmasa jim o'tamiz — ishlovchi hech qachon yiqilmasin
  }
}

class PushService {
  PushService(this._auth);

  final AuthRepository _auth;

  StreamSubscription<String>? _refreshSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  bool _connecting = false;

  /// Kirishdan keyin chaqiriladi: ruxsat so'raydi, tokenni olib serverga
  /// yuboradi va yangilanishini kuzatib turadi.
  Future<void> connect() async {
    if (_connecting) return;
    _connecting = true;
    try {
      final messaging = FirebaseMessaging.instance;
      // Android 13+ va iOS'da bildirishnoma ruxsati. Rad etilsa ham token
      // ro'yxatdan o'tadi — foydalanuvchi keyin sozlamadan yoqishi mumkin.
      await messaging.requestPermission();
      await _ensureLocalReady();
      // iOS'da ochiq ilovada ham banner/tovush ko'rsatilsin
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      // Ochiq ilovada Android push'ni o'zi chizmaydi — o'zimiz chizamiz
      _messageSub ??= FirebaseMessaging.onMessage.listen(_display);
      final token = await messaging.getToken();
      // Token konsolda ko'rinadi — Firebase konsolidan sinov push
      // yuborishda aynan shu qiymat kerak bo'ladi (adb logcat / flutter run)
      debugPrint('FCM token: ${token ?? "(olinmadi)"}');
      if (token != null && token.isNotEmpty) {
        await _register(token);
      }
      // FCM tokenni o'zi almashtirishi mumkin — yangisi darhol serverga
      // boradi, aks holda pushlar eski (o'lik) tokenga ketardi
      _refreshSub ??= messaging.onTokenRefresh.listen(_register);
    } catch (_) {
      // Firebase yo'q — push jim o'chadi, ilova ishlayveradi
    } finally {
      _connecting = false;
    }
  }

  Future<void> _register(String token) async {
    debugPrint('FCM token (yangilandi): $token');
    try {
      await _auth.registerFcmToken(token);
    } catch (_) {
      // Tarmoq xatosi — keyingi kirishda yoki token yangilanganda qayta
      // uriniladi
    }
  }

  /// Chiqishda (yoki sessiya tugaganda): kuzatuv to'xtaydi va qurilma
  /// tokeni o'chadi — chiqqan foydalanuvchiga push kelmaydi. Keyingi
  /// kirishda yangi token olinadi.
  Future<void> disconnect() async {
    try {
      await _refreshSub?.cancel();
      _refreshSub = null;
      await _messageSub?.cancel();
      _messageSub = null;
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {
      // Firebase yo'q bo'lsa o'chiradigan narsa ham yo'q
    }
  }
}
