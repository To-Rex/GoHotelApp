import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import 'data/calls_repository.dart';
import 'domain/incoming_call.dart';

/// Kiruvchi qo'ng'iroqni sezib, serverga xabar beradi.
///
/// Qabulxona qurilmasiga mehmon qo'ng'iroq qilganda raqam serverga
/// yuboriladi, server uni bazadan qidiradi va natija VEB ekranidagi
/// menyuda paydo bo'ladi. Xodim go'shakni ko'targanda kim gapirayotganini
/// biladi — ismini so'rab, keyin qidirib o'tirmaydi.
///
/// Uch cheklov ochiq aytilgan:
///
/// 1. **Faqat Android.** iOS tizimi kiruvchi raqamni ilovaga bermaydi —
///    bu platformaning qat'iy qoidasi, aylanib o'tish yo'li yo'q.
/// 2. **Faqat qabulxona roli.** Xizmat shu roldagi shellda ishga
///    tushiriladi; farrosh ilovasida u umuman yoqilmaydi.
/// 3. **Ruxsatsiz jim turadi.** Ruxsat berilmasa xizmat hech narsa
///    qilmaydi va ilovaning qolgan qismi avvalgidek ishlaydi.
class CallWatcherService {
  CallWatcherService(this._repository);

  static const _events = EventChannel('gohotels/incoming_calls');
  static const _permission = MethodChannel(
    'gohotels/incoming_calls/permission',
  );

  final CallsRepository _repository;
  StreamSubscription<dynamic>? _subscription;

  /// Topilgan mehmon haqidagi xabarlar — UI ularni ko'rsatishi mumkin.
  final _matches = StreamController<IncomingCall>.broadcast();
  Stream<IncomingCall> get matches => _matches.stream;

  /// iOS'da kiruvchi raqamni o'qib bo'lmaydi — xizmat u yerda umuman
  /// yoqilmaydi va hech narsa ko'rsatilmaydi.
  bool get isSupported => Platform.isAndroid;

  Future<bool> hasPermission() async {
    if (!isSupported) return false;
    final granted = await _permission.invokeMethod<bool>('has');
    return granted ?? false;
  }

  /// Tizim oynasini ochadi. Foydalanuvchi rad etsa `false` qaytadi.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    final granted = await _permission.invokeMethod<bool>('request');
    return granted ?? false;
  }

  /// Ruxsat bo'lsa tinglashni boshlaydi. Takroriy chaqiruv xavfsiz.
  Future<bool> start({String? deviceId}) async {
    if (!isSupported || _subscription != null) return _subscription != null;
    if (!await hasPermission()) return false;

    _subscription = _events.receiveBroadcastStream().listen(
      (event) => _report(event, deviceId),
      // Tarmoq yoki kanal xatosi ilovani to'xtatmasligi kerak: bu
      // qo'shimcha qulaylik, asosiy ish emas
      onError: (_) {},
    );
    return true;
  }

  Future<void> _report(dynamic event, String? deviceId) async {
    final phone = event is String ? event.trim() : '';
    if (phone.isEmpty) return;
    try {
      final call = await _repository.report(phone, deviceId: deviceId);
      _matches.add(call);
    } catch (_) {
      // Server javob bermasa qo'ng'iroq baribir o'tadi — xodim ishini
      // to'xtatib qo'yadigan xato emas
    }
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> dispose() async {
    await stop();
    await _matches.close();
  }
}
