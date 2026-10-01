# GoHotel Staff — mehmonxona xodimlari mobil ilovasi

GoHotel tizimining mobil ilovasi. **Farrosh**, **Qabulxona** va
**Boshqaruv (admin / menejer)** modullari to'liq ishlab chiqilgan; texnik
xizmat uchun alohida papka tayyorlab qo'yilgan — ilova xodimning rolini o'zi
aniqlab, mos bo'limni ochadi.

Backend: `GoHotelBackend` (FastAPI) · Web frontend: `GoHotelFrontend` (React).
Ilova ikonkasi va brend ranglari frontend bilan bir xil (`#2563EB`, oq
mehmonxona binosi).

## Imkoniyatlar (Farrosh)

| Bo'lim | Tavsif |
|---|---|
| **Kirish** | Login + parol → (yuz biriktirilgan bo'lsa) yuz tasdig'i (`/auth/face/verify-login`); kamerasiz zaxira yo'l; qurilma tasdig'i (`X-Device-Id`, PENDING/BLOCKED holatlari); biometrik "Tez kirish" (Face Unlock / barmoq izi) |
| **Vazifalar** | Tozalash ro'yxati (`GET /tasks`), filtrlash, boshlash, checklist, progress, yakunlash (xona avtomatik AVAILABLE bo'ladi), foto hisobot, muammo xabari |
| **Xonalar** | Band xonalar va chiqish vaqtlari (`/housekeeping/occupied-rooms`), "Yaqin tozalash" tartibi, kechikkanlar belgisi, xona bo'yicha resepshnga xabar |
| **Chat** | Xodimlar taxtasi (`/messages`): yuborish, "Bajarildi", rasm biriktirish (`/files/upload`), 10 soniyalik jonli yangilanish |
| **Bildirishnomalar** | Ro'yxat, o'qilgan belgilash, o'qilmaganlar sanog'i |
| **Profil** | Ism, lavozim (rolga qarab), telefon, ID, mehmonxona, ish vaqti, surat, ish statistikasi (bugun/hafta/oy, o'rtacha vaqt) |
| **Sozlamalar** | 3 til (o'zbek — asosiy, rus, ingliz), kun/tun/tizim mavzusi, biometrika |

## Imkoniyatlar (Boshqaruv — admin va menejer)

Bitta qobiq (`features/management`), farq ruxsatlarda (`ManagementAccess`):
admin hammasini ko'radi, menejer — o'z ruxsat kodlariga qarab (tugma
ko'rinmasa server ham rad etadi). Ma'lumot har daqiqada jim yangilanadi,
ilova fonga o'tganda polling to'xtaydi.

| Bo'lim | Tavsif |
|---|---|
| **Asosiy (puls)** | Bandlik halqasi (`GET /rooms/`), bugungi kelish/chiqish/turibdi (`/reception/bookings`), moliya kartasi — tushum, xarajat, sof natija, qarzdorlik, to'lov usullari, 7 kunlik chiziq (`/finance/summary`, davr: bugun / 7 kun / oy), xo'jalik progressi (`/housekeeping/tasks`), "Diqqat talab qiladi" ro'yxati (yangi shikoyatlar, chiqish vaqti o'tgan xonalar, biriktirilmagan vazifalar, xodim muammolari, topshirilmagan smenalar, qarzdorlar), jamoa kartasi. Har bo'lak mustaqil yuklanadi — biri yiqilsa qolganlari turadi |
| **Xonalar xaritasi** | Umumiy karta (hozir bo'sh xonalar, bandlik, taqsimot chizig'i), tepada qoladigan holat filtri, qavatlar bo'yicha kataklar — bo'sh xona oq, qolganlari holat rangida (`/rooms/`, `/floors/`); katak → tafsilot (qanchadan beri, mehmon va hamrohlar `/rooms/{id}/reservations`, qarz), holatni qo'lda o'zgartirish (`PATCH /rooms/{id}/status`, `room.update`; band/bron holatlari bron orqali), vazifa yaratish (`POST /housekeeping/tasks`, tur/muhimlik/mas'ul) |
| **Jamoa** | *Xodimlar* — ro'yxat, qidiruv, ish vaqtida/ilovada belgilari, faol vazifalari (`/employees/`); *Smenalar* — kassa rejimida ochiq smenalar jonli davomiylik bilan, majburiy yopish (`POST /shifts/force-close`, `shift.force_close`), yopilganlar farqi bilan (`/shifts/history`); *Vazifalar* — kutmoqda/jarayonda/bajarildi, biriktirish (`housekeeping.task.assign`), yakunlash/bekor qilish (`housekeeping.task.update`); *Muammolar* — xodimlar xabar qilgan muammolar, ishga olish / hal qilish (`PATCH /problems/{id}/status`) |
| **Murojaatlar** | Talab / taklif / shikoyat (`/feedback/`), filtr, holatni o'zgartirish (ishga olish, hal qilish, rad etish, qayta ochish) — yopishda javob matni shart |
| **E'lon** | Pastki paneldagi markaziy tugma (faqat admin): barcha xodimlarga push (`POST /notifications/broadcast`) |
| **Profil** | Appbar'dagi avatar orqali — profil sahifasi boshqa rollar bilan bir xil |

Vizual til: iOS 26 shisha panellar saqlangan; puls ekranida kod bilan
chizilgan bandlik halqasi va tushum chizig'i (`CustomPainter`), raqamlar
"sanab chiqiladi", kartalar birin-ketin paydo bo'ladi (`StaggerIn`),
ko'rinmas tabda animatsiya uxlaydi (`TickerIndexedStack`). Gradient
ishlatilmaydi — faqat tekis ranglar. Xonalar xaritasi va qavatlarda
holat taqsimoti chizig'i (`DistributionBar`), Jamoa sahifasida sonli
tanlagich (`StatTabs`), xodimlarda 24 soatlik ish chizig'i (`DayTimeline`).

Dizaynni qurilmasiz ko'rish: `test/management_pages_test.dart` sahifa va
oynalarni 360×740 ekranda uch tilda tekshiradi; skrinshot kerak bo'lsa
`GOHOTEL_SHOTS=<papka> flutter test --update-goldens test/management_pages_test.dart`.

## Arxitektura

Clean architecture, feature-first. Har bir modul ichida `data / domain /
presentation` qatlamlari; holat boshqaruvi — `flutter_bloc` (Cubit), DI —
`get_it`.

```
lib/
├── main.dart
├── app/                        # ilova qobig'i
│   ├── app.dart                #   MaterialApp + AuthGate
│   ├── di.dart                 #   get_it bog'lamalari
│   ├── roles/role_registry.dart#   rol → bosh sahifa (dinamik)
│   ├── settings/               #   til + mavzu (SettingsCubit)
│   └── theme/                  #   ranglar, mavzular (AppColors extension)
├── core/                       # rolga bog'lanmagan umumiy kod
│   ├── config/api_config.dart  #   backend manzili (--dart-define bilan almashadi)
│   ├── network/                #   Dio klient (auth header, X-Device-Id, avtorefresh)
│   ├── storage/                #   TokenStore (secure), AppPrefs
│   ├── services/               #   BiometricService
│   ├── extensions/             #   context.l10n, context.colors, sana formatlari
│   └── widgets/                #   AppCard, StatusChip, EmptyState, RoleScaffold...
├── features/
│   ├── auth/                   # kirish (barcha rollar uchun umumiy)
│   ├── chat/                   # xodimlar chati (umumiy)
│   ├── notifications/          # bildirishnomalar (umumiy)
│   ├── profile/                # profil + statistika (umumiy)
│   ├── housekeeper/            # FARROSH MODULI (to'liq)
│   │   ├── home/               #   4 tabli shell
│   │   ├── tasks/              #   vazifalar (data/domain/presentation)
│   │   └── rooms/              #   band xonalar
│   ├── reception/              # QABULXONA MODULI (bronlar, hisobot, skaner)
│   ├── management/             # BOSHQARUV MODULI (admin + menejer)
│   │   ├── home/               #   ManagementShell — 4 tab + e'lon
│   │   ├── data/               #   ManagementRepository (veb-API'lar)
│   │   ├── domain/             #   RoomTile, HotelPulse, FinanceSummary, ShiftSession...
│   │   └── presentation/       #   cubit (puls, xarita, jamoa, murojaat), pages, widgets
│   ├── admin/                  # → ManagementShell (to'liq ruxsat)
│   ├── manager/                # → ManagementShell (ruxsat kodlariga qarab)
│   ├── maintenance/            # rol skeleti — kelgusi modul joyi
│   └── staff/                  # rol aniqlanmaganlar uchun zaxira
└── l10n/
    ├── arb/                    # app_uz.arb (asosiy), app_ru.arb, app_en.arb
    └── gen/                    # flutter gen-l10n natijasi (S klassi)
```

### Rollar qanday aniqlanadi

Backend'da xodim turi `SUPER_ADMIN / ADMIN / EMPLOYEE`, aniq rol esa ruxsat
kodlaridan kelib chiqadi (web'dagi shablonlar bilan bir xil mantiq):

1. `ADMIN`/`SUPER_ADMIN` → **admin**
2. `shift.*` yoki `employee.create` → **menejer**
3. `reservation.create` → **resepshn**
4. `housekeeping.task.create` (assign'siz) → **texnik xizmat**
5. `housekeeping.*` yoki `room.status.update` → **farrosh**
6. hech biri → **umumiy xodim** (chat + profil baribir ishlaydi)

Yangi rol qo'shish: `features/<rol>/` papkasida sahifa yozing va
`app/roles/role_registry.dart` dagi ro'yxatga `RoleModule` qo'shing — bo'ldi.
Tartib muhim: kengroq huquqli rollar yuqorida turadi.

## Ishga tushirish

```bash
flutter pub get
flutter gen-l10n          # (build paytida o'zi ham chaqiriladi)
flutter run
```

Backend manzilini almashtirish:

```bash
flutter run --dart-define=API_BASE_URL=https://sizning-server.uz/api/v1
```

Testlar: `flutter test` · Ikonka qayta generatsiyasi: `dart run flutter_launcher_icons`

## Muhim texnik detallari

- **Qurilma tasdig'i.** Har so'rovda `X-Device-Id` yuboriladi (birinchi
  ochilishda yaratiladi va saqlanadi). Yangi qurilmadan kirishda backend
  `DEVICE_PENDING` qaytaradi — ilova administrator tasdig'ini kutish ekranini
  ko'rsatadi. ADMIN'lar tekshiruvdan ozod.
- **Ikki bosqichli kirish.** Parol to'g'ri bo'lsa-yu xodimga yuz biriktirilgan
  bo'lsa, server token o'rniga `face_token` beradi — ilova yuz suratini
  `/auth/face/verify-login` ga yuboradi. Kamera yo'q qurilmada
  `/auth/login/no-camera` (sabab sessiyaga yoziladi).
- **Token yangilash.** 401 da (auth yo'llaridan tashqari) refresh bir marta
  uriniladi, parallel so'rovlar bitta refresh'ni kutadi; o'tmasa — login sahifa.
- **Chatdagi rasmlar.** `POST /files/upload` (`entity_type=staff_message`)
  `file.upload` ruxsatini talab qiladi — ruxsat bo'lmasa ilova buni tushunarli
  xabar bilan aytadi (matn baribir ketadi). Rasmlar backend orqali
  (`/files/{id}/download`) avtorizatsiya bilan ko'rsatiladi.
- **Statistika.** `GET /housekeeping/tasks?assigned_to=<men>` dan hisoblanadi:
  bugun/hafta/oy bajarilganlar va o'rtacha vaqt (`started_at→completed_at`).

## Push (FCM) ni yoqish — keyingi qadam

Plumbing tayyor: login `fcm_token` qabul qiladi,
`AuthRepository.registerFcmToken()` esa `/notifications/register-device` ga
yuboradi. Yoqish uchun:

1. Firebase loyihasiga Android ilovani qo'shib `google-services.json` ni
   `android/app/` ga joylang (iOS: `GoogleService-Info.plist`).
2. `firebase_core` + `firebase_messaging` paketlarini qo'shing.
3. Token olingach `registerFcmToken()` ni chaqiring (login'dan keyin va
   `onTokenRefresh` da).

Server tomoni allaqachon tayyor (`/notifications/push-health` bilan tekshirsa
bo'ladi). Hozircha bildirishnomalar ilova ochiq payt polling orqali keladi.
