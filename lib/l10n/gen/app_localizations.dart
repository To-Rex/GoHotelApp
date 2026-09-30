import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uz, this message translates to:
  /// **'GoHotel Staff'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In uz, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get save;

  /// No description provided for @retry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get close;

  /// No description provided for @refresh.
  ///
  /// In uz, this message translates to:
  /// **'Yangilash'**
  String get refresh;

  /// No description provided for @send.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get send;

  /// No description provided for @all.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get all;

  /// No description provided for @today.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get today;

  /// No description provided for @done.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi'**
  String get done;

  /// No description provided for @back.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get back;

  /// No description provided for @logout.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get logout;

  /// No description provided for @confirm.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get confirm;

  /// No description provided for @comingSoon.
  ///
  /// In uz, this message translates to:
  /// **'Tez orada'**
  String get comingSoon;

  /// No description provided for @error.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik'**
  String get error;

  /// No description provided for @optional.
  ///
  /// In uz, this message translates to:
  /// **'ixtiyoriy'**
  String get optional;

  /// No description provided for @enable.
  ///
  /// In uz, this message translates to:
  /// **'Yoqish'**
  String get enable;

  /// No description provided for @notNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir emas'**
  String get notNow;

  /// No description provided for @networkError.
  ///
  /// In uz, this message translates to:
  /// **'Internet bilan aloqa yo\'q. Ulanishni tekshirib, qayta urinib ko\'ring.'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In uz, this message translates to:
  /// **'Serverda xatolik yuz berdi. Birozdan so\'ng qayta urinib ko\'ring.'**
  String get serverError;

  /// No description provided for @sessionExpired.
  ///
  /// In uz, this message translates to:
  /// **'Sessiya muddati tugadi. Qaytadan kiring.'**
  String get sessionExpired;

  /// No description provided for @permissionDenied.
  ///
  /// In uz, this message translates to:
  /// **'Bu amal uchun sizda ruxsat yo\'q.'**
  String get permissionDenied;

  /// No description provided for @welcomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish uchun hisobingizga kiring'**
  String get welcomeSubtitle;

  /// No description provided for @username.
  ///
  /// In uz, this message translates to:
  /// **'Login'**
  String get username;

  /// No description provided for @password.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get signIn;

  /// No description provided for @fieldRequired.
  ///
  /// In uz, this message translates to:
  /// **'Bu maydon to\'ldirilishi shart'**
  String get fieldRequired;

  /// No description provided for @wrongCredentials.
  ///
  /// In uz, this message translates to:
  /// **'Login yoki parol noto\'g\'ri'**
  String get wrongCredentials;

  /// No description provided for @faceStepTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yuzni tasdiqlash'**
  String get faceStepTitle;

  /// No description provided for @faceStepBody.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik uchun yuzingizni tasdiqlang. Kameraga to\'g\'ri qarab, yorug\' joyda suratga oling.'**
  String get faceStepBody;

  /// No description provided for @faceOpenCamera.
  ///
  /// In uz, this message translates to:
  /// **'Kamerani ochish'**
  String get faceOpenCamera;

  /// No description provided for @faceRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta suratga olish'**
  String get faceRetry;

  /// No description provided for @faceNoCameraBtn.
  ///
  /// In uz, this message translates to:
  /// **'Kamerasiz kirish'**
  String get faceNoCameraBtn;

  /// No description provided for @faceNoCameraReason.
  ///
  /// In uz, this message translates to:
  /// **'Qurilmada kamera ishlamayapti'**
  String get faceNoCameraReason;

  /// No description provided for @faceNotRecognized.
  ///
  /// In uz, this message translates to:
  /// **'Yuz mos kelmadi. Qayta urinib ko\'ring.'**
  String get faceNotRecognized;

  /// No description provided for @faceNotDetected.
  ///
  /// In uz, this message translates to:
  /// **'Yuz aniqlanmadi — kameraga to\'g\'ri qarab qayta uriring.'**
  String get faceNotDetected;

  /// No description provided for @devicePendingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qurilma tasdiq kutmoqda'**
  String get devicePendingTitle;

  /// No description provided for @devicePendingBody.
  ///
  /// In uz, this message translates to:
  /// **'Bu qurilmadan birinchi marta kirilmoqda. Administrator qurilmani tasdiqlagach, qayta urinib ko\'ring.'**
  String get devicePendingBody;

  /// No description provided for @deviceBlockedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qurilma bloklangan'**
  String get deviceBlockedTitle;

  /// No description provided for @deviceBlockedBody.
  ///
  /// In uz, this message translates to:
  /// **'Bu qurilmadan kirish taqiqlangan. Administratorga murojaat qiling.'**
  String get deviceBlockedBody;

  /// No description provided for @scanTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatni skanerlash'**
  String get scanTitle;

  /// No description provided for @scanPickType.
  ///
  /// In uz, this message translates to:
  /// **'Hujjat turi'**
  String get scanPickType;

  /// No description provided for @scanPickTypeBody.
  ///
  /// In uz, this message translates to:
  /// **'Qaysi hujjatni skanerlaymiz?'**
  String get scanPickTypeBody;

  /// No description provided for @scanIdCard.
  ///
  /// In uz, this message translates to:
  /// **'ID karta'**
  String get scanIdCard;

  /// No description provided for @scanIdCardBody.
  ///
  /// In uz, this message translates to:
  /// **'Old tomoni yetarli — xohlasangiz orqasini ham qo\'shasiz'**
  String get scanIdCardBody;

  /// No description provided for @scanPassport.
  ///
  /// In uz, this message translates to:
  /// **'Passport'**
  String get scanPassport;

  /// No description provided for @scanPassportBody.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot sahifasi'**
  String get scanPassportBody;

  /// No description provided for @scanStepFront.
  ///
  /// In uz, this message translates to:
  /// **'Old tomon'**
  String get scanStepFront;

  /// No description provided for @scanStepBack.
  ///
  /// In uz, this message translates to:
  /// **'Orqa tomon'**
  String get scanStepBack;

  /// No description provided for @scanSendOneSide.
  ///
  /// In uz, this message translates to:
  /// **'Old tomoni yetarli — jo\'natish'**
  String get scanSendOneSide;

  /// No description provided for @scanStepPassport.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumot sahifasi'**
  String get scanStepPassport;

  /// No description provided for @scanGuide.
  ///
  /// In uz, this message translates to:
  /// **'Hujjatni ramka ichiga to\'liq joylang va qimirlatmay turing'**
  String get scanGuide;

  /// No description provided for @scanReading.
  ///
  /// In uz, this message translates to:
  /// **'Hujjat o\'qilmoqda...'**
  String get scanReading;

  /// No description provided for @scanCameraFailed.
  ///
  /// In uz, this message translates to:
  /// **'Kamera ochilmadi'**
  String get scanCameraFailed;

  /// No description provided for @scanFailedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hujjat o\'qilmadi'**
  String get scanFailedTitle;

  /// No description provided for @scanMatchedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mehmon topildi'**
  String get scanMatchedTitle;

  /// No description provided for @scanNewGuestTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi mijoz'**
  String get scanNewGuestTitle;

  /// No description provided for @scanSentBody.
  ///
  /// In uz, this message translates to:
  /// **'Qabulxona ekranida yangi bandlov oynasi ochildi.'**
  String get scanSentBody;

  /// No description provided for @scanAgain.
  ///
  /// In uz, this message translates to:
  /// **'Qayta skanerlash'**
  String get scanAgain;

  /// No description provided for @serviceStoppedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xizmat to\'xtatilgan'**
  String get serviceStoppedTitle;

  /// No description provided for @serviceStoppedBody.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxonangiz uchun tizim vaqtincha o\'chirib qo\'yilgan. Bu ilovadagi nosozlik emas — ma\'lumotlaringiz saqlanmoqda.'**
  String get serviceStoppedBody;

  /// No description provided for @serviceStoppedHint.
  ///
  /// In uz, this message translates to:
  /// **'Xizmatni tiklash uchun tizim ma\'muriga murojaat qiling. Tiklangach «Qayta tekshirish» tugmasi ishni davom ettiradi.'**
  String get serviceStoppedHint;

  /// No description provided for @serviceStoppedRetry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta tekshirish'**
  String get serviceStoppedRetry;

  /// No description provided for @biometricEnableTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tez kirish'**
  String get biometricEnableTitle;

  /// No description provided for @biometricEnableBody.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi safar ilovaga barmoq izi yoki yuz orqali tez kirishni yoqasizmi?'**
  String get biometricEnableBody;

  /// No description provided for @biometricReason.
  ///
  /// In uz, this message translates to:
  /// **'Ilovaga kirish uchun shaxsingizni tasdiqlang'**
  String get biometricReason;

  /// No description provided for @unlock.
  ///
  /// In uz, this message translates to:
  /// **'Ochish'**
  String get unlock;

  /// No description provided for @unlockTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilova qulflangan'**
  String get unlockTitle;

  /// No description provided for @unlockBody.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish uchun shaxsingizni tasdiqlang'**
  String get unlockBody;

  /// No description provided for @loginAsOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa hisob bilan kirish'**
  String get loginAsOther;

  /// No description provided for @tabTasks.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get tabTasks;

  /// No description provided for @tabRooms.
  ///
  /// In uz, this message translates to:
  /// **'Xonalar'**
  String get tabRooms;

  /// No description provided for @tabChat.
  ///
  /// In uz, this message translates to:
  /// **'Chat'**
  String get tabChat;

  /// No description provided for @tabProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get tabProfile;

  /// No description provided for @goodMorning.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli tong'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli kun'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli kech'**
  String get goodEvening;

  /// No description provided for @tasksTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash vazifalari'**
  String get tasksTitle;

  /// No description provided for @filterAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get filterAll;

  /// No description provided for @filterNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi'**
  String get filterNew;

  /// No description provided for @filterInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get filterInProgress;

  /// No description provided for @filterDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilgan'**
  String get filterDone;

  /// No description provided for @roomTitle.
  ///
  /// In uz, this message translates to:
  /// **'{n}-xona'**
  String roomTitle(String n);

  /// No description provided for @urgentBadge.
  ///
  /// In uz, this message translates to:
  /// **'Shoshilinch'**
  String get urgentBadge;

  /// No description provided for @deadlineAt.
  ///
  /// In uz, this message translates to:
  /// **'Muddat: {time}'**
  String deadlineAt(String time);

  /// No description provided for @guestLabel.
  ///
  /// In uz, this message translates to:
  /// **'Mehmon'**
  String get guestLabel;

  /// No description provided for @statusNew.
  ///
  /// In uz, this message translates to:
  /// **'Yangi'**
  String get statusNew;

  /// No description provided for @statusInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilgan'**
  String get statusDone;

  /// No description provided for @startCleaning.
  ///
  /// In uz, this message translates to:
  /// **'Tozalashni boshlash'**
  String get startCleaning;

  /// No description provided for @finishCleaning.
  ///
  /// In uz, this message translates to:
  /// **'Tozalashni yakunlash'**
  String get finishCleaning;

  /// No description provided for @confirmFinishTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash yakunlandimi?'**
  String get confirmFinishTitle;

  /// No description provided for @confirmFinishBody.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa bajarilgan deb belgilanadi va xona “Bo\'sh” holatiga o\'tadi.'**
  String get confirmFinishBody;

  /// No description provided for @cleaningDone.
  ///
  /// In uz, this message translates to:
  /// **'Barakalla! Xona tozalandi ✅'**
  String get cleaningDone;

  /// No description provided for @checklistTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bajariladigan ishlar'**
  String get checklistTitle;

  /// No description provided for @checklistRemaining.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta ish belgilanmagan'**
  String checklistRemaining(int count);

  /// No description provided for @confirmFinishBodyRemaining.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta ish hali belgilanmagan. Baribir yakunlaysizmi? Vazifa bajarilgan deb belgilanadi va xona “Bo\'sh” holatiga o\'tadi.'**
  String confirmFinishBodyRemaining(int count);

  /// No description provided for @checklistAllDone.
  ///
  /// In uz, this message translates to:
  /// **'Barcha ishlar belgilandi'**
  String get checklistAllDone;

  /// No description provided for @progressLabel.
  ///
  /// In uz, this message translates to:
  /// **'Bajarilishi'**
  String get progressLabel;

  /// No description provided for @photoReportTitle.
  ///
  /// In uz, this message translates to:
  /// **'Foto hisobot'**
  String get photoReportTitle;

  /// No description provided for @addPhoto.
  ///
  /// In uz, this message translates to:
  /// **'Rasm qo\'shish'**
  String get addPhoto;

  /// No description provided for @commentHint.
  ///
  /// In uz, this message translates to:
  /// **'Izoh (ixtiyoriy)'**
  String get commentHint;

  /// No description provided for @sendReport.
  ///
  /// In uz, this message translates to:
  /// **'Hisobotni yuborish'**
  String get sendReport;

  /// No description provided for @reportSentOk.
  ///
  /// In uz, this message translates to:
  /// **'Foto hisobot yuborildi'**
  String get reportSentOk;

  /// No description provided for @reportProblem.
  ///
  /// In uz, this message translates to:
  /// **'Muammo haqida xabar berish'**
  String get reportProblem;

  /// No description provided for @noteLabel.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get noteLabel;

  /// No description provided for @noTasksTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha vazifa yo\'q'**
  String get noTasksTitle;

  /// No description provided for @noTasksBody.
  ///
  /// In uz, this message translates to:
  /// **'Sizga yangi vazifa berilganda shu yerda ko\'rinadi va bildirishnoma keladi.'**
  String get noTasksBody;

  /// No description provided for @tasksSummary.
  ///
  /// In uz, this message translates to:
  /// **'{done} / {total} bajarildi'**
  String tasksSummary(int done, int total);

  /// No description provided for @problemTitle.
  ///
  /// In uz, this message translates to:
  /// **'Muammo haqida xabar'**
  String get problemTitle;

  /// No description provided for @problemCategoryLabel.
  ///
  /// In uz, this message translates to:
  /// **'Muammo turi'**
  String get problemCategoryLabel;

  /// No description provided for @problemDescLabel.
  ///
  /// In uz, this message translates to:
  /// **'Tavsif'**
  String get problemDescLabel;

  /// No description provided for @problemDescHint.
  ///
  /// In uz, this message translates to:
  /// **'Muammoni qisqacha yozing...'**
  String get problemDescHint;

  /// No description provided for @problemPhotos.
  ///
  /// In uz, this message translates to:
  /// **'Rasmlar'**
  String get problemPhotos;

  /// No description provided for @problemSubmit.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yuborish'**
  String get problemSubmit;

  /// No description provided for @problemSentOk.
  ///
  /// In uz, this message translates to:
  /// **'Muammo haqida xabar yuborildi'**
  String get problemSentOk;

  /// No description provided for @catBroken.
  ///
  /// In uz, this message translates to:
  /// **'Siniq buyum'**
  String get catBroken;

  /// No description provided for @catTechnical.
  ///
  /// In uz, this message translates to:
  /// **'Texnik nosozlik'**
  String get catTechnical;

  /// No description provided for @catWater.
  ///
  /// In uz, this message translates to:
  /// **'Suv sizishi'**
  String get catWater;

  /// No description provided for @catBurnt.
  ///
  /// In uz, this message translates to:
  /// **'Chiroq kuygan'**
  String get catBurnt;

  /// No description provided for @catElectric.
  ///
  /// In uz, this message translates to:
  /// **'Elektr nosozligi'**
  String get catElectric;

  /// No description provided for @catMechanism.
  ///
  /// In uz, this message translates to:
  /// **'Mexanizm buzilgan'**
  String get catMechanism;

  /// No description provided for @catOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get catOther;

  /// No description provided for @roomsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xonalar'**
  String get roomsTitle;

  /// No description provided for @tabOccupied.
  ///
  /// In uz, this message translates to:
  /// **'Band xonalar'**
  String get tabOccupied;

  /// No description provided for @tabUpcoming.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin tozalash'**
  String get tabUpcoming;

  /// No description provided for @checkoutLabel.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish vaqti'**
  String get checkoutLabel;

  /// No description provided for @overdueBadge.
  ///
  /// In uz, this message translates to:
  /// **'Vaqti o\'tgan'**
  String get overdueBadge;

  /// No description provided for @leftMinutes.
  ///
  /// In uz, this message translates to:
  /// **'{n} daqiqa qoldi'**
  String leftMinutes(int n);

  /// No description provided for @leftHours.
  ///
  /// In uz, this message translates to:
  /// **'{h} soat {m} daq. qoldi'**
  String leftHours(int h, int m);

  /// No description provided for @guestRequests.
  ///
  /// In uz, this message translates to:
  /// **'Mehmon so\'rovlari'**
  String get guestRequests;

  /// No description provided for @writeToReception.
  ///
  /// In uz, this message translates to:
  /// **'Resepshnga yozish'**
  String get writeToReception;

  /// No description provided for @reservedBadge.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get reservedBadge;

  /// No description provided for @checkedInBadge.
  ///
  /// In uz, this message translates to:
  /// **'Mehmon ichkarida'**
  String get checkedInBadge;

  /// No description provided for @bookingDaily.
  ///
  /// In uz, this message translates to:
  /// **'Kunlik'**
  String get bookingDaily;

  /// No description provided for @bookingHourly.
  ///
  /// In uz, this message translates to:
  /// **'Soatlik'**
  String get bookingHourly;

  /// No description provided for @noOccupiedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Band xonalar yo\'q'**
  String get noOccupiedTitle;

  /// No description provided for @noOccupiedBody.
  ///
  /// In uz, this message translates to:
  /// **'Hozirda mehmon joylashgan xonalar yo\'q.'**
  String get noOccupiedBody;

  /// No description provided for @upcomingEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yaqin tozalash yo\'q'**
  String get upcomingEmptyTitle;

  /// No description provided for @upcomingEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish vaqti yaqinlashgan xonalar shu yerda ko\'rinadi.'**
  String get upcomingEmptyBody;

  /// No description provided for @upcomingHint.
  ///
  /// In uz, this message translates to:
  /// **'Mehmon chiqqach, xonani tozalash kerak bo\'ladi. Ro\'yxat chiqish vaqtiga qarab tartiblangan.'**
  String get upcomingHint;

  /// No description provided for @roomStatusAvailable.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'sh'**
  String get roomStatusAvailable;

  /// No description provided for @roomStatusReserved.
  ///
  /// In uz, this message translates to:
  /// **'Bron qilingan'**
  String get roomStatusReserved;

  /// No description provided for @roomStatusOccupied.
  ///
  /// In uz, this message translates to:
  /// **'Band'**
  String get roomStatusOccupied;

  /// No description provided for @roomStatusCleaning.
  ///
  /// In uz, this message translates to:
  /// **'Tozalanmoqda'**
  String get roomStatusCleaning;

  /// No description provided for @roomStatusMaintenance.
  ///
  /// In uz, this message translates to:
  /// **'Ta\'mirda'**
  String get roomStatusMaintenance;

  /// No description provided for @roomStatusInspection.
  ///
  /// In uz, this message translates to:
  /// **'Tekshiruvda'**
  String get roomStatusInspection;

  /// No description provided for @roomStatusOutOfService.
  ///
  /// In uz, this message translates to:
  /// **'Ishlamayapti'**
  String get roomStatusOutOfService;

  /// No description provided for @chatTitle.
  ///
  /// In uz, this message translates to:
  /// **'Resepshn bilan chat'**
  String get chatTitle;

  /// No description provided for @chatSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Xabarlar barcha xodimlarga ko\'rinadi'**
  String get chatSubtitle;

  /// No description provided for @messageHint.
  ///
  /// In uz, this message translates to:
  /// **'Xabar yozing...'**
  String get messageHint;

  /// No description provided for @markDone.
  ///
  /// In uz, this message translates to:
  /// **'Bajarildi deb belgilash'**
  String get markDone;

  /// No description provided for @doneByName.
  ///
  /// In uz, this message translates to:
  /// **'Bajardi: {name}'**
  String doneByName(String name);

  /// No description provided for @openBadge.
  ///
  /// In uz, this message translates to:
  /// **'Ochiq'**
  String get openBadge;

  /// No description provided for @attachPhoto.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuborish'**
  String get attachPhoto;

  /// No description provided for @imageMessageBody.
  ///
  /// In uz, this message translates to:
  /// **'📷 Rasm'**
  String get imageMessageBody;

  /// No description provided for @uploadImageDenied.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuborish uchun sizga «file.upload» ruxsati berilmagan. Administratorga murojaat qiling.'**
  String get uploadImageDenied;

  /// No description provided for @noMessagesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xabarlar yo\'q'**
  String get noMessagesTitle;

  /// No description provided for @noMessagesBody.
  ///
  /// In uz, this message translates to:
  /// **'Resepshn va boshqa xodimlar bilan yozishmalar shu yerda ko\'rinadi.'**
  String get noMessagesBody;

  /// No description provided for @selectRoom.
  ///
  /// In uz, this message translates to:
  /// **'Xonani tanlash'**
  String get selectRoom;

  /// No description provided for @noRoom.
  ///
  /// In uz, this message translates to:
  /// **'Xonasiz'**
  String get noRoom;

  /// No description provided for @notificationsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notificationsTitle;

  /// No description provided for @markAllRead.
  ///
  /// In uz, this message translates to:
  /// **'Barchasini o\'qilgan qilish'**
  String get markAllRead;

  /// No description provided for @noNotifsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnoma yo\'q'**
  String get noNotifsTitle;

  /// No description provided for @noNotifsBody.
  ///
  /// In uz, this message translates to:
  /// **'Yangi vazifa va xabarlar haqidagi bildirishnomalar shu yerda ko\'rinadi.'**
  String get noNotifsBody;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @positionLabel.
  ///
  /// In uz, this message translates to:
  /// **'Lavozim'**
  String get positionLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get phoneLabel;

  /// No description provided for @idLabel.
  ///
  /// In uz, this message translates to:
  /// **'Xodim ID'**
  String get idLabel;

  /// No description provided for @hotelLabel.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonxona'**
  String get hotelLabel;

  /// No description provided for @scheduleLabel.
  ///
  /// In uz, this message translates to:
  /// **'Ish vaqti'**
  String get scheduleLabel;

  /// No description provided for @statsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ish statistikasi'**
  String get statsTitle;

  /// No description provided for @statToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get statToday;

  /// No description provided for @statWeek.
  ///
  /// In uz, this message translates to:
  /// **'Bu hafta'**
  String get statWeek;

  /// No description provided for @statMonth.
  ///
  /// In uz, this message translates to:
  /// **'Bu oy'**
  String get statMonth;

  /// No description provided for @statAvg.
  ///
  /// In uz, this message translates to:
  /// **'O\'rtacha vaqt'**
  String get statAvg;

  /// No description provided for @statActive.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get statActive;

  /// No description provided for @completedTasks.
  ///
  /// In uz, this message translates to:
  /// **'bajarilgan'**
  String get completedTasks;

  /// No description provided for @statMinutes.
  ///
  /// In uz, this message translates to:
  /// **'{n} daqiqa'**
  String statMinutes(int n);

  /// No description provided for @settingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settingsTitle;

  /// No description provided for @languageLabel.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get languageLabel;

  /// No description provided for @themeLabel.
  ///
  /// In uz, this message translates to:
  /// **'Mavzu'**
  String get themeLabel;

  /// No description provided for @themeLight.
  ///
  /// In uz, this message translates to:
  /// **'Kunduzgi'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uz, this message translates to:
  /// **'Tungi'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim bo\'yicha'**
  String get themeSystem;

  /// No description provided for @quickUnlockLabel.
  ///
  /// In uz, this message translates to:
  /// **'Tez kirish (Face ID / barmoq izi)'**
  String get quickUnlockLabel;

  /// No description provided for @quickUnlockDesc.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani ochishda biometrik tasdiq so\'raladi'**
  String get quickUnlockDesc;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobdan chiqasizmi?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmBody.
  ///
  /// In uz, this message translates to:
  /// **'Qaytadan kirish uchun login va parol kerak bo\'ladi.'**
  String get logoutConfirmBody;

  /// No description provided for @appVersion.
  ///
  /// In uz, this message translates to:
  /// **'Versiya {v}'**
  String appVersion(String v);

  /// No description provided for @roleHousekeeper.
  ///
  /// In uz, this message translates to:
  /// **'Farrosh'**
  String get roleHousekeeper;

  /// No description provided for @roleAdmin.
  ///
  /// In uz, this message translates to:
  /// **'Administrator'**
  String get roleAdmin;

  /// No description provided for @roleManager.
  ///
  /// In uz, this message translates to:
  /// **'Menejer'**
  String get roleManager;

  /// No description provided for @roleReception.
  ///
  /// In uz, this message translates to:
  /// **'Qabulxona xodimi'**
  String get roleReception;

  /// No description provided for @roleMaintenance.
  ///
  /// In uz, this message translates to:
  /// **'Texnik xizmat'**
  String get roleMaintenance;

  /// No description provided for @roleAccountant.
  ///
  /// In uz, this message translates to:
  /// **'Buxgalter'**
  String get roleAccountant;

  /// No description provided for @roleStaff.
  ///
  /// In uz, this message translates to:
  /// **'Xodim'**
  String get roleStaff;

  /// No description provided for @roleHomeSoonTitle.
  ///
  /// In uz, this message translates to:
  /// **'{role} bo\'limi tez orada'**
  String roleHomeSoonTitle(String role);

  /// No description provided for @roleHomeSoonBody.
  ///
  /// In uz, this message translates to:
  /// **'Sizning lavozimingiz uchun maxsus bo\'lim ishlab chiqilmoqda. Hozircha chat, bildirishnoma va profil bo\'limlaridan foydalanishingiz mumkin.'**
  String get roleHomeSoonBody;

  /// No description provided for @yourTools.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud imkoniyatlar'**
  String get yourTools;

  /// No description provided for @faceGateTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni biriktiring'**
  String get faceGateTitle;

  /// No description provided for @faceGateBody.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kirish ikki bosqichli: parol va yuz. Sizda hali yuz biriktirilmagan — hisobingizni hozircha faqat parol himoya qilyapti. Davom etish uchun yuzingizni biriktiring.'**
  String get faceGateBody;

  /// No description provided for @faceEnrollAction.
  ///
  /// In uz, this message translates to:
  /// **'Yuzni biriktirish'**
  String get faceEnrollAction;

  /// No description provided for @faceEnrolledOk.
  ///
  /// In uz, this message translates to:
  /// **'Yuz biriktirildi ✅'**
  String get faceEnrolledOk;

  /// No description provided for @faceSection.
  ///
  /// In uz, this message translates to:
  /// **'Yuz bilan kirish'**
  String get faceSection;

  /// No description provided for @faceStatusEnrolled.
  ///
  /// In uz, this message translates to:
  /// **'Biriktirilgan · {count} ta namuna'**
  String faceStatusEnrolled(int count);

  /// No description provided for @faceStatusNotEnrolled.
  ///
  /// In uz, this message translates to:
  /// **'Biriktirilmagan'**
  String get faceStatusNotEnrolled;

  /// No description provided for @faceAddSample.
  ///
  /// In uz, this message translates to:
  /// **'Yana namuna qo\'shish'**
  String get faceAddSample;

  /// No description provided for @faceDeleteAction.
  ///
  /// In uz, this message translates to:
  /// **'Yuz profillarini o\'chirish'**
  String get faceDeleteAction;

  /// No description provided for @faceDeleteTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yuz profillarini o\'chirasizmi?'**
  String get faceDeleteTitle;

  /// No description provided for @faceDeleteBody.
  ///
  /// In uz, this message translates to:
  /// **'Kirishda yuz so\'ralmaydi va tizim keyingi kirishda qaytadan biriktirishni talab qiladi.'**
  String get faceDeleteBody;

  /// No description provided for @faceDeletedOk.
  ///
  /// In uz, this message translates to:
  /// **'Yuz profillari o\'chirildi'**
  String get faceDeletedOk;

  /// No description provided for @faceEngineOff.
  ///
  /// In uz, this message translates to:
  /// **'Serverda yuz tekshiruvi hozircha yoqilmagan.'**
  String get faceEngineOff;

  /// No description provided for @faceAutoPlace.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni oval ichiga joylashtiring'**
  String get faceAutoPlace;

  /// No description provided for @faceAutoCloser.
  ///
  /// In uz, this message translates to:
  /// **'Yaqinroq keling'**
  String get faceAutoCloser;

  /// No description provided for @faceAutoFarther.
  ///
  /// In uz, this message translates to:
  /// **'Biroz uzoqlashing'**
  String get faceAutoFarther;

  /// No description provided for @faceAutoCenter.
  ///
  /// In uz, this message translates to:
  /// **'Yuzingizni markazga joylang'**
  String get faceAutoCenter;

  /// No description provided for @faceAutoLookStraight.
  ///
  /// In uz, this message translates to:
  /// **'Kameraga to\'g\'ri qarang'**
  String get faceAutoLookStraight;

  /// No description provided for @faceAutoHold.
  ///
  /// In uz, this message translates to:
  /// **'Qimirlamay turing…'**
  String get faceAutoHold;

  /// No description provided for @tabBookings.
  ///
  /// In uz, this message translates to:
  /// **'Bronlar'**
  String get tabBookings;

  /// No description provided for @tabReport.
  ///
  /// In uz, this message translates to:
  /// **'Hisobot'**
  String get tabReport;

  /// No description provided for @bookingsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bronlar'**
  String get bookingsTitle;

  /// No description provided for @bookingsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Kelayotgan, turgan va chiqayotganlar'**
  String get bookingsSubtitle;

  /// No description provided for @bookingsSearchHint.
  ///
  /// In uz, this message translates to:
  /// **'Mehmon, bron raqami yoki xona...'**
  String get bookingsSearchHint;

  /// No description provided for @bookingsAll.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi'**
  String get bookingsAll;

  /// No description provided for @bookingArrival.
  ///
  /// In uz, this message translates to:
  /// **'Kelish'**
  String get bookingArrival;

  /// No description provided for @bookingInhouse.
  ///
  /// In uz, this message translates to:
  /// **'Turibdi'**
  String get bookingInhouse;

  /// No description provided for @bookingDeparture.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get bookingDeparture;

  /// No description provided for @bookingsEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bu kunda bron yo\'q'**
  String get bookingsEmptyTitle;

  /// No description provided for @bookingsEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa kunni tanlang yoki keyinroq qarang.'**
  String get bookingsEmptyBody;

  /// No description provided for @bookingsNotFoundTitle.
  ///
  /// In uz, this message translates to:
  /// **'Topilmadi'**
  String get bookingsNotFoundTitle;

  /// No description provided for @bookingsNotFoundBody.
  ///
  /// In uz, this message translates to:
  /// **'Qidiruv bo\'yicha bron topilmadi.'**
  String get bookingsNotFoundBody;

  /// No description provided for @bookingPaid.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get bookingPaid;

  /// No description provided for @bookingCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get bookingCancelled;

  /// No description provided for @bookingDebt.
  ///
  /// In uz, this message translates to:
  /// **'Qarz: {amount}'**
  String bookingDebt(String amount);

  /// No description provided for @bookingPeriod.
  ///
  /// In uz, this message translates to:
  /// **'Muddat'**
  String get bookingPeriod;

  /// No description provided for @bookingGuests.
  ///
  /// In uz, this message translates to:
  /// **'Mehmonlar'**
  String get bookingGuests;

  /// No description provided for @bookingPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get bookingPhone;

  /// No description provided for @bookingNote.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get bookingNote;

  /// No description provided for @bookingTotal.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy summa'**
  String get bookingTotal;

  /// No description provided for @bookingPaidAmount.
  ///
  /// In uz, this message translates to:
  /// **'To\'langan'**
  String get bookingPaidAmount;

  /// No description provided for @bookingRemaining.
  ///
  /// In uz, this message translates to:
  /// **'Qoldiq'**
  String get bookingRemaining;

  /// No description provided for @bookingReadOnlyHint.
  ///
  /// In uz, this message translates to:
  /// **'Bron bu yerda faqat ko\'rinadi. Tahrirlash, to\'lov qabul qilish va chiqarish katta ekranda bajariladi.'**
  String get bookingReadOnlyHint;

  /// No description provided for @previousDay.
  ///
  /// In uz, this message translates to:
  /// **'Oldingi kun'**
  String get previousDay;

  /// No description provided for @nextDay.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi kun'**
  String get nextDay;

  /// No description provided for @copied.
  ///
  /// In uz, this message translates to:
  /// **'Nusxa olindi'**
  String get copied;

  /// No description provided for @periodToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get periodToday;

  /// No description provided for @periodYesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get periodYesterday;

  /// No description provided for @periodLast7.
  ///
  /// In uz, this message translates to:
  /// **'7 kun'**
  String get periodLast7;

  /// No description provided for @periodThisMonth.
  ///
  /// In uz, this message translates to:
  /// **'Shu oy'**
  String get periodThisMonth;

  /// No description provided for @reportNet.
  ///
  /// In uz, this message translates to:
  /// **'Sof natija'**
  String get reportNet;

  /// No description provided for @reportNetBreakdown.
  ///
  /// In uz, this message translates to:
  /// **'Tushum {income} − xarajat {expense}'**
  String reportNetBreakdown(String income, String expense);

  /// No description provided for @reportCollected.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilingan pul'**
  String get reportCollected;

  /// No description provided for @reportCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd: {amount}'**
  String reportCash(String amount);

  /// No description provided for @reportBookings.
  ///
  /// In uz, this message translates to:
  /// **'Bronlarim'**
  String get reportBookings;

  /// No description provided for @reportCancelled.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta bekor qilingan'**
  String reportCancelled(int count);

  /// No description provided for @reportShop.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon savdosi'**
  String get reportShop;

  /// No description provided for @reportShopCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta sotuv'**
  String reportShopCount(int count);

  /// No description provided for @reportExpenses.
  ///
  /// In uz, this message translates to:
  /// **'Xarajatlarim'**
  String get reportExpenses;

  /// No description provided for @reportExpenseCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta chiqim'**
  String reportExpenseCount(int count);

  /// No description provided for @reportRefunds.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarilgan'**
  String get reportRefunds;

  /// No description provided for @reportRefundsHint.
  ///
  /// In uz, this message translates to:
  /// **'tushumdan ayirilgan'**
  String get reportRefundsHint;

  /// No description provided for @reportShopUnpaid.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon qarzi'**
  String get reportShopUnpaid;

  /// No description provided for @reportShopUnpaidHint.
  ///
  /// In uz, this message translates to:
  /// **'bronga yozilgan'**
  String get reportShopUnpaidHint;

  /// No description provided for @reportByMethod.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usullari bo\'yicha'**
  String get reportByMethod;

  /// No description provided for @methodCash.
  ///
  /// In uz, this message translates to:
  /// **'Naqd pul'**
  String get methodCash;

  /// No description provided for @methodCard.
  ///
  /// In uz, this message translates to:
  /// **'Bank kartasi'**
  String get methodCard;

  /// No description provided for @methodOnline.
  ///
  /// In uz, this message translates to:
  /// **'Online to\'lov'**
  String get methodOnline;

  /// No description provided for @methodBankTransfer.
  ///
  /// In uz, this message translates to:
  /// **'Bank o\'tkazmasi'**
  String get methodBankTransfer;

  /// No description provided for @methodOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get methodOther;

  /// No description provided for @callWatchTitle.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'ng\'iroq bo\'yicha mehmonni aniqlash'**
  String get callWatchTitle;

  /// No description provided for @callWatchBody.
  ///
  /// In uz, this message translates to:
  /// **'Mehmon qo\'ng\'iroq qilganda uning ismi va xonasi kompyuter ekranida ko\'rinadi. Buning uchun qurilmadan qo\'ng\'iroq raqamini o\'qishga ruxsat kerak.'**
  String get callWatchBody;

  /// No description provided for @callWatchEnable.
  ///
  /// In uz, this message translates to:
  /// **'Yoqish'**
  String get callWatchEnable;

  /// No description provided for @callWatchEnabled.
  ///
  /// In uz, this message translates to:
  /// **'Yoqildi — endi qo\'ng\'iroqlar kompyuterda ko\'rinadi'**
  String get callWatchEnabled;

  /// No description provided for @callMatched.
  ///
  /// In uz, this message translates to:
  /// **'{name} qo\'ng\'iroq qilmoqda'**
  String callMatched(String name);

  /// No description provided for @dismiss.
  ///
  /// In uz, this message translates to:
  /// **'Yopish'**
  String get dismiss;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'ru':
      return SRu();
    case 'uz':
      return SUz();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
