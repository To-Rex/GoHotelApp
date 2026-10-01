import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/extensions/context_x.dart';
import '../core/network/api_client.dart';
import '../core/services/push_service.dart';
import '../core/widgets/confirm_sheet.dart';
import '../features/auth/data/face_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/pages/face_verify_page.dart';
import '../features/auth/presentation/widgets/face_enroll_gate.dart';
import '../features/auth/presentation/pages/locked_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/outside_work_hours_page.dart';
import '../features/auth/presentation/pages/service_stopped_page.dart';
import '../l10n/gen/app_localizations.dart';
import 'boot_splash.dart';
import 'di.dart';
import 'roles/role_registry.dart';
import 'settings/settings_cubit.dart';
import 'theme/app_theme.dart';

class GoHotelsApp extends StatelessWidget {
  const GoHotelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(getIt())),
        BlocProvider(
          create: (_) => AuthCubit(
            repository: getIt(),
            prefs: getIt(),
            biometrics: getIt(),
          )..appStarted(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'GoHotel Staff',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            // O'zbek tili — asosiy; sozlamada tanlansa rus/ingliz.
            locale: settings.locale ?? const Locale('uz'),
            supportedLocales: S.supportedLocales,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            /* Ildiz sahifa — AuthGate. Avvalgi `home: AuthGate()` bilan bir
               xil, faqat dasturiy `pop()` uni olib tashlay olmaydi
               ([AuthGate.rootRoute]). `home` bilan `onGenerateInitialRoutes`
               birga berilmaydi, shuning uchun "/" yo'li shu yerda quriladi. */
            onGenerateInitialRoutes: (_) => [AuthGate.rootRoute()],
            onGenerateRoute: (settings) =>
                settings.name == Navigator.defaultRouteName
                ? MaterialPageRoute<void>(
                    settings: settings,
                    builder: (_) => const AuthGate(),
                  )
                : null,
          );
        },
      ),
    );
  }
}

