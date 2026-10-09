// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class SRu extends S {
  SRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'GoHotel Staff';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get retry => 'Повторить';

  @override
  String get close => 'Закрыть';

  @override
  String get refresh => 'Обновить';

  @override
  String get send => 'Отправить';

  @override
  String get all => 'Все';

  @override
  String get today => 'Сегодня';

  @override
  String get done => 'Выполнено';

  @override
  String get back => 'Назад';

  @override
  String get logout => 'Выйти';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get comingSoon => 'Скоро';

  @override
  String get error => 'Ошибка';

  @override
  String get optional => 'необязательно';

  @override
  String get enable => 'Включить';

  @override
  String get notNow => 'Не сейчас';

  @override
  String get networkError =>
      'Нет соединения с интернетом. Проверьте подключение и попробуйте снова.';

  @override
  String get serverError => 'Ошибка на сервере. Попробуйте немного позже.';

  @override
  String get sessionExpired => 'Сессия истекла. Войдите заново.';

  @override
  String get permissionDenied => 'У вас нет прав для этого действия.';

  @override
  String get welcomeTitle => 'Добро пожаловать';

  @override
  String get welcomeSubtitle => 'Войдите в свой аккаунт, чтобы продолжить';

  @override
  String get username => 'Логин';

  @override
  String get password => 'Пароль';

  @override
  String get signIn => 'Войти';

  @override
  String get fieldRequired => 'Это поле обязательно';

  @override
  String get wrongCredentials => 'Неверный логин или пароль';

  @override
  String get faceStepTitle => 'Подтверждение лица';

  @override
  String get faceStepBody =>
      'Для безопасности подтвердите своё лицо. Смотрите прямо в камеру и сделайте снимок в хорошо освещённом месте.';

  @override
  String get faceOpenCamera => 'Открыть камеру';

  @override
  String get faceRetry => 'Переснять';

  @override
  String get faceNoCameraBtn => 'Войти без камеры';

  @override
  String get faceNoCameraReason => 'Камера на устройстве не работает';

  @override
  String get faceCameraRequiredHint =>
      'Этот аккаунт защищён лицом — его откроет только привязанное лицо.';

  @override
  String get faceNotRecognized => 'Лицо не совпало. Попробуйте ещё раз.';

  @override
  String get faceNotDetected =>
      'Лицо не обнаружено — посмотрите прямо в камеру и повторите.';

  @override
  String get devicePendingTitle => 'Устройство ждёт одобрения';

  @override
  String get devicePendingBody =>
      'С этого устройства входят впервые. Попробуйте снова после того, как администратор одобрит устройство.';

  @override
  String get deviceBlockedTitle => 'Устройство заблокировано';

  @override
  String get deviceBlockedBody =>
      'Вход с этого устройства запрещён. Обратитесь к администратору.';

  @override
  String get scanTitle => 'Сканировать документ';

  @override
  String get scanPickType => 'Тип документа';

  @override
  String get scanPickTypeBody => 'Какой документ сканируем?';

  @override
  String get scanIdCard => 'ID-карта';

  @override
  String get scanIdCardBody =>
      'Достаточно лицевой стороны — при желании добавьте обратную';

  @override
  String get scanPassport => 'Паспорт';

  @override
  String get scanPassportBody => 'Страница с данными';

  @override
  String get scanStepFront => 'Лицевая сторона';

  @override
  String get scanStepBack => 'Обратная сторона';

  @override
  String get scanSendOneSide => 'Достаточно лицевой стороны — отправить';

  @override
  String get scanStepPassport => 'Страница с данными';

  @override
  String get scanGuide => 'Поместите документ в рамку и держите ровно';

  @override
  String get scanReading => 'Документ распознаётся...';

  @override
  String get scanCameraFailed => 'Не удалось открыть камеру';

  @override
  String get scanFailedTitle => 'Документ не распознан';

  @override
  String get scanMatchedTitle => 'Гость найден';

  @override
  String get scanNewGuestTitle => 'Новый гость';

  @override
  String get scanSentBody =>
      'На стойке регистрации открылось окно новой брони.';

  @override
  String get scanAgain => 'Сканировать снова';

  @override
  String get serviceStoppedTitle => 'Сервис остановлен';

  @override
  String get serviceStoppedBody =>
      'Система для вашего отеля временно отключена. Это не сбой приложения — все данные сохранены.';

  @override
  String get serviceStoppedHint =>
      'Обратитесь к системному администратору, чтобы восстановить сервис. После восстановления кнопка «Проверить снова» продолжит работу.';

  @override
  String get serviceStoppedRetry => 'Проверить снова';

  @override
  String get outsideHoursTitle => 'Сейчас не ваше рабочее время';

  @override
  String get outsideHoursBody =>
      'В отеле ограничена работа вне рабочего времени. Когда начнётся ваше рабочее время, приложение само продолжит работу.';

  @override
  String get outsideHoursScheduleLabel => 'Ваше рабочее время';

  @override
  String get outsideHoursHint =>
      'Приложение проверяет это каждую минуту. Если нужно работать в нерабочее время, обратитесь к администратору.';

  @override
  String get outsideHoursRetry => 'Проверить снова';

  @override
  String get outsideHoursStill => 'Ваше рабочее время ещё не началось';

  @override
  String get outsideHoursError =>
      'Сейчас не ваше рабочее время. Продолжить можно, когда оно начнётся.';

  @override
  String get biometricEnableTitle => 'Быстрый вход';

  @override
  String get biometricEnableBody =>
      'Включить быстрый вход в приложение по отпечатку пальца или лицу?';

  @override
  String get biometricReason => 'Подтвердите личность для входа в приложение';

  @override
  String get unlock => 'Разблокировать';

  @override
  String get unlockTitle => 'Приложение заблокировано';

  @override
  String get unlockBody => 'Подтвердите личность, чтобы продолжить';

  @override
  String get loginAsOther => 'Войти под другим аккаунтом';

  @override
  String get tabTasks => 'Задачи';

  @override
  String get tabRooms => 'Комнаты';

  @override
  String get tabChat => 'Чат';

  @override
  String get tabProfile => 'Профиль';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String get tasksTitle => 'Задачи по уборке';

  @override
  String get filterAll => 'Все';

  @override
  String get filterNew => 'Новые';

  @override
  String get filterInProgress => 'В работе';

  @override
  String get filterDone => 'Готово';

  @override
  String roomTitle(String n) {
    return 'Комната $n';
  }

  @override
  String get urgentBadge => 'Срочно';

  @override
  String deadlineAt(String time) {
    return 'Срок: $time';
  }

  @override
  String get guestLabel => 'Гость';

  @override
  String get statusNew => 'Новая';

  @override
  String get statusInProgress => 'В работе';

  @override
  String get statusDone => 'Готово';

  @override
  String get startCleaning => 'Начать уборку';

  @override
  String get finishCleaning => 'Завершить уборку';

  @override
  String get confirmFinishTitle => 'Уборка завершена?';

  @override
  String get confirmFinishBody =>
      'Задача будет отмечена выполненной, а комната перейдёт в статус «Свободна».';

  @override
  String get cleaningDone => 'Отлично! Комната убрана ✅';

  @override
  String get checklistTitle => 'Список работ';

  @override
  String checklistRemaining(int count) {
    return 'Не отмечено работ: $count';
  }

  @override
  String confirmFinishBodyRemaining(int count) {
    return 'Не отмечено работ: $count. Всё равно завершить? Задача будет отмечена выполненной, а комната перейдёт в статус «Свободна».';
  }

  @override
  String get checklistAllDone => 'Все работы отмечены';

  @override
  String get progressLabel => 'Прогресс';

  @override
  String get photoReportTitle => 'Фотоотчёт';

  @override
  String get addPhoto => 'Добавить фото';

  @override
  String get commentHint => 'Комментарий (необязательно)';

  @override
  String get sendReport => 'Отправить отчёт';

  @override
  String get reportSentOk => 'Фотоотчёт отправлен';

  @override
  String get reportProblem => 'Сообщить о проблеме';

  @override
  String get noteLabel => 'Примечание';

  @override
  String get noTasksTitle => 'Пока задач нет';

  @override
  String get noTasksBody =>
      'Когда вам назначат новую задачу, она появится здесь, и придёт уведомление.';

  @override
  String tasksSummary(int done, int total) {
    return '$done / $total выполнено';
  }

  @override
  String get problemTitle => 'Сообщение о проблеме';

  @override
  String get problemCategoryLabel => 'Тип проблемы';

  @override
  String get problemDescLabel => 'Описание';

  @override
  String get problemDescHint => 'Кратко опишите проблему...';

  @override
  String get problemPhotos => 'Фотографии';

  @override
  String get problemSubmit => 'Отправить';

  @override
  String get problemSentOk => 'Сообщение о проблеме отправлено';

  @override
  String get catBroken => 'Сломанный предмет';

  @override
  String get catTechnical => 'Техническая неисправность';

  @override
  String get catWater => 'Протечка воды';

  @override
  String get catBurnt => 'Перегоревшая лампа';

  @override
  String get catElectric => 'Проблема с электрикой';

  @override
  String get catMechanism => 'Сломан механизм';

  @override
  String get catOther => 'Другое';

  @override
  String get roomsTitle => 'Комнаты';

  @override
  String get tabOccupied => 'Занятые';

  @override
  String get tabUpcoming => 'Скоро уборка';

  @override
  String get checkoutLabel => 'Время выезда';

  @override
  String get overdueBadge => 'Просрочено';

  @override
  String leftMinutes(int n) {
    return 'Осталось $n мин';
  }

  @override
  String leftHours(int h, int m) {
    return 'Осталось $h ч $m мин';
  }

  @override
  String get guestRequests => 'Запросы гостя';

  @override
  String get writeToReception => 'Написать на ресепшн';

  @override
  String get reservedBadge => 'Ожидается';

  @override
  String get checkedInBadge => 'Гость в номере';

  @override
  String get bookingDaily => 'Посуточно';

  @override
  String get bookingHourly => 'Почасово';

  @override
  String get noOccupiedTitle => 'Занятых комнат нет';

  @override
  String get noOccupiedBody => 'Сейчас нет комнат с заселёнными гостями.';

  @override
  String get upcomingEmptyTitle => 'Ближайших уборок нет';

  @override
  String get upcomingEmptyBody =>
      'Комнаты с приближающимся временем выезда появятся здесь.';

  @override
  String get upcomingHint =>
      'После выезда гостя комнату нужно убрать. Список отсортирован по времени выезда.';

  @override
  String get roomStatusAvailable => 'Свободна';

  @override
  String get roomStatusReserved => 'Забронирована';

  @override
  String get roomStatusOccupied => 'Занята';

  @override
  String get roomStatusCleaning => 'Уборка';

  @override
  String get roomStatusMaintenance => 'Ремонт';

  @override
  String get roomStatusInspection => 'Проверка';

  @override
  String get roomStatusOutOfService => 'Не работает';

  @override
  String get chatTitle => 'Чат с ресепшн';

  @override
  String get chatSubtitle => 'Сообщения видят все сотрудники';

  @override
  String get messageHint => 'Напишите сообщение...';

  @override
  String get markDone => 'Отметить выполненным';

  @override
  String doneByName(String name) {
    return 'Выполнил: $name';
  }

  @override
  String get openBadge => 'Открыто';

  @override
  String get attachPhoto => 'Отправить фото';

  @override
  String get imageMessageBody => '📷 Фото';

  @override
  String get uploadImageDenied =>
      'Для отправки фото вам не выдано право «file.upload». Обратитесь к администратору.';

  @override
  String get noMessagesTitle => 'Сообщений нет';

  @override
  String get noMessagesBody =>
      'Переписка с ресепшн и другими сотрудниками появится здесь.';

  @override
  String get selectRoom => 'Выбрать комнату';

  @override
  String get noRoom => 'Без комнаты';

  @override
  String get notificationsTitle => 'Уведомления';

  @override
  String get markAllRead => 'Отметить все прочитанными';

  @override
  String get noNotifsTitle => 'Уведомлений нет';

  @override
  String get noNotifsBody =>
      'Уведомления о новых задачах и сообщениях появятся здесь.';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get positionLabel => 'Должность';

  @override
  String get phoneLabel => 'Телефон';

  @override
  String get idLabel => 'ID сотрудника';

  @override
  String get hotelLabel => 'Отель';

  @override
  String get branchLabel => 'Филиал';

  @override
  String get branchSwitchTitle => 'Сменить филиал';

  @override
  String get branchSwitchHint =>
      'У каждого филиала свои номера, гости, касса и отчёты. Откроются данные выбранного филиала.';

  @override
  String get branchMain => 'Основной филиал';

  @override
  String get scheduleLabel => 'Рабочее время';

  @override
  String get statsTitle => 'Статистика работы';

  @override
  String get statToday => 'Сегодня';

  @override
  String get statWeek => 'За неделю';

  @override
  String get statMonth => 'За месяц';

  @override
  String get statAvg => 'Среднее время';

  @override
  String get statActive => 'В работе';

  @override
  String get completedTasks => 'выполнено';

  @override
  String statMinutes(int n) {
    return '$n мин';
  }

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get languageLabel => 'Язык';

  @override
  String get themeLabel => 'Тема';

  @override
  String get themeLight => 'Дневная';

  @override
  String get themeDark => 'Ночная';

  @override
  String get themeSystem => 'Как в системе';

  @override
  String get quickUnlockLabel => 'Быстрый вход (Face ID / отпечаток)';

  @override
  String get quickUnlockDesc => 'При открытии приложения потребуется биометрия';

  @override
  String get logoutConfirmTitle => 'Выйти из аккаунта?';

  @override
  String get logoutConfirmBody =>
      'Для повторного входа понадобятся логин и пароль.';

  @override
  String appVersion(String v) {
    return 'Версия $v';
  }

  @override
  String get roleHousekeeper => 'Горничная';

  @override
  String get roleAdmin => 'Администратор';

  @override
  String get roleManager => 'Менеджер';

  @override
  String get roleReception => 'Сотрудник ресепшн';

  @override
  String get roleMaintenance => 'Техническая служба';

  @override
  String get roleAccountant => 'Бухгалтер';

  @override
  String get roleStaff => 'Сотрудник';

  @override
  String roleHomeSoonTitle(String role) {
    return 'Раздел «$role» скоро';
  }

  @override
  String get roleHomeSoonBody =>
      'Специальный раздел для вашей должности в разработке. Пока вам доступны чат, уведомления и профиль.';

  @override
  String get yourTools => 'Доступные возможности';

  @override
  String get faceGateTitle => 'Привяжите своё лицо';

  @override
  String get faceGateBody =>
      'Вход в систему двухэтапный: пароль и лицо. У вас ещё не привязано лицо — аккаунт пока защищён только паролем. Привяжите лицо, чтобы продолжить.';

  @override
  String get faceEnrollAction => 'Привязать лицо';

  @override
  String get faceEnrolledOk => 'Лицо привязано ✅';

  @override
  String get faceSection => 'Вход по лицу';

  @override
  String faceStatusEnrolled(int count) {
    return 'Привязано · $count обр.';
  }

  @override
  String get faceStatusNotEnrolled => 'Не привязано';

  @override
  String get faceAddSample => 'Добавить ещё образец';

  @override
  String get faceDeleteAction => 'Удалить профили лица';

  @override
  String get faceDeleteTitle => 'Удалить профили лица?';

  @override
  String get faceDeleteBody =>
      'При входе лицо запрашиваться не будет, и система потребует привязать его заново при следующем входе.';

  @override
  String get faceDeletedOk => 'Профили лица удалены';

  @override
  String get faceEngineOff => 'Проверка лица на сервере пока не включена.';

  @override
  String get faceAutoPlace => 'Поместите лицо в овал';

  @override
  String get faceAutoCloser => 'Подойдите ближе';

  @override
  String get faceAutoFarther => 'Отодвиньтесь немного';

  @override
  String get faceAutoCenter => 'Поместите лицо по центру';

  @override
  String get faceAutoLookStraight => 'Смотрите прямо в камеру';

  @override
  String get faceAutoHold => 'Не двигайтесь…';

  @override
  String get tabBookings => 'Брони';

  @override
  String get tabReport => 'Отчёт';

  @override
  String get bookingsTitle => 'Брони';

  @override
  String get bookingsSubtitle => 'Заезды, проживающие и выезды';

  @override
  String get bookingsSearchHint => 'Гость, номер брони или комната...';

  @override
  String get bookingsAll => 'Все';

  @override
  String get bookingArrival => 'Заезд';

  @override
  String get bookingInhouse => 'Проживает';

  @override
  String get bookingDeparture => 'Выезд';

  @override
  String get bookingsEmptyTitle => 'На этот день броней нет';

  @override
  String get bookingsEmptyBody => 'Выберите другой день или зайдите позже.';

  @override
  String get bookingsNotFoundTitle => 'Не найдено';

  @override
  String get bookingsNotFoundBody => 'По запросу ничего не найдено.';

  @override
  String get bookingPaid => 'Оплачено';

  @override
  String get bookingCancelled => 'Отменена';

  @override
  String bookingDebt(String amount) {
    return 'Долг: $amount';
  }

  @override
  String get bookingPeriod => 'Период';

  @override
  String get bookingGuests => 'Гости';

  @override
  String get bookingPhone => 'Телефон';

  @override
  String get bookingNote => 'Заметка';

  @override
  String get bookingTotal => 'Итого';

  @override
  String get bookingPaidAmount => 'Оплачено';

  @override
  String get bookingRemaining => 'Остаток';

  @override
  String get bookingReadOnlyHint =>
      'Здесь бронь только просматривается. Редактирование, приём оплаты и выезд выполняются на большом экране.';

  @override
  String get previousDay => 'Предыдущий день';

  @override
  String get nextDay => 'Следующий день';

  @override
  String get copied => 'Скопировано';

  @override
  String get periodToday => 'Сегодня';

  @override
  String get periodYesterday => 'Вчера';

  @override
  String get periodLast7 => '7 дней';

  @override
  String get periodThisMonth => 'Этот месяц';

  @override
  String get reportNet => 'Чистый результат';

  @override
  String reportNetBreakdown(String income, String expense) {
    return 'Доход $income − расход $expense';
  }

  @override
  String get reportCollected => 'Принято денег';

  @override
  String reportCash(String amount) {
    return 'Наличные: $amount';
  }

  @override
  String get reportBookings => 'Мои брони';

  @override
  String reportCancelled(int count) {
    return 'Отменено: $count';
  }

  @override
  String get reportShop => 'Продажи магазина';

  @override
  String reportShopCount(int count) {
    return 'Продаж: $count';
  }

  @override
  String get reportExpenses => 'Мои расходы';

  @override
  String reportExpenseCount(int count) {
    return 'Записей: $count';
  }

  @override
  String get reportRefunds => 'Возвращено';

  @override
  String get reportRefundsHint => 'уже вычтено';

  @override
  String get reportShopUnpaid => 'Долг магазина';

  @override
  String get reportShopUnpaidHint => 'записано на брони';

  @override
  String get reportByMethod => 'По способам оплаты';

  @override
  String get methodCash => 'Наличные';

  @override
  String get methodCard => 'Карта';

  @override
  String get methodOnline => 'Онлайн';

  @override
  String get methodBankTransfer => 'Банковский перевод';

  @override
  String get methodOther => 'Другое';

  @override
  String get callWatchTitle => 'Определять гостя по звонку';

  @override
  String get callWatchBody =>
      'Когда гость звонит, его имя и комната появятся на экране компьютера. Нужно разрешение на чтение входящего номера.';

  @override
  String get callWatchEnable => 'Включить';

  @override
  String get callWatchEnabled => 'Включено — звонки видны на компьютере';

  @override
  String callMatched(String name) {
    return 'Звонит $name';
  }

  @override
  String get dismiss => 'Закрыть';

  @override
  String get tabHome => 'Главная';

  @override
  String get tabTeam => 'Команда';

  @override
  String get broadcastAction => 'Объявление';

  @override
  String get pulseTitle => 'Пульс отеля';

  @override
  String get pulseLive => 'Онлайн';

  @override
  String pulseUpdatedAt(String time) {
    return 'Обновлено $time';
  }

  @override
  String pulsePartialWarning(int count) {
    return '$count разделов не загрузились — потяните вниз для обновления';
  }

  @override
  String get occupancyTitle => 'Загрузка';

  @override
  String roomsOf(int busy, int total) {
    return '$busy из $total комнат заняты';
  }

  @override
  String get heroArrivals => 'Заезд';

  @override
  String get heroDepartures => 'Выезд';

  @override
  String get heroInHouse => 'Проживают';

  @override
  String heroOverdue(int count) {
    return '$count комнат просрочили выезд';
  }

  @override
  String get todayBookingsTitle => 'Брони на сегодня';

  @override
  String get financeTitle => 'Финансы';

  @override
  String get financeIncome => 'Выручка';

  @override
  String get financeExpenses => 'Расходы';

  @override
  String get financeNet => 'Чистый итог';

  @override
  String get financeDebt => 'Долги';

  @override
  String financePayments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count платежа',
      many: '$count платежей',
      few: '$count платежа',
      one: '$count платёж',
    );
    return '$_temp0';
  }

  @override
  String get financeLast7 => 'Выручка за последние 7 дней';

  @override
  String get currencySuffix => 'сум';

  @override
  String get moneyThousand => 'тыс.';

  @override
  String get moneyMillion => 'млн';

  @override
  String get hkTitle => 'Хозяйство';

  @override
  String get taskOpen => 'Ожидает';

  @override
  String get taskInProgress => 'В работе';

  @override
  String get taskCompleted => 'Выполнено';

  @override
  String get taskCancelled => 'Отменено';

  @override
  String get hkDoneToday => 'Выполнено сегодня';

  @override
  String hkCleaningRooms(int count) {
    return '$count комнат убирается';
  }

  @override
  String get attentionTitle => 'Требует внимания';

  @override
  String get attentionNone => 'Всё в порядке — ничего не требует внимания';

  @override
  String attentionComplaints(int count) {
    return '$count новых жалоб';
  }

  @override
  String attentionFeedbackOpen(int count) {
    return '$count открытых обращений';
  }

  @override
  String attentionDebtors(int count, String amount) {
    return '$count долгов по броням · $amount';
  }

  @override
  String attentionProblems(int count) {
    return '$count открытых проблем от сотрудников';
  }

  @override
  String attentionHandover(int count) {
    return '$count смен ждут передачи';
  }

  @override
  String attentionOpenTasks(int count) {
    return '$count задач без исполнителя';
  }

  @override
  String teamOnDuty(int onDuty, int total) {
    return '$onDuty из $total сотрудников на смене';
  }

  @override
  String shiftsOpen(int count) {
    return '$count открытых смен';
  }

  @override
  String get roomMapTitle => 'Карта комнат';

  @override
  String get roomStateAvailable => 'Свободна';

  @override
  String get roomStateOccupied => 'Занята';

  @override
  String get roomStateReserved => 'Бронь';

  @override
  String get roomStateCleaning => 'Уборка';

  @override
  String get roomStateMaintenance => 'Ремонт';

  @override
  String get roomStateInspection => 'Проверка';

  @override
  String get roomStateOutOfService => 'Не обслуживается';

  @override
  String get roomStateUnknown => 'Неизвестно';

  @override
  String floorLabel(int number) {
    return '$number этаж';
  }

  @override
  String get floorOther => 'Другие комнаты';

  @override
  String get roomsEmptyTitle => 'Комнаты не найдены';

  @override
  String get roomsEmptyBody => 'Нет комнат в этом состоянии';

  @override
  String roomSinceLabel(String duration) {
    return 'уже $duration';
  }

  @override
  String roomCapacity(int count) {
    return '$count мест';
  }

  @override
  String get roomPrice => 'Цена';

  @override
  String get roomGuestTitle => 'Гость';

  @override
  String get roomNoStay => 'Нет активного бронирования';

  @override
  String roomCompanions(String names) {
    return 'Сопровождающие: $names';
  }

  @override
  String get roomChangeStatus => 'Изменить статус';

  @override
  String get roomCreateTask => 'Создать задачу';

  @override
  String get roomStatusChanged => 'Статус комнаты обновлён';

  @override
  String get roomStatusBusyHint =>
      'Статусы «занята» и «бронь» меняются через бронирование — оформите заезд или выезд';

  @override
  String get notesLabel => 'Заметка';

  @override
  String get hourShort => 'ч';

  @override
  String get minuteShort => 'мин';

  @override
  String taskCreateTitle(String room) {
    return 'Новая задача · $room';
  }

  @override
  String get taskTypeLabel => 'Тип задачи';

  @override
  String get taskTypeCleaning => 'Уборка';

  @override
  String get taskTypeDeepCleaning => 'Генеральная уборка';

  @override
  String get taskTypeMaintenance => 'Ремонт';

  @override
  String get taskTypeInspection => 'Проверка';

  @override
  String get taskTypeTurnDown => 'Вечерняя подготовка';

  @override
  String get priorityLabel => 'Приоритет';

  @override
  String get priorityLow => 'Низкий';

  @override
  String get priorityMedium => 'Средний';

  @override
  String get priorityHigh => 'Высокий';

  @override
  String get priorityUrgent => 'Срочно';

  @override
  String get assigneeLabel => 'Исполнитель';

  @override
  String get assigneeNone => 'Автоматически (по очереди)';

  @override
  String get taskCreated => 'Задача создана';

  @override
  String get create => 'Создать';

  @override
  String get segmentStaff => 'Сотрудники';

  @override
  String get segmentShifts => 'Смены';

  @override
  String get segmentTasks => 'Задачи';

  @override
  String get segmentProblems => 'Проблемы';

  @override
  String get staffSearchHint => 'Имя, логин или телефон';

  @override
  String get staffOnDutyBadge => 'На смене';

  @override
  String get staffOffDuty => 'Вне смены';

  @override
  String get staffOnline => 'Сейчас в приложении';

  @override
  String get staffStatusInactive => 'Неактивен';

  @override
  String get staffStatusTerminated => 'Уволен';

  @override
  String get staffLastLoginLabel => 'Последний вход';

  @override
  String get staffNeverLoggedIn => 'Ещё не входил';

  @override
  String get staffEmptyTitle => 'Сотрудники не найдены';

  @override
  String get staffEmptyBody => 'Никто не подходит под запрос';

  @override
  String get shiftsNotCashTitle => 'Кассовый режим выключен';

  @override
  String get shiftsNotCashBody =>
      'Смены ведутся, когда в настройках включён кассовый режим';

  @override
  String get shiftsOpenTitle => 'Открытые смены';

  @override
  String get shiftsClosedTitle => 'Закрытые смены';

  @override
  String get shiftsEmpty => 'Смен пока нет';

  @override
  String get shiftActive => 'Активна';

  @override
  String get shiftPendingHandover => 'Ждёт передачи';

  @override
  String get shiftForceClosed => 'Закрыта принудительно';

  @override
  String shiftStarted(String time) {
    return 'Начата $time';
  }

  @override
  String get shiftDurationLabel => 'Длительность';

  @override
  String get shiftOpeningCash => 'Начальная касса';

  @override
  String get shiftCounted => 'Подсчитано';

  @override
  String get shiftDiff => 'Разница';

  @override
  String get shiftForceClose => 'Закрыть принудительно';

  @override
  String shiftForceCloseBody(String name) {
    return 'Смена $name будет закрыта. Без подсчитанной суммы она закроется по ожидаемой кассе.';
  }

  @override
  String get shiftCountedCashLabel => 'Подсчитанные наличные (необязательно)';

  @override
  String get shiftHandOver => 'Передать кассу следующему сотруднику';

  @override
  String get shiftHandOverHint =>
      'Если выключено — деньги забирает админ, смена полностью закрывается';

  @override
  String get shiftForceClosedDone => 'Смена закрыта';

  @override
  String get tasksEmptyTitle => 'Задач нет';

  @override
  String get tasksEmptyBody => 'Задачу можно создать с карты комнат';

  @override
  String get taskAssign => 'Назначить';

  @override
  String get taskReassign => 'Переназначить';

  @override
  String get taskUnassigned => 'Не назначена';

  @override
  String get taskAssigned => 'Задача назначена';

  @override
  String get taskComplete => 'Завершить';

  @override
  String get taskCancelAction => 'Отменить задачу';

  @override
  String get taskCompleteConfirm =>
      'Отметить задачу выполненной? Для уборки комната станет свободной.';

  @override
  String get taskCancelConfirm => 'Отменить задачу?';

  @override
  String taskWaiting(String duration) {
    return 'ждёт $duration';
  }

  @override
  String taskWorking(String duration) {
    return 'в работе $duration';
  }

  @override
  String taskChecklist(int done, int total) {
    return '$done/$total пунктов';
  }

  @override
  String get taskChecklistLabel => 'Чек-лист';

  @override
  String get taskAutoCompleted => 'Завершена автоматически';

  @override
  String get taskCreatedAt => 'Создана';

  @override
  String get taskStartedAt => 'Начата';

  @override
  String get assignSheetTitle => 'Кому назначить?';

  @override
  String get problemsEmptyTitle => 'Проблем нет';

  @override
  String get problemsEmptyBody =>
      'Здесь появятся проблемы, о которых сообщили сотрудники';

  @override
  String get problemOpen => 'Открыта';

  @override
  String get problemResolved => 'Решена';

  @override
  String get problemTake => 'Взять в работу';

  @override
  String get problemResolve => 'Отметить решённой';

  @override
  String problemReportedBy(String name) {
    return 'Сообщил(а) $name';
  }

  @override
  String get problemResolvedTitle => 'Решённые';

  @override
  String get feedbackTitle => 'Обращения';

  @override
  String get feedbackRequest => 'Запрос';

  @override
  String get feedbackSuggestion => 'Предложение';

  @override
  String get feedbackComplaint => 'Жалоба';

  @override
  String get feedbackNew => 'Новое';

  @override
  String get feedbackInProgress => 'В работе';

  @override
  String get feedbackResolved => 'Решено';

  @override
  String get feedbackRejected => 'Отклонено';

  @override
  String get feedbackFilterOpen => 'Открытые';

  @override
  String get feedbackFilterComplaints => 'Жалобы';

  @override
  String get feedbackFilterResolved => 'Закрытые';

  @override
  String get feedbackEmptyTitle => 'Обращений нет';

  @override
  String get feedbackEmptyBody => 'Обращения гостей вносит ресепшн';

  @override
  String get feedbackResolveAction => 'Решить';

  @override
  String get feedbackRejectAction => 'Отклонить';

  @override
  String get feedbackReopen => 'Открыть снова';

  @override
  String get feedbackResolutionLabel => 'Решение';

  @override
  String get feedbackResolutionRequired => 'Для закрытия нужен текст решения';

  @override
  String feedbackRoom(String number) {
    return 'Комната $number';
  }

  @override
  String feedbackAssigned(String name) {
    return 'Ответственный: $name';
  }

  @override
  String get feedbackStatusUpdated => 'Статус обращения обновлён';

  @override
  String get broadcastTitle => 'Объявление всем сотрудникам';

  @override
  String get broadcastBody =>
      'Уйдёт push-уведомлением всем активным сотрудникам этого филиала и администраторам';

  @override
  String get broadcastTitleHint => 'Заголовок';

  @override
  String get broadcastMessageHint => 'Текст (необязательно)';

  @override
  String broadcastSent(int count) {
    return 'Объявление отправлено на $count устройств';
  }

  @override
  String roomStayNights(int done, int total) {
    return 'Ночь $done из $total';
  }

  @override
  String get roomActionsTitle => 'Действия';

  @override
  String get broadcastPreview => 'Так это увидит сотрудник';

  @override
  String get broadcastNow => 'сейчас';

  @override
  String broadcastRecipients(int count) {
    return 'Получат $count активных сотрудников';
  }

  @override
  String get broadcastQuick => 'Быстрые тексты';

  @override
  String get broadcastQuick1 => 'Собрание через 10 минут';

  @override
  String get broadcastQuick2 => 'Не забудьте передать смену';

  @override
  String get broadcastQuick3 => 'Особое внимание чистоте';

  @override
  String get broadcastTitlePlaceholder => 'Заголовок объявления';

  @override
  String get broadcastBodyPlaceholder => 'Здесь появится текст объявления';

  @override
  String get teamOnDutyNow => 'Сейчас на смене';

  @override
  String get teamNobodyOnDuty => 'Сейчас никого нет на смене';

  @override
  String staffActiveTasks(int count) {
    return '$count активных задач';
  }

  @override
  String get staffNoTasks => 'Нет активных задач';

  @override
  String get taskStepAssigned => 'Назначена';

  @override
  String get taskTimelineTitle => 'Ход задачи';

  @override
  String get taskNotStarted => 'Ещё не начата';

  @override
  String get shiftSummaryTitle => 'Смена';

  @override
  String get assigneeAuto => 'Авто';

  @override
  String get roomsFreeNow => 'Свободно сейчас';

  @override
  String get stayCheckIn => 'Заезд';

  @override
  String get stayCheckOut => 'Выезд';

  @override
  String get roleConfigurator => 'Настройщик';

  @override
  String get configuratorTitle => 'Учётная запись настройщика';

  @override
  String get configuratorBody =>
      'Гостиницы настраиваются в веб-приложении. Войдите в GoHotel на компьютере с этим логином, выберите гостиницу и филиал — после этого вам откроются все её разделы и настройки.';

  @override
  String get configuratorHint =>
      'Мобильное приложение предназначено для сотрудников гостиницы.';

  @override
  String get financeDetails => 'Подробнее';

  @override
  String get periodCustom => 'Выбрать';

  @override
  String get financePickRange => 'Выберите период';

  @override
  String get financeRevenue => 'Общая выручка';

  @override
  String financeRevenueParts(String bookings, String shop) {
    return 'Брони: $bookings · Магазин: $shop';
  }

  @override
  String financeAvgPayment(String amount) {
    return 'средний платёж $amount';
  }

  @override
  String get financeVsPrevious => 'к прошлому периоду';

  @override
  String get financeNoPrevious => 'в прошлом периоде выручки не было';

  @override
  String get financeInvoices => 'Счета';

  @override
  String financeInvoicesValue(int count, String amount) {
    return '$count шт. · $amount';
  }

  @override
  String get financeDiscounts => 'Скидки';

  @override
  String get cashNowTitle => 'Сейчас в кассах';

  @override
  String get cashNowHint =>
      'Наличные, которые сейчас должны быть в открытых кассах';

  @override
  String cashDrawersCount(int active, int pending) {
    return 'Открыто: $active · сдаётся: $pending';
  }

  @override
  String get cashNoOpen => 'Сейчас нет открытых касс';

  @override
  String get cashSimpleMode =>
      'Кассовые смены не ведутся — движение наличных за период ниже';

  @override
  String cashBreakdown(
    String opening,
    String payments,
    String shop,
    String expenses,
  ) {
    return 'Начальная $opening + оплаты $payments + магазин $shop − расходы $expenses';
  }

  @override
  String cashCounted(String amount) {
    return 'Пересчитано при сдаче: $amount';
  }

  @override
  String get cashFlowTitle => 'Движение наличных';

  @override
  String get cashIn => 'Приход';

  @override
  String get cashOut => 'Расход';

  @override
  String get cashBalance => 'Остаток';

  @override
  String get chartDaily => 'Выручка и расходы по дням';

  @override
  String get chartWeekly => 'Выручка и расходы по неделям';

  @override
  String chartBest(String day, String amount) {
    return 'Лучший: $day — $amount';
  }

  @override
  String chartAverage(String amount) {
    return 'В среднем за день $amount';
  }

  @override
  String get expenseCategoriesTitle => 'Расходы по категориям';

  @override
  String get expensesNone => 'За период расходов нет';

  @override
  String get debtorsTitle => 'Должники';

  @override
  String debtorsSummary(int count, String amount) {
    return 'Броней: $count · всего $amount';
  }

  @override
  String get debtorsNone => 'Должников нет';

  @override
  String debtorsMore(int count) {
    return 'Ещё $count';
  }

  @override
  String debtorRoom(String room) {
    return 'Номер $room';
  }

  @override
  String debtorCheckOut(String date) {
    return 'выезд $date';
  }

  @override
  String get shiftsCashTitle => 'Кассы смен';

  @override
  String shiftsClosedCount(int count) {
    return 'Закрыто смен: $count';
  }

  @override
  String get shiftsShortage => 'Недостача';

  @override
  String get shiftsSurplus => 'Излишек';

  @override
  String get shiftsNoneClosed => 'За период смены не закрывались';

  @override
  String get financeGuestUnknown => 'Гость';

  @override
  String get financePenalties => 'Штрафы';

  @override
  String financePenaltiesValue(int count, String amount) {
    return '$count шт. · $amount';
  }

  @override
  String get financePenaltiesHint =>
      'За поздний выезд и повреждения — добавляются к долгу по брони';

  @override
  String get staffRevenueTitle => 'Выручка по сотрудникам';

  @override
  String get staffRevenueHint => 'Кто сколько принял: оплаты броней и магазин';

  @override
  String get staffRevenueNone =>
      'За этот период сотрудники не принимали оплату';

  @override
  String staffRevenueShare(String percent) {
    return '$percent от общей выручки';
  }

  @override
  String staffRevenueShowAll(int count) {
    return 'Показать всех ($count)';
  }

  @override
  String get staffRevenueShowLess => 'Свернуть';

  @override
  String get staffUnknown => 'Неизвестный сотрудник';

  @override
  String get staffInactive => 'Не работает';

  @override
  String get staffBookings => 'Оплаты броней';

  @override
  String get staffCashTitle => 'Наличные';

  @override
  String staffCounts(int payments, int sales, int expenses) {
    return 'оплат: $payments · продаж: $sales · расходов: $expenses';
  }

  @override
  String get staffCashIn => 'Принято наличными';

  @override
  String get staffCashOut => 'Расходы наличными';

  @override
  String get staffCashNet => 'Остаток';

  @override
  String staffShopShort(String amount) {
    return 'магазин $amount';
  }

  @override
  String get handoversTitle => 'Деньги от смены к смене';

  @override
  String get handoversHint =>
      'Каждая сданная касса: от кого кому, сколько пересчитано и разница';

  @override
  String get handoversPassed => 'Следующей смене';

  @override
  String get handoversTakenOut => 'Изъято';

  @override
  String get handoversPending => 'Ожидает приёма';

  @override
  String handoversMore(int count) {
    return 'Ещё $count — полный список на странице «Смены» в веб-версии';
  }

  @override
  String get handoverKindPending => 'Ожидает приёма';

  @override
  String get handoverKindCashOut => 'Изъято из кассы (выемка)';

  @override
  String get handoverKindForceTaken =>
      'Закрыта принудительно — забрал руководитель';

  @override
  String handoverAccepted(String time) {
    return 'принято: $time';
  }

  @override
  String get handoverCorrected => 'Исправлено';

  @override
  String handoverReceivedOpening(String amount) {
    return 'Принявший начал с $amount';
  }

  @override
  String handoverExpected(String amount) {
    return 'ожидалось $amount';
  }

  @override
  String get debtWhy => 'Почему';

  @override
  String debtReasonRoom(String room) {
    return 'Проживание (номер $room)';
  }

  @override
  String get debtReasonRoomPlain => 'Проживание';

  @override
  String get debtReasonExtension => 'Пересчёт при выезде (продление)';

  @override
  String debtReasonService(String name) {
    return 'Услуга: $name';
  }

  @override
  String get debtReasonPenalty => 'Штраф';

  @override
  String debtReasonPenaltyWith(String details) {
    return 'Штраф ($details)';
  }

  @override
  String debtReasonShop(String products) {
    return 'Магазин: $products';
  }

  @override
  String get debtReasonShopPlain => 'Магазин';

  @override
  String get debtPenaltyLate => 'поздний выезд';

  @override
  String get debtPenaltyDamage => 'ущерб';

  @override
  String get debtPenaltyOther => 'другое';

  @override
  String debtAcknowledged(String note) {
    return 'Выписан с долгом: $note';
  }

  @override
  String debtOverdueDays(int days) {
    return 'уже $days дн.';
  }

  @override
  String get debtLeftWithDebt => 'Гость выехал с долгом';

  @override
  String get debtTakeBeforeLeave => 'Примите оплату до отъезда гостя';
}
