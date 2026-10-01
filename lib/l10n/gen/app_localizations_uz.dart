// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class SUz extends S {
  SUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'GoHotel Staff';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get save => 'Saqlash';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get close => 'Yopish';

  @override
  String get refresh => 'Yangilash';

  @override
  String get send => 'Yuborish';

  @override
  String get all => 'Barchasi';

  @override
  String get today => 'Bugun';

  @override
  String get done => 'Bajarildi';

  @override
  String get back => 'Orqaga';

  @override
  String get logout => 'Chiqish';

  @override
  String get confirm => 'Tasdiqlash';

  @override
  String get comingSoon => 'Tez orada';

  @override
  String get error => 'Xatolik';

  @override
  String get optional => 'ixtiyoriy';

  @override
  String get enable => 'Yoqish';

  @override
  String get notNow => 'Hozir emas';

  @override
  String get networkError =>
      'Internet bilan aloqa yo\'q. Ulanishni tekshirib, qayta urinib ko\'ring.';

  @override
  String get serverError =>
      'Serverda xatolik yuz berdi. Birozdan so\'ng qayta urinib ko\'ring.';

  @override
  String get sessionExpired => 'Sessiya muddati tugadi. Qaytadan kiring.';

  @override
  String get permissionDenied => 'Bu amal uchun sizda ruxsat yo\'q.';

  @override
  String get welcomeTitle => 'Xush kelibsiz';

  @override
  String get welcomeSubtitle => 'Davom etish uchun hisobingizga kiring';

  @override
  String get username => 'Login';

  @override
  String get password => 'Parol';

  @override
  String get signIn => 'Kirish';

  @override
  String get fieldRequired => 'Bu maydon to\'ldirilishi shart';

  @override
  String get wrongCredentials => 'Login yoki parol noto\'g\'ri';

  @override
  String get faceStepTitle => 'Yuzni tasdiqlash';

  @override
  String get faceStepBody =>
      'Xavfsizlik uchun yuzingizni tasdiqlang. Kameraga to\'g\'ri qarab, yorug\' joyda suratga oling.';

  @override
  String get faceOpenCamera => 'Kamerani ochish';

  @override
  String get faceRetry => 'Qayta suratga olish';

  @override
  String get faceNoCameraBtn => 'Kamerasiz kirish';

  @override
  String get faceNoCameraReason => 'Qurilmada kamera ishlamayapti';

  @override
  String get faceNotRecognized => 'Yuz mos kelmadi. Qayta urinib ko\'ring.';

  @override
  String get faceNotDetected =>
      'Yuz aniqlanmadi — kameraga to\'g\'ri qarab qayta uriring.';

  @override
  String get devicePendingTitle => 'Qurilma tasdiq kutmoqda';

  @override
  String get devicePendingBody =>
      'Bu qurilmadan birinchi marta kirilmoqda. Administrator qurilmani tasdiqlagach, qayta urinib ko\'ring.';

  @override
  String get deviceBlockedTitle => 'Qurilma bloklangan';

  @override
  String get deviceBlockedBody =>
      'Bu qurilmadan kirish taqiqlangan. Administratorga murojaat qiling.';

  @override
  String get scanTitle => 'Hujjatni skanerlash';

  @override
  String get scanPickType => 'Hujjat turi';

  @override
  String get scanPickTypeBody => 'Qaysi hujjatni skanerlaymiz?';

  @override
  String get scanIdCard => 'ID karta';

  @override
  String get scanIdCardBody =>
      'Old tomoni yetarli — xohlasangiz orqasini ham qo\'shasiz';

  @override
  String get scanPassport => 'Passport';

  @override
  String get scanPassportBody => 'Ma\'lumot sahifasi';

  @override
  String get scanStepFront => 'Old tomon';

  @override
  String get scanStepBack => 'Orqa tomon';

  @override
  String get scanSendOneSide => 'Old tomoni yetarli — jo\'natish';

  @override
  String get scanStepPassport => 'Ma\'lumot sahifasi';

  @override
  String get scanGuide =>
      'Hujjatni ramka ichiga to\'liq joylang va qimirlatmay turing';

  @override
  String get scanReading => 'Hujjat o\'qilmoqda...';

  @override
  String get scanCameraFailed => 'Kamera ochilmadi';

  @override
  String get scanFailedTitle => 'Hujjat o\'qilmadi';

  @override
  String get scanMatchedTitle => 'Mehmon topildi';

  @override
  String get scanNewGuestTitle => 'Yangi mijoz';

  @override
  String get scanSentBody => 'Qabulxona ekranida yangi bandlov oynasi ochildi.';

  @override
  String get scanAgain => 'Qayta skanerlash';

  @override
  String get serviceStoppedTitle => 'Xizmat to\'xtatilgan';

  @override
  String get serviceStoppedBody =>
      'Mehmonxonangiz uchun tizim vaqtincha o\'chirib qo\'yilgan. Bu ilovadagi nosozlik emas — ma\'lumotlaringiz saqlanmoqda.';

  @override
  String get serviceStoppedHint =>
      'Xizmatni tiklash uchun tizim ma\'muriga murojaat qiling. Tiklangach «Qayta tekshirish» tugmasi ishni davom ettiradi.';

  @override
  String get serviceStoppedRetry => 'Qayta tekshirish';

  @override
  String get outsideHoursTitle => 'Ish vaqtingiz emas';

  @override
  String get outsideHoursBody =>
      'Mehmonxonada ish vaqtidan tashqari ishlash cheklangan. Ish vaqtingiz boshlanganda ilova ishni o\'zi davom ettiradi.';

  @override
  String get outsideHoursScheduleLabel => 'Ish vaqtingiz';

  @override
  String get outsideHoursHint =>
      'Ilova har daqiqada o\'zi tekshiradi. Ish vaqtidan tashqari ishlash kerak bo\'lsa, administratorga murojaat qiling.';

  @override
  String get outsideHoursRetry => 'Qayta tekshirish';

  @override
  String get outsideHoursStill => 'Hozircha ish vaqtingiz emas';

  @override
  String get outsideHoursError =>
      'Hozir ish vaqtingiz emas. Ish vaqti boshlanganda davom ettirishingiz mumkin.';

  @override
  String get biometricEnableTitle => 'Tez kirish';

  @override
  String get biometricEnableBody =>
      'Keyingi safar ilovaga barmoq izi yoki yuz orqali tez kirishni yoqasizmi?';

  @override
  String get biometricReason => 'Ilovaga kirish uchun shaxsingizni tasdiqlang';

  @override
  String get unlock => 'Ochish';

  @override
  String get unlockTitle => 'Ilova qulflangan';

  @override
  String get unlockBody => 'Davom etish uchun shaxsingizni tasdiqlang';

  @override
  String get loginAsOther => 'Boshqa hisob bilan kirish';

  @override
  String get tabTasks => 'Vazifalar';

  @override
  String get tabRooms => 'Xonalar';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabProfile => 'Profil';

  @override
  String get goodMorning => 'Xayrli tong';

  @override
  String get goodAfternoon => 'Xayrli kun';

  @override
  String get goodEvening => 'Xayrli kech';

  @override
  String get tasksTitle => 'Tozalash vazifalari';

  @override
  String get filterAll => 'Barchasi';

  @override
  String get filterNew => 'Yangi';

  @override
  String get filterInProgress => 'Jarayonda';

  @override
  String get filterDone => 'Bajarilgan';

  @override
  String roomTitle(String n) {
    return '$n-xona';
  }

  @override
  String get urgentBadge => 'Shoshilinch';

  @override
  String deadlineAt(String time) {
    return 'Muddat: $time';
  }

  @override
  String get guestLabel => 'Mehmon';

  @override
  String get statusNew => 'Yangi';

  @override
  String get statusInProgress => 'Jarayonda';

  @override
  String get statusDone => 'Bajarilgan';

  @override
  String get startCleaning => 'Tozalashni boshlash';

  @override
  String get finishCleaning => 'Tozalashni yakunlash';

  @override
  String get confirmFinishTitle => 'Tozalash yakunlandimi?';

  @override
  String get confirmFinishBody =>
      'Vazifa bajarilgan deb belgilanadi va xona “Bo\'sh” holatiga o\'tadi.';

  @override
  String get cleaningDone => 'Barakalla! Xona tozalandi ✅';

  @override
  String get checklistTitle => 'Bajariladigan ishlar';

  @override
  String checklistRemaining(int count) {
    return '$count ta ish belgilanmagan';
  }

  @override
  String confirmFinishBodyRemaining(int count) {
    return '$count ta ish hali belgilanmagan. Baribir yakunlaysizmi? Vazifa bajarilgan deb belgilanadi va xona “Bo\'sh” holatiga o\'tadi.';
  }

  @override
  String get checklistAllDone => 'Barcha ishlar belgilandi';

  @override
  String get progressLabel => 'Bajarilishi';

  @override
  String get photoReportTitle => 'Foto hisobot';

  @override
  String get addPhoto => 'Rasm qo\'shish';

  @override
  String get commentHint => 'Izoh (ixtiyoriy)';

  @override
  String get sendReport => 'Hisobotni yuborish';

  @override
  String get reportSentOk => 'Foto hisobot yuborildi';

  @override
  String get reportProblem => 'Muammo haqida xabar berish';

  @override
  String get noteLabel => 'Izoh';

  @override
  String get noTasksTitle => 'Hozircha vazifa yo\'q';

  @override
  String get noTasksBody =>
      'Sizga yangi vazifa berilganda shu yerda ko\'rinadi va bildirishnoma keladi.';

  @override
  String tasksSummary(int done, int total) {
    return '$done / $total bajarildi';
  }

  @override
  String get problemTitle => 'Muammo haqida xabar';

  @override
  String get problemCategoryLabel => 'Muammo turi';

  @override
  String get problemDescLabel => 'Tavsif';

  @override
  String get problemDescHint => 'Muammoni qisqacha yozing...';

  @override
  String get problemPhotos => 'Rasmlar';

  @override
  String get problemSubmit => 'Xabar yuborish';

  @override
  String get problemSentOk => 'Muammo haqida xabar yuborildi';

  @override
  String get catBroken => 'Siniq buyum';

  @override
  String get catTechnical => 'Texnik nosozlik';

  @override
  String get catWater => 'Suv sizishi';

  @override
  String get catBurnt => 'Chiroq kuygan';

  @override
  String get catElectric => 'Elektr nosozligi';

  @override
  String get catMechanism => 'Mexanizm buzilgan';

  @override
  String get catOther => 'Boshqa';

  @override
  String get roomsTitle => 'Xonalar';

  @override
  String get tabOccupied => 'Band xonalar';

  @override
  String get tabUpcoming => 'Yaqin tozalash';

  @override
  String get checkoutLabel => 'Chiqish vaqti';

  @override
  String get overdueBadge => 'Vaqti o\'tgan';

  @override
  String leftMinutes(int n) {
    return '$n daqiqa qoldi';
  }

  @override
  String leftHours(int h, int m) {
    return '$h soat $m daq. qoldi';
  }

  @override
  String get guestRequests => 'Mehmon so\'rovlari';

  @override
  String get writeToReception => 'Resepshnga yozish';

  @override
  String get reservedBadge => 'Kutilmoqda';

  @override
  String get checkedInBadge => 'Mehmon ichkarida';

  @override
  String get bookingDaily => 'Kunlik';

  @override
  String get bookingHourly => 'Soatlik';

  @override
  String get noOccupiedTitle => 'Band xonalar yo\'q';

  @override
  String get noOccupiedBody => 'Hozirda mehmon joylashgan xonalar yo\'q.';

  @override
  String get upcomingEmptyTitle => 'Yaqin tozalash yo\'q';

  @override
  String get upcomingEmptyBody =>
      'Chiqish vaqti yaqinlashgan xonalar shu yerda ko\'rinadi.';

  @override
  String get upcomingHint =>
      'Mehmon chiqqach, xonani tozalash kerak bo\'ladi. Ro\'yxat chiqish vaqtiga qarab tartiblangan.';

  @override
  String get roomStatusAvailable => 'Bo\'sh';

  @override
  String get roomStatusReserved => 'Bron qilingan';

  @override
  String get roomStatusOccupied => 'Band';

  @override
  String get roomStatusCleaning => 'Tozalanmoqda';

  @override
  String get roomStatusMaintenance => 'Ta\'mirda';

  @override
  String get roomStatusInspection => 'Tekshiruvda';

  @override
  String get roomStatusOutOfService => 'Ishlamayapti';

  @override
  String get chatTitle => 'Resepshn bilan chat';

  @override
  String get chatSubtitle => 'Xabarlar barcha xodimlarga ko\'rinadi';

  @override
  String get messageHint => 'Xabar yozing...';

  @override
  String get markDone => 'Bajarildi deb belgilash';

  @override
  String doneByName(String name) {
    return 'Bajardi: $name';
  }

  @override
  String get openBadge => 'Ochiq';

  @override
  String get attachPhoto => 'Rasm yuborish';

  @override
  String get imageMessageBody => '📷 Rasm';

  @override
  String get uploadImageDenied =>
      'Rasm yuborish uchun sizga «file.upload» ruxsati berilmagan. Administratorga murojaat qiling.';

  @override
  String get noMessagesTitle => 'Xabarlar yo\'q';

  @override
  String get noMessagesBody =>
      'Resepshn va boshqa xodimlar bilan yozishmalar shu yerda ko\'rinadi.';

  @override
  String get selectRoom => 'Xonani tanlash';

  @override
  String get noRoom => 'Xonasiz';

  @override
  String get notificationsTitle => 'Bildirishnomalar';

  @override
  String get markAllRead => 'Barchasini o\'qilgan qilish';

  @override
  String get noNotifsTitle => 'Bildirishnoma yo\'q';

  @override
  String get noNotifsBody =>
      'Yangi vazifa va xabarlar haqidagi bildirishnomalar shu yerda ko\'rinadi.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get positionLabel => 'Lavozim';

  @override
  String get phoneLabel => 'Telefon';

  @override
  String get idLabel => 'Xodim ID';

  @override
  String get hotelLabel => 'Mehmonxona';

  @override
  String get scheduleLabel => 'Ish vaqti';

  @override
  String get statsTitle => 'Ish statistikasi';

  @override
  String get statToday => 'Bugun';

  @override
  String get statWeek => 'Bu hafta';

  @override
  String get statMonth => 'Bu oy';

  @override
  String get statAvg => 'O\'rtacha vaqt';

  @override
  String get statActive => 'Jarayonda';

  @override
  String get completedTasks => 'bajarilgan';

  @override
  String statMinutes(int n) {
    return '$n daqiqa';
  }

  @override
  String get settingsTitle => 'Sozlamalar';

  @override
  String get languageLabel => 'Til';

  @override
  String get themeLabel => 'Mavzu';

  @override
  String get themeLight => 'Kunduzgi';

  @override
  String get themeDark => 'Tungi';

  @override
  String get themeSystem => 'Tizim bo\'yicha';

  @override
  String get quickUnlockLabel => 'Tez kirish (Face ID / barmoq izi)';

  @override
  String get quickUnlockDesc => 'Ilovani ochishda biometrik tasdiq so\'raladi';

  @override
  String get logoutConfirmTitle => 'Hisobdan chiqasizmi?';

  @override
  String get logoutConfirmBody =>
      'Qaytadan kirish uchun login va parol kerak bo\'ladi.';

  @override
  String appVersion(String v) {
    return 'Versiya $v';
  }

  @override
  String get roleHousekeeper => 'Farrosh';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleManager => 'Menejer';

  @override
  String get roleReception => 'Qabulxona xodimi';

  @override
  String get roleMaintenance => 'Texnik xizmat';

  @override
  String get roleAccountant => 'Buxgalter';

  @override
  String get roleStaff => 'Xodim';

  @override
  String roleHomeSoonTitle(String role) {
    return '$role bo\'limi tez orada';
  }

  @override
  String get roleHomeSoonBody =>
      'Sizning lavozimingiz uchun maxsus bo\'lim ishlab chiqilmoqda. Hozircha chat, bildirishnoma va profil bo\'limlaridan foydalanishingiz mumkin.';

  @override
  String get yourTools => 'Mavjud imkoniyatlar';

  @override
  String get faceGateTitle => 'Yuzingizni biriktiring';

  @override
  String get faceGateBody =>
      'Tizimga kirish ikki bosqichli: parol va yuz. Sizda hali yuz biriktirilmagan — hisobingizni hozircha faqat parol himoya qilyapti. Davom etish uchun yuzingizni biriktiring.';

  @override
  String get faceEnrollAction => 'Yuzni biriktirish';

  @override
  String get faceEnrolledOk => 'Yuz biriktirildi ✅';

  @override
  String get faceSection => 'Yuz bilan kirish';

  @override
  String faceStatusEnrolled(int count) {
    return 'Biriktirilgan · $count ta namuna';
  }

  @override
  String get faceStatusNotEnrolled => 'Biriktirilmagan';

  @override
  String get faceAddSample => 'Yana namuna qo\'shish';

  @override
  String get faceDeleteAction => 'Yuz profillarini o\'chirish';

  @override
  String get faceDeleteTitle => 'Yuz profillarini o\'chirasizmi?';

  @override
  String get faceDeleteBody =>
      'Kirishda yuz so\'ralmaydi va tizim keyingi kirishda qaytadan biriktirishni talab qiladi.';

  @override
  String get faceDeletedOk => 'Yuz profillari o\'chirildi';

  @override
  String get faceEngineOff => 'Serverda yuz tekshiruvi hozircha yoqilmagan.';

  @override
  String get faceAutoPlace => 'Yuzingizni oval ichiga joylashtiring';

  @override
  String get faceAutoCloser => 'Yaqinroq keling';

  @override
  String get faceAutoFarther => 'Biroz uzoqlashing';

  @override
  String get faceAutoCenter => 'Yuzingizni markazga joylang';

  @override
  String get faceAutoLookStraight => 'Kameraga to\'g\'ri qarang';

  @override
  String get faceAutoHold => 'Qimirlamay turing…';

  @override
  String get tabBookings => 'Bronlar';

  @override
  String get tabReport => 'Hisobot';

  @override
  String get bookingsTitle => 'Bronlar';

  @override
  String get bookingsSubtitle => 'Kelayotgan, turgan va chiqayotganlar';

  @override
  String get bookingsSearchHint => 'Mehmon, bron raqami yoki xona...';

  @override
  String get bookingsAll => 'Hammasi';

  @override
  String get bookingArrival => 'Kelish';

  @override
  String get bookingInhouse => 'Turibdi';

  @override
  String get bookingDeparture => 'Chiqish';

  @override
  String get bookingsEmptyTitle => 'Bu kunda bron yo\'q';

  @override
  String get bookingsEmptyBody => 'Boshqa kunni tanlang yoki keyinroq qarang.';

  @override
  String get bookingsNotFoundTitle => 'Topilmadi';

  @override
  String get bookingsNotFoundBody => 'Qidiruv bo\'yicha bron topilmadi.';

  @override
  String get bookingPaid => 'To\'langan';

  @override
  String get bookingCancelled => 'Bekor qilingan';

  @override
  String bookingDebt(String amount) {
    return 'Qarz: $amount';
  }

  @override
  String get bookingPeriod => 'Muddat';

  @override
  String get bookingGuests => 'Mehmonlar';

  @override
  String get bookingPhone => 'Telefon';

  @override
  String get bookingNote => 'Izoh';

  @override
  String get bookingTotal => 'Umumiy summa';

  @override
  String get bookingPaidAmount => 'To\'langan';

  @override
  String get bookingRemaining => 'Qoldiq';

  @override
  String get bookingReadOnlyHint =>
      'Bron bu yerda faqat ko\'rinadi. Tahrirlash, to\'lov qabul qilish va chiqarish katta ekranda bajariladi.';

  @override
  String get previousDay => 'Oldingi kun';

  @override
  String get nextDay => 'Keyingi kun';

  @override
  String get copied => 'Nusxa olindi';

  @override
  String get periodToday => 'Bugun';

  @override
  String get periodYesterday => 'Kecha';

  @override
  String get periodLast7 => '7 kun';

  @override
  String get periodThisMonth => 'Shu oy';

  @override
  String get reportNet => 'Sof natija';

  @override
  String reportNetBreakdown(String income, String expense) {
    return 'Tushum $income − xarajat $expense';
  }

  @override
  String get reportCollected => 'Qabul qilingan pul';

  @override
  String reportCash(String amount) {
    return 'Naqd: $amount';
  }

  @override
  String get reportBookings => 'Bronlarim';

  @override
  String reportCancelled(int count) {
    return '$count ta bekor qilingan';
  }

  @override
  String get reportShop => 'Do\'kon savdosi';

  @override
  String reportShopCount(int count) {
    return '$count ta sotuv';
  }

  @override
  String get reportExpenses => 'Xarajatlarim';

  @override
  String reportExpenseCount(int count) {
    return '$count ta chiqim';
  }

  @override
  String get reportRefunds => 'Qaytarilgan';

  @override
  String get reportRefundsHint => 'tushumdan ayirilgan';

  @override
  String get reportShopUnpaid => 'Do\'kon qarzi';

  @override
  String get reportShopUnpaidHint => 'bronga yozilgan';

  @override
  String get reportByMethod => 'To\'lov usullari bo\'yicha';

  @override
  String get methodCash => 'Naqd pul';

  @override
  String get methodCard => 'Bank kartasi';

  @override
  String get methodOnline => 'Online to\'lov';

  @override
  String get methodBankTransfer => 'Bank o\'tkazmasi';

  @override
  String get methodOther => 'Boshqa';

  @override
  String get callWatchTitle => 'Qo\'ng\'iroq bo\'yicha mehmonni aniqlash';

  @override
  String get callWatchBody =>
      'Mehmon qo\'ng\'iroq qilganda uning ismi va xonasi kompyuter ekranida ko\'rinadi. Buning uchun qurilmadan qo\'ng\'iroq raqamini o\'qishga ruxsat kerak.';

  @override
  String get callWatchEnable => 'Yoqish';

  @override
  String get callWatchEnabled =>
      'Yoqildi — endi qo\'ng\'iroqlar kompyuterda ko\'rinadi';

  @override
  String callMatched(String name) {
    return '$name qo\'ng\'iroq qilmoqda';
  }

  @override
  String get dismiss => 'Yopish';

  @override
  String get tabHome => 'Asosiy';

  @override
  String get tabTeam => 'Jamoa';

  @override
  String get broadcastAction => 'E\'lon';

  @override
  String get pulseTitle => 'Mehmonxona pulsi';

  @override
  String get pulseLive => 'Jonli';

  @override
  String pulseUpdatedAt(String time) {
    return 'Yangilandi $time';
  }

  @override
  String pulsePartialWarning(int count) {
    return '$count bo\'lak yuklanmadi — pastga tortib yangilang';
  }

  @override
  String get occupancyTitle => 'Bandlik';

  @override
  String roomsOf(int busy, int total) {
    return '$busy / $total xona band';
  }

  @override
  String get heroArrivals => 'Keladi';

  @override
  String get heroDepartures => 'Chiqadi';

  @override
  String get heroInHouse => 'Turibdi';

  @override
  String heroOverdue(int count) {
    return '$count xona chiqish vaqtidan o\'tgan';
  }

  @override
  String get todayBookingsTitle => 'Bugungi bronlar';

  @override
  String get financeTitle => 'Moliya';

  @override
  String get financeIncome => 'Tushum';

  @override
  String get financeExpenses => 'Xarajat';

  @override
  String get financeNet => 'Sof natija';

  @override
  String get financeDebt => 'Qarzdorlik';

  @override
  String financePayments(int count) {
    return '$count to\'lov';
  }

  @override
  String get financeLast7 => 'Oxirgi 7 kun tushumi';

  @override
  String get currencySuffix => 'so\'m';

  @override
  String get moneyThousand => 'ming';

  @override
  String get moneyMillion => 'mln';

  @override
  String get hkTitle => 'Xo\'jalik ishlari';

  @override
  String get taskOpen => 'Kutmoqda';

  @override
  String get taskInProgress => 'Jarayonda';

  @override
  String get taskCompleted => 'Bajarildi';

  @override
  String get taskCancelled => 'Bekor qilingan';

  @override
  String get hkDoneToday => 'Bugun bajarildi';

  @override
  String hkCleaningRooms(int count) {
    return '$count xona tozalanmoqda';
  }

  @override
  String get attentionTitle => 'Diqqat talab qiladi';

  @override
  String get attentionNone =>
      'Hammasi joyida — e\'tibor talab qiladigan holat yo\'q';

  @override
  String attentionComplaints(int count) {
    return '$count yangi shikoyat';
  }

  @override
  String attentionFeedbackOpen(int count) {
    return '$count ochiq murojaat';
  }

  @override
  String attentionDebtors(int count, String amount) {
    return '$count qarzdor bron · $amount';
  }

  @override
  String attentionProblems(int count) {
    return '$count xodim muammosi ochiq';
  }

  @override
  String attentionHandover(int count) {
    return '$count smena topshirishni kutmoqda';
  }

  @override
  String attentionOpenTasks(int count) {
    return '$count vazifa biriktirilmagan';
  }

  @override
  String teamOnDuty(int onDuty, int total) {
    return '$onDuty / $total xodim ish vaqtida';
  }

  @override
  String shiftsOpen(int count) {
    return '$count ochiq smena';
  }

  @override
  String get roomMapTitle => 'Xonalar xaritasi';

  @override
  String get roomStateAvailable => 'Bo\'sh';

  @override
  String get roomStateOccupied => 'Band';

  @override
  String get roomStateReserved => 'Bron';

  @override
  String get roomStateCleaning => 'Tozalanmoqda';

  @override
  String get roomStateMaintenance => 'Ta\'mirda';

  @override
  String get roomStateInspection => 'Tekshiruvda';

  @override
  String get roomStateOutOfService => 'Xizmatdan tashqari';

  @override
  String get roomStateUnknown => 'Noma\'lum';

  @override
  String floorLabel(int number) {
    return '$number-qavat';
  }

  @override
  String get floorOther => 'Boshqa xonalar';

  @override
  String get roomsEmptyTitle => 'Xonalar topilmadi';

  @override
  String get roomsEmptyBody => 'Bu holatda xona yo\'q';

  @override
  String roomSinceLabel(String duration) {
    return '$duration dan beri';
  }

  @override
  String roomCapacity(int count) {
    return '$count kishilik';
  }

  @override
  String get roomPrice => 'Narx';

  @override
  String get roomGuestTitle => 'Mehmon';

  @override
  String get roomNoStay => 'Faol bron yo\'q';

  @override
  String roomCompanions(String names) {
    return 'Hamrohlar: $names';
  }

  @override
  String get roomChangeStatus => 'Holatni o\'zgartirish';

  @override
  String get roomCreateTask => 'Vazifa yaratish';

  @override
  String get roomStatusChanged => 'Xona holati yangilandi';

  @override
  String get roomStatusBusyHint =>
      'Band yoki bron qilingan xona holati bron orqali o\'zgaradi — kirish yoki chiqish rasmiylashtiring';

  @override
  String get notesLabel => 'Izoh';

  @override
  String get hourShort => 's';

  @override
  String get minuteShort => 'd';

  @override
  String taskCreateTitle(String room) {
    return 'Yangi vazifa · $room';
  }

  @override
  String get taskTypeLabel => 'Vazifa turi';

  @override
  String get taskTypeCleaning => 'Tozalash';

  @override
  String get taskTypeDeepCleaning => 'Chuqur tozalash';

  @override
  String get taskTypeMaintenance => 'Ta\'mir';

  @override
  String get taskTypeInspection => 'Tekshiruv';

  @override
  String get taskTypeTurnDown => 'Kechki tayyorlash';

  @override
  String get priorityLabel => 'Muhimlik';

  @override
  String get priorityLow => 'Past';

  @override
  String get priorityMedium => 'O\'rta';

  @override
  String get priorityHigh => 'Yuqori';

  @override
  String get priorityUrgent => 'Shoshilinch';

  @override
  String get assigneeLabel => 'Mas\'ul';

  @override
  String get assigneeNone => 'Avtomatik (navbat bo\'yicha)';

  @override
  String get taskCreated => 'Vazifa yaratildi';

  @override
  String get create => 'Yaratish';

  @override
  String get segmentStaff => 'Xodimlar';

  @override
  String get segmentShifts => 'Smenalar';

  @override
  String get segmentTasks => 'Vazifalar';

  @override
  String get segmentProblems => 'Muammolar';

  @override
  String get staffSearchHint => 'Ism, login yoki telefon';

  @override
  String get staffOnDutyBadge => 'Ish vaqtida';

  @override
  String get staffOffDuty => 'Ish vaqtidan tashqari';

  @override
  String get staffOnline => 'Hozir ilovada';

  @override
  String get staffStatusInactive => 'Nofaol';

  @override
  String get staffStatusTerminated => 'Ishdan bo\'shagan';

  @override
  String get staffLastLoginLabel => 'Oxirgi kirish';

  @override
  String get staffNeverLoggedIn => 'Hali kirmagan';

  @override
  String get staffEmptyTitle => 'Xodimlar topilmadi';

  @override
  String get staffEmptyBody => 'Qidiruvga mos xodim yo\'q';

  @override
  String get shiftsNotCashTitle => 'Kassa rejimi o\'chirilgan';

  @override
  String get shiftsNotCashBody =>
      'Smenalar sozlamada «kassa» rejimi yoqilganda yuritiladi';

  @override
  String get shiftsOpenTitle => 'Ochiq smenalar';

  @override
  String get shiftsClosedTitle => 'Yopilgan smenalar';

  @override
  String get shiftsEmpty => 'Smenalar hali yo\'q';

  @override
  String get shiftActive => 'Faol';

  @override
  String get shiftPendingHandover => 'Topshirishni kutmoqda';

  @override
  String get shiftForceClosed => 'Majburiy yopilgan';

  @override
  String shiftStarted(String time) {
    return 'Boshlandi $time';
  }

  @override
  String get shiftDurationLabel => 'Davomiyligi';

  @override
  String get shiftOpeningCash => 'Boshlang\'ich kassa';

  @override
  String get shiftCounted => 'Sanalgan';

  @override
  String get shiftDiff => 'Farq';

  @override
  String get shiftForceClose => 'Majburiy yopish';

  @override
  String shiftForceCloseBody(String name) {
    return '$name smenasi yopiladi. Sanalgan summa kiritilmasa kutilgan summa bo\'yicha yopiladi.';
  }

  @override
  String get shiftCountedCashLabel => 'Sanalgan naqd (ixtiyoriy)';

  @override
  String get shiftHandOver => 'Kassa keyingi xodimga topshirilsin';

  @override
  String get shiftHandOverHint =>
      'O\'chirilsa pulni admin oladi va smena butunlay yopiladi';

  @override
  String get shiftForceClosedDone => 'Smena yopildi';

  @override
  String get tasksEmptyTitle => 'Vazifalar yo\'q';

  @override
  String get tasksEmptyBody =>
      'Xonalar xaritasidan vazifa yaratishingiz mumkin';

  @override
  String get taskAssign => 'Biriktirish';

  @override
  String get taskReassign => 'Qayta biriktirish';

  @override
  String get taskUnassigned => 'Biriktirilmagan';

  @override
  String get taskAssigned => 'Vazifa biriktirildi';

  @override
  String get taskComplete => 'Yakunlash';

  @override
  String get taskCancelAction => 'Vazifani bekor qilish';

  @override
  String get taskCompleteConfirm =>
      'Vazifa yakunlangan deb belgilansinmi? Tozalash bo\'lsa xona bo\'sh holatga o\'tadi.';

  @override
  String get taskCancelConfirm => 'Vazifa bekor qilinsinmi?';

  @override
  String taskWaiting(String duration) {
    return '$duration kutmoqda';
  }

  @override
  String taskWorking(String duration) {
    return '$duration ishlanmoqda';
  }

  @override
  String taskChecklist(int done, int total) {
    return '$done/$total band';
  }

  @override
  String get taskChecklistLabel => 'Ish bandlari';

  @override
  String get taskAutoCompleted => 'Avtomatik yakunlangan';

  @override
  String get taskCreatedAt => 'Yaratilgan';

  @override
  String get taskStartedAt => 'Boshlangan';

  @override
  String get assignSheetTitle => 'Kimga biriktiriladi?';

  @override
  String get problemsEmptyTitle => 'Muammolar yo\'q';

  @override
  String get problemsEmptyBody =>
      'Xodimlar xabar qilgan muammolar shu yerda ko\'rinadi';

  @override
  String get problemOpen => 'Ochiq';

  @override
  String get problemResolved => 'Hal qilindi';

  @override
  String get problemTake => 'Ishga olish';

  @override
  String get problemResolve => 'Hal qilindi deb belgilash';

  @override
  String problemReportedBy(String name) {
    return '$name xabar qildi';
  }

  @override
  String get problemResolvedTitle => 'Hal qilinganlar';

  @override
  String get feedbackTitle => 'Murojaatlar';

  @override
  String get feedbackRequest => 'Talab';

  @override
  String get feedbackSuggestion => 'Taklif';

  @override
  String get feedbackComplaint => 'Shikoyat';

  @override
  String get feedbackNew => 'Yangi';

  @override
  String get feedbackInProgress => 'Jarayonda';

  @override
  String get feedbackResolved => 'Hal qilindi';

  @override
  String get feedbackRejected => 'Rad etildi';

  @override
  String get feedbackFilterOpen => 'Ochiq';

  @override
  String get feedbackFilterComplaints => 'Shikoyatlar';

  @override
  String get feedbackFilterResolved => 'Yopilgan';

  @override
  String get feedbackEmptyTitle => 'Murojaatlar yo\'q';

  @override
  String get feedbackEmptyBody =>
      'Mehmon murojaatlari qabulxona tomonidan kiritiladi';

  @override
  String get feedbackResolveAction => 'Hal qilish';

  @override
  String get feedbackRejectAction => 'Rad etish';

  @override
  String get feedbackReopen => 'Qayta ochish';

  @override
  String get feedbackResolutionLabel => 'Qaror / javob';

  @override
  String get feedbackResolutionRequired => 'Yopishda javob matni shart';

  @override
  String feedbackRoom(String number) {
    return 'Xona $number';
  }

  @override
  String feedbackAssigned(String name) {
    return 'Mas\'ul: $name';
  }

  @override
  String get feedbackStatusUpdated => 'Murojaat holati yangilandi';

  @override
  String get broadcastTitle => 'Barcha xodimlarga e\'lon';

  @override
  String get broadcastBody =>
      'Xabar mehmonxonaning barcha faol xodimlariga push bo\'lib boradi';

  @override
  String get broadcastTitleHint => 'Sarlavha';

  @override
  String get broadcastMessageHint => 'Matn (ixtiyoriy)';

  @override
  String broadcastSent(int count) {
    return 'E\'lon $count qurilmaga yuborildi';
  }

  @override
  String roomStayNights(int done, int total) {
    return '$done / $total kecha';
  }

  @override
  String get roomActionsTitle => 'Amallar';

  @override
  String get broadcastPreview => 'Xodim telefonida shunday ko\'rinadi';

  @override
  String get broadcastNow => 'hozir';

  @override
  String broadcastRecipients(int count) {
    return '$count faol xodimga yuboriladi';
  }

  @override
  String get broadcastQuick => 'Tez matnlar';

  @override
  String get broadcastQuick1 => 'Yig\'ilish 10 daqiqadan so\'ng';

  @override
  String get broadcastQuick2 => 'Smenani topshirishni unutmang';

  @override
  String get broadcastQuick3 => 'Tozalikka alohida e\'tibor bering';

  @override
  String get broadcastTitlePlaceholder => 'E\'lon sarlavhasi';

  @override
  String get broadcastBodyPlaceholder => 'E\'lon matni shu yerda ko\'rinadi';

  @override
  String get teamOnDutyNow => 'Hozir ish vaqtida';

  @override
  String get teamNobodyOnDuty => 'Hozir ish vaqtida hech kim yo\'q';

  @override
  String staffActiveTasks(int count) {
    return '$count faol vazifa';
  }

  @override
  String get staffNoTasks => 'Faol vazifa yo\'q';

  @override
  String get taskStepAssigned => 'Biriktirilgan';

  @override
  String get taskTimelineTitle => 'Jarayon';

  @override
  String get taskNotStarted => 'Hali boshlanmagan';

  @override
  String get shiftSummaryTitle => 'Smena';

  @override
  String get assigneeAuto => 'Avto';

  @override
  String get roomsFreeNow => 'Hozir bo\'sh';

  @override
  String get stayCheckIn => 'Kelish';

  @override
  String get stayCheckOut => 'Ketish';

  @override
  String get roleConfigurator => 'Sozlovchi';

  @override
  String get configuratorTitle => 'Sozlovchi hisobi';

  @override
  String get configuratorBody =>
      'Mehmonxonalarni sozlash veb-ilovada bajariladi. Kompyuterda GoHotel\'ga shu login bilan kiring, mehmonxona va filialni tanlang — keyin uning barcha bo\'limlari va sozlamalari sizga ochiladi.';

  @override
  String get configuratorHint => 'Mobil ilova mehmonxona xodimlari uchun.';

  @override
  String get financeDetails => 'Batafsil';

  @override
  String get periodCustom => 'Tanlash';

  @override
  String get financePickRange => 'Davrni tanlang';

  @override
  String get financeRevenue => 'Jami tushum';

  @override
  String financeRevenueParts(String bookings, String shop) {
    return 'Bronlar: $bookings · Do\'kon: $shop';
  }

  @override
  String financeAvgPayment(String amount) {
    return 'o\'rtacha to\'lov $amount';
  }

  @override
  String get financeVsPrevious => 'oldingi davrga nisbatan';

  @override
  String get financeNoPrevious => 'oldingi davrda tushum bo\'lmagan';

  @override
  String get financeInvoices => 'Hisob-fakturalar';

  @override
  String financeInvoicesValue(int count, String amount) {
    return '$count ta · $amount';
  }

  @override
  String get financeDiscounts => 'Chegirmalar';

  @override
  String get cashNowTitle => 'Kassada hozir';

  @override
  String get cashNowHint =>
      'Ochiq smenalarda kassada bo\'lishi kerak bo\'lgan naqd pul';

  @override
  String cashDrawersCount(int active, int pending) {
    return 'Ochiq: $active · topshirilmoqda: $pending';
  }

  @override
  String get cashNoOpen => 'Hozir ochiq kassa yo\'q';

  @override
  String get cashSimpleMode =>
      'Kassa smenalari yuritilmaydi — naqd pul harakati davr bo\'yicha quyida';

  @override
  String cashBreakdown(
    String opening,
    String payments,
    String shop,
    String expenses,
  ) {
    return 'Boshlang\'ich $opening + to\'lovlar $payments + do\'kon $shop − xarajat $expenses';
  }

  @override
  String cashCounted(String amount) {
    return 'Sanab topshirildi: $amount';
  }

  @override
  String get cashFlowTitle => 'Naqd pul harakati';

  @override
  String get cashIn => 'Kirim';

  @override
  String get cashOut => 'Chiqim';

  @override
  String get cashBalance => 'Qoldiq';

  @override
  String get chartDaily => 'Kunlik tushum va xarajat';

  @override
  String get chartWeekly => 'Haftalik tushum va xarajat';

  @override
  String chartBest(String day, String amount) {
    return 'Eng yaxshi: $day — $amount';
  }

  @override
  String chartAverage(String amount) {
    return 'Kuniga o\'rtacha $amount';
  }

  @override
  String get expenseCategoriesTitle => 'Xarajatlar toifalari';

  @override
  String get expensesNone => 'Bu davrda xarajat yo\'q';

  @override
  String get debtorsTitle => 'Qarzdorlar';

  @override
  String debtorsSummary(int count, String amount) {
    return '$count ta bron · jami $amount';
  }

  @override
  String get debtorsNone => 'Qarzdor yo\'q';

  @override
  String debtorsMore(int count) {
    return 'Yana $count ta';
  }

  @override
  String debtorRoom(String room) {
    return '$room-xona';
  }

  @override
  String debtorCheckOut(String date) {
    return 'chiqish $date';
  }

  @override
  String get shiftsCashTitle => 'Smenalar kassasi';

  @override
  String shiftsClosedCount(int count) {
    return 'Yopilgan smenalar: $count';
  }

  @override
  String get shiftsShortage => 'Kamomad';

  @override
  String get shiftsSurplus => 'Ortiqcha';

  @override
  String get shiftsNoneClosed => 'Bu davrda smena yopilmagan';

  @override
  String get financeGuestUnknown => 'Mehmon';
}