/// Auth holatiga qarab kerakli ekranni ko'rsatadi.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  /// Ilovaning ildiz sahifasi (AuthGate) — `home` dagi bilan bir xil
  /// [MaterialPageRoute], faqat dasturiy `pop()` uni olib tashlay olmaydi.
  ///
  /// To'siq ekraniga (ish vaqti tugadi, xizmat to'xtatildi) o'tishda
  /// ustidagi sahifa va oynalar yopiladi. Ulardan biri yopilish animatsiyasi
  /// paytida (hali "mounted") kutayotgan ishini tugatib o'zini `pop()`
  /// qilsa, bu chaqiriq ildizga tushib, ilovani bo'sh (qora) ekranda
  /// qoldirardi. Tizimning "orqaga" tugmasi bunga tegmaydi: ildizda u
  /// avvalgidek ilovadan chiqadi.
  static Route<void> rootRoute() => _GateRoute();

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _GateRoute extends MaterialPageRoute<void> {
  _GateRoute()
    : super(
        builder: (_) => const AuthGate(),
        settings: const RouteSettings(name: Navigator.defaultRouteName),
      );

  /// Ildiz hech qachon dasturiy `pop()` bilan olib tashlanmaydi: ostida
  /// sahifa yo'q, olib tashlansa ilova bo'sh ekranda qolardi. (`didPop`
  /// paytida `isFirst` allaqachon `false` — shuning uchun shartsiz.)
  ///
  /// Shu sababli `popUntil` predikati ildizda albatta to'xtashi kerak
  /// (masalan `route.isFirst`) — aks holda sikl tugamaydi.
  @override
  // ignore: must_call_super
  bool didPop(void result) => false;
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Refresh ham o'tmay qolganda login sahifasiga qaytaramiz.
    getIt<ApiClient>().onSessionExpired = () {
      if (mounted) context.read<AuthCubit>().sessionExpired();
    };
    // Mehmonxona xizmati to'xtatilsa — sabab ekrani. Sessiya saqlanadi.
    getIt<ApiClient>().onServiceStopped = (code, message) {
      if (mounted) context.read<AuthCubit>().serviceStopped(code, message);
    };
    // Ish vaqti tugadi (mehmonxona cheklagan) — ish vaqti ekrani.
    // Sessiya saqlanadi.
    getIt<ApiClient>().onOutsideWorkHours = (message) {
      if (mounted) context.read<AuthCubit>().outsideWorkHours(message);
    };
  }

  static bool _isBlocking(AuthStatus status) =>
      status == AuthStatus.outsideWorkHours ||
      status == AuthStatus.serviceStopped;

  /// To'siq ekrani ilovaning ILDIZIDA almashadi, ochiq sahifalar (vazifa,
  /// kamera, bildirishnomalar) va oynalar esa uning ustida turadi — ular
  /// yopilmasa to'siq ko'rinmay, ular ham 403 olib yotaverardi.
  ///
  /// Yopish keyingi kadrdan KEYIN: to'siqni qo'zg'atgan 403 so'rovining
  /// egasi (masalan skanerning "o'qilmoqda" oynasi) xatoni olgach o'z
  /// oynasini o'zi yopadi. Shu ondayoq yopilsa, uning `pop()` i boshqa
  /// sahifaga (oxir-oqibat ildizga) tushardi — qarang [AuthGate.rootRoute].
  void _closeRoutesAboveGate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_isBlocking(context.read<AuthCubit>().state.status)) return;
      Navigator.maybeOf(context)?.popUntil((route) => route.isFirst);
    });
  }

  Future<void> _maybeOfferBiometric() async {
    final auth = context.read<AuthCubit>();
    final l10n = context.l10n;
    if (!await auth.shouldOfferBiometric()) return;
    // Yuz biriktirish darvozasi ochiladigan bo'lsa, taklif keyingi safarga
    // qoldiriladi — ikkita oyna ustma-ust chiqmasin.
    final user = auth.state.user;
    if (user != null && user.userType == 'EMPLOYEE') {
      try {
        final face = await getIt<FaceRepository>().getStatus();
        if (face.engineAvailable && !face.enrolled) return;
      } catch (_) {}
    }
    if (!mounted) return;
    await auth.prefs.setBiometricAsked();
    if (!mounted) return;
    final ok = await showConfirmSheet(
      context,
      title: l10n.biometricEnableTitle,
      body: l10n.biometricEnableBody,
      confirmLabel: l10n.enable,
      icon: Icons.fingerprint_rounded,
    );
    if (ok) {
      await auth.setBiometricEnabled(true, l10n.biometricReason);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listenWhen: (a, b) => a.status != b.status,
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          _maybeOfferBiometric();
          /* Push: kirish tugashi bilan FCM tokeni serverga ro'yxatdan
             o'tadi — bildirishnoma yaratilganda backend aynan shu
             tokenga push yuboradi. */
          getIt<PushService>().connect();
        } else if (state.status == AuthStatus.unauthenticated) {
          // Chiqqan foydalanuvchiga push kelmasin — qurilma tokeni o'chadi
          getIt<PushService>().disconnect();
        } else if (_isBlocking(state.status)) {
          _closeRoutesAboveGate();
          /* Ish vaqtidan tashqarida ham push ulangan qoladi (kirish shu
             holatda tugagan bo'lsa ham qurilma ro'yxatdan o'tadi):
             ertalab ilova ochilmagan bo'lsa ham xabar yetib keladi. */
          if (state.status == AuthStatus.outsideWorkHours) {
            getIt<PushService>().connect();
          }
        }
      },
      buildWhen: (a, b) => a.status != b.status || a.user != b.user,
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: switch (state.status) {
            AuthStatus.starting => const BootSplash(),
            AuthStatus.locked => const LockedPage(),
            AuthStatus.unauthenticated => const LoginPage(),
            AuthStatus.faceStep => const FaceVerifyPage(),
            AuthStatus.serviceStopped => const ServiceStoppedPage(),
            AuthStatus.outsideWorkHours => const OutsideWorkHoursPage(),
            AuthStatus.authenticated =>
              // Rolga qarab bosh sahifa: farrosh → farrosh moduli,
              // boshqalar → o'z bo'limlari (yoki umumiy skelet).
              // FaceEnrollGate — yuzi biriktirilmagan xodimdan (frontend'dagi
              // kabi) yuz biriktirishni talab qiladi.
              KeyedSubtree(
                key: ValueKey(state.user!.id),
                child: FaceEnrollGate(
                  user: state.user!,
                  child: RoleRegistry.resolve(state.user!).homeBuilder(),
                ),
              ),
          },
        );
      },
    );
  }
}
