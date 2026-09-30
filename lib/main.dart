import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app/app.dart';
import 'app/boot_splash.dart';
import 'app/di.dart';
import 'app/theme/app_theme.dart';
import 'core/services/push_service.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Hech narsa kutilmaydi. Ilgari bu yerda Firebase va bog'liqliklar
  // kutilardi va ekran shu vaqt davomida bo'm-bo'sh turardi — o'lchovda
  // 1.6 soniya. Sabab plaginlarning o'zi emas, birinchi platforma kanali
  // chaqiruvi Android tomoni tayyor bo'lishini kutishi edi; uni qayta
  // tartiblash yordam bermaydi, faqat oldin chizish yordam beradi.
  runApp(const AppBootstrap());
}

/// Avval ekranni chizadi, keyin bog'liqliklarni tayyorlaydi.
///
/// Foydalanuvchi darhol brendli yuklanish ekranini ko'radi; tayyor bo'lgach
/// o'sha ekranning o'zi ilovaga aylanadi. Ishga tushirish tartibi va
/// mazmuni o'zgarmagan — faqat u endi birinchi kadrni to'sib turmaydi.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final Future<void> _ready = _boot();

  Future<void> _boot() async {
    // Ekran yo'nalishi — chizishni to'sib turishi shart emas.
    unawaited(
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]),
    );
    // Firebase va bog'liqliklar bir-biriga bog'liq emas — birga ishlaydi.
    await Future.wait([_initFirebase(), configureDependencies()]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ready,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Sozlamalar hali o'qilmagan, shuning uchun mavzu qurilmanikiga
          // ergashadi: qorong'i rejimdagi foydalanuvchi oq ekran ko'rmaydi.
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            home: const BootSplash(),
          );
        }
        return const GoHotelsApp();
      },
    );
  }
}

/// Push xabarlari uchun Firebase. Sozlanmagan yoki Play Services yo'q
/// qurilmada ilova baribir ishga tushishi kerak — push shunchaki jim o'chadi.
Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Yangi vazifa pushlari ilova yopiq paytda ham budilnik bo'lib
    // jiringlashi uchun fon ishlovchisi shu yerda ro'yxatdan o'tadi
    FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);
  } catch (_) {
    // Push yo'q — ilova qolgan hamma narsani bajaraveradi.
  }
}
