// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'GoHotel Staff';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get refresh => 'Refresh';

  @override
  String get send => 'Send';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get done => 'Done';

  @override
  String get back => 'Back';

  @override
  String get logout => 'Log out';

  @override
  String get confirm => 'Confirm';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get error => 'Error';

  @override
  String get optional => 'optional';

  @override
  String get enable => 'Enable';

  @override
  String get notNow => 'Not now';

  @override
  String get networkError =>
      'No internet connection. Check your connection and try again.';

  @override
  String get serverError => 'Server error. Please try again in a moment.';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get permissionDenied => 'You don\'t have permission for this action.';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeSubtitle => 'Sign in to your account to continue';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign in';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get wrongCredentials => 'Wrong username or password';

  @override
  String get faceStepTitle => 'Face verification';

  @override
  String get faceStepBody =>
      'For security, verify your face. Look straight at the camera and take a photo in a well-lit place.';

  @override
  String get faceOpenCamera => 'Open camera';

  @override
  String get faceRetry => 'Retake photo';

  @override
  String get faceNoCameraBtn => 'Sign in without camera';

  @override
  String get faceNoCameraReason => 'Camera is not working on this device';

  @override
  String get faceNotRecognized => 'Face didn\'t match. Please try again.';

  @override
  String get faceNotDetected =>
      'No face detected — look straight at the camera and try again.';

  @override
  String get devicePendingTitle => 'Device awaiting approval';

  @override
  String get devicePendingBody =>
      'This is the first sign-in from this device. Try again after an administrator approves it.';

  @override
  String get deviceBlockedTitle => 'Device blocked';

  @override
  String get deviceBlockedBody =>
      'Sign-in from this device is not allowed. Contact your administrator.';

  @override
  String get scanTitle => 'Scan a document';

  @override
  String get scanPickType => 'Document type';

  @override
  String get scanPickTypeBody => 'Which document are we scanning?';

  @override
  String get scanIdCard => 'ID card';

  @override
  String get scanIdCardBody =>
      'Front side is enough — add the back if you wish';

  @override
  String get scanPassport => 'Passport';

  @override
  String get scanPassportBody => 'Data page';

  @override
  String get scanStepFront => 'Front side';

  @override
  String get scanStepBack => 'Back side';

  @override
  String get scanSendOneSide => 'Front side is enough — send';

  @override
  String get scanStepPassport => 'Data page';

  @override
  String get scanGuide => 'Fit the document inside the frame and hold still';

  @override
  String get scanReading => 'Reading the document...';

  @override
  String get scanCameraFailed => 'Could not open the camera';

  @override
  String get scanFailedTitle => 'Could not read the document';

  @override
  String get scanMatchedTitle => 'Guest found';

  @override
  String get scanNewGuestTitle => 'New guest';

  @override
  String get scanSentBody =>
      'The new booking dialog opened on the front desk screen.';

  @override
  String get scanAgain => 'Scan again';

  @override
  String get serviceStoppedTitle => 'Service stopped';

  @override
  String get serviceStoppedBody =>
      'The system has been switched off for your hotel. This is not an app failure — your data is safe.';

  @override
  String get serviceStoppedHint =>
      'Contact your system administrator to restore the service. Once restored, “Check again” resumes your work.';

  @override
  String get serviceStoppedRetry => 'Check again';

  @override
  String get outsideHoursTitle => 'Outside your working hours';

  @override
  String get outsideHoursBody =>
      'Your hotel restricts work outside working hours. When your working hours start, the app will continue on its own.';

  @override
  String get outsideHoursScheduleLabel => 'Your working hours';

  @override
  String get outsideHoursHint =>
      'The app checks again every minute. If you need to work outside your hours, contact your administrator.';

  @override
  String get outsideHoursRetry => 'Check again';

  @override
  String get outsideHoursStill => 'Your working hours haven\'t started yet';

  @override
  String get outsideHoursError =>
      'It\'s outside your working hours. You can continue once they start.';

  @override
  String get biometricEnableTitle => 'Quick unlock';

  @override
  String get biometricEnableBody =>
      'Enable quick sign-in with fingerprint or face next time?';

  @override
  String get biometricReason => 'Verify your identity to enter the app';

  @override
  String get unlock => 'Unlock';

  @override
  String get unlockTitle => 'App is locked';

  @override
  String get unlockBody => 'Verify your identity to continue';

  @override
  String get loginAsOther => 'Sign in with another account';

  @override
  String get tabTasks => 'Tasks';

  @override
  String get tabRooms => 'Rooms';

  @override
  String get tabChat => 'Chat';

  @override
  String get tabProfile => 'Profile';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get tasksTitle => 'Cleaning tasks';

  @override
  String get filterAll => 'All';

  @override
  String get filterNew => 'New';

  @override
  String get filterInProgress => 'In progress';

  @override
  String get filterDone => 'Done';

  @override
  String roomTitle(String n) {
    return 'Room $n';
  }

  @override
  String get urgentBadge => 'Urgent';

  @override
  String deadlineAt(String time) {
    return 'Due: $time';
  }

  @override
  String get guestLabel => 'Guest';

  @override
  String get statusNew => 'New';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusDone => 'Done';

  @override
  String get startCleaning => 'Start cleaning';

  @override
  String get finishCleaning => 'Finish cleaning';

  @override
  String get confirmFinishTitle => 'Finished cleaning?';

  @override
  String get confirmFinishBody =>
      'The task will be marked as done and the room will become “Available”.';

  @override
  String get cleaningDone => 'Great job! Room is clean ✅';

  @override
  String get checklistTitle => 'Checklist';

  @override
  String checklistRemaining(int count) {
    return '$count item(s) not checked';
  }

  @override
  String confirmFinishBodyRemaining(int count) {
    return '$count item(s) are still unchecked. Finish anyway? The task will be marked as done and the room will become “Available”.';
  }

  @override
  String get checklistAllDone => 'All items checked';

  @override
  String get progressLabel => 'Progress';

  @override
  String get photoReportTitle => 'Photo report';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get commentHint => 'Comment (optional)';

  @override
  String get sendReport => 'Send report';

  @override
  String get reportSentOk => 'Photo report sent';

  @override
  String get reportProblem => 'Report a problem';

  @override
  String get noteLabel => 'Note';

  @override
  String get noTasksTitle => 'No tasks yet';

  @override
  String get noTasksBody =>
      'When a new task is assigned to you, it will appear here and you\'ll get a notification.';

  @override
  String tasksSummary(int done, int total) {
    return '$done / $total done';
  }

  @override
  String get problemTitle => 'Report a problem';

  @override
  String get problemCategoryLabel => 'Problem type';

  @override
  String get problemDescLabel => 'Description';

  @override
  String get problemDescHint => 'Briefly describe the problem...';

  @override
  String get problemPhotos => 'Photos';

  @override
  String get problemSubmit => 'Submit';

  @override
  String get problemSentOk => 'Problem report sent';

  @override
  String get catBroken => 'Broken item';

  @override
  String get catTechnical => 'Technical fault';

  @override
  String get catWater => 'Water leak';

  @override
  String get catBurnt => 'Burnt-out light';

  @override
  String get catElectric => 'Electrical fault';

  @override
  String get catMechanism => 'Broken mechanism';

  @override
  String get catOther => 'Other';

  @override
  String get roomsTitle => 'Rooms';

  @override
  String get tabOccupied => 'Occupied';

  @override
  String get tabUpcoming => 'Upcoming cleaning';

  @override
  String get checkoutLabel => 'Check-out time';

  @override
  String get overdueBadge => 'Overdue';

  @override
  String leftMinutes(int n) {
    return '$n min left';
  }

  @override
  String leftHours(int h, int m) {
    return '$h h $m min left';
  }

  @override
  String get guestRequests => 'Guest requests';

  @override
  String get writeToReception => 'Message reception';

  @override
  String get reservedBadge => 'Arriving';

  @override
  String get checkedInBadge => 'Guest inside';

  @override
  String get bookingDaily => 'Daily';

  @override
  String get bookingHourly => 'Hourly';

  @override
  String get noOccupiedTitle => 'No occupied rooms';

  @override
  String get noOccupiedBody =>
      'There are no rooms with checked-in guests right now.';

  @override
  String get upcomingEmptyTitle => 'No upcoming cleanings';

  @override
  String get upcomingEmptyBody =>
      'Rooms with an approaching check-out time will appear here.';

  @override
  String get upcomingHint =>
      'After the guest checks out, the room will need cleaning. The list is sorted by check-out time.';

  @override
  String get roomStatusAvailable => 'Available';

  @override
  String get roomStatusReserved => 'Reserved';

  @override
  String get roomStatusOccupied => 'Occupied';

  @override
  String get roomStatusCleaning => 'Cleaning';

  @override
  String get roomStatusMaintenance => 'Maintenance';

  @override
  String get roomStatusInspection => 'Inspection';

  @override
  String get roomStatusOutOfService => 'Out of service';

  @override
  String get chatTitle => 'Reception chat';

  @override
  String get chatSubtitle => 'Messages are visible to all staff';

  @override
  String get messageHint => 'Type a message...';

  @override
  String get markDone => 'Mark as done';

  @override
  String doneByName(String name) {
    return 'Done by: $name';
  }

  @override
  String get openBadge => 'Open';

  @override
  String get attachPhoto => 'Send photo';

  @override
  String get imageMessageBody => '📷 Photo';

  @override
  String get uploadImageDenied =>
      'You don\'t have the “file.upload” permission to send photos. Contact your administrator.';

  @override
  String get noMessagesTitle => 'No messages';

  @override
  String get noMessagesBody =>
      'Conversations with reception and other staff will appear here.';

  @override
  String get selectRoom => 'Select room';

  @override
  String get noRoom => 'No room';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get noNotifsTitle => 'No notifications';

  @override
  String get noNotifsBody =>
      'Notifications about new tasks and messages will appear here.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get positionLabel => 'Position';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get idLabel => 'Employee ID';

  @override
  String get hotelLabel => 'Hotel';

  @override
  String get scheduleLabel => 'Working hours';

  @override
  String get statsTitle => 'Work statistics';

  @override
  String get statToday => 'Today';

  @override
  String get statWeek => 'This week';

  @override
  String get statMonth => 'This month';

  @override
  String get statAvg => 'Average time';

  @override
  String get statActive => 'In progress';

  @override
  String get completedTasks => 'completed';

  @override
  String statMinutes(int n) {
    return '$n min';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageLabel => 'Language';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get quickUnlockLabel => 'Quick unlock (Face ID / fingerprint)';

  @override
  String get quickUnlockDesc =>
      'Biometric confirmation will be required on app start';

  @override
  String get logoutConfirmTitle => 'Log out of your account?';

  @override
  String get logoutConfirmBody =>
      'You will need your username and password to sign in again.';

  @override
  String appVersion(String v) {
    return 'Version $v';
  }

  @override
  String get roleHousekeeper => 'Housekeeper';

  @override
  String get roleAdmin => 'Administrator';

  @override
  String get roleManager => 'Manager';

  @override
  String get roleReception => 'Receptionist';

  @override
  String get roleMaintenance => 'Maintenance';

  @override
  String get roleAccountant => 'Accountant';

  @override
  String get roleStaff => 'Staff member';

  @override
  String roleHomeSoonTitle(String role) {
    return '$role section coming soon';
  }

  @override
  String get roleHomeSoonBody =>
      'A dedicated section for your position is under development. For now you can use chat, notifications and your profile.';

  @override
  String get yourTools => 'Available tools';

  @override
  String get faceGateTitle => 'Enroll your face';

  @override
  String get faceGateBody =>
      'Signing in has two steps: password and face. You haven\'t enrolled a face yet — your account is protected by password only. Enroll your face to continue.';

  @override
  String get faceEnrollAction => 'Enroll face';

  @override
  String get faceEnrolledOk => 'Face enrolled ✅';

  @override
  String get faceSection => 'Face sign-in';

  @override
  String faceStatusEnrolled(int count) {
    return 'Enrolled · $count sample(s)';
  }

  @override
  String get faceStatusNotEnrolled => 'Not enrolled';

  @override
  String get faceAddSample => 'Add another sample';

  @override
  String get faceDeleteAction => 'Delete face profiles';

  @override
  String get faceDeleteTitle => 'Delete face profiles?';

  @override
  String get faceDeleteBody =>
      'Face won\'t be requested at sign-in, and the system will require enrolling again next time you sign in.';

  @override
  String get faceDeletedOk => 'Face profiles deleted';

  @override
  String get faceEngineOff =>
      'Server-side face verification is not enabled yet.';

  @override
  String get faceAutoPlace => 'Place your face inside the oval';

  @override
  String get faceAutoCloser => 'Move closer';

  @override
  String get faceAutoFarther => 'Move back a little';

  @override
  String get faceAutoCenter => 'Center your face';

  @override
  String get faceAutoLookStraight => 'Look straight at the camera';

  @override
  String get faceAutoHold => 'Hold still…';

  @override
  String get tabBookings => 'Bookings';

  @override
  String get tabReport => 'Report';

  @override
  String get bookingsTitle => 'Bookings';

  @override
  String get bookingsSubtitle => 'Arrivals, in-house and departures';

  @override
  String get bookingsSearchHint => 'Guest, booking number or room...';

  @override
  String get bookingsAll => 'All';

  @override
  String get bookingArrival => 'Arrival';

  @override
  String get bookingInhouse => 'In-house';

  @override
  String get bookingDeparture => 'Departure';

  @override
  String get bookingsEmptyTitle => 'No bookings on this day';

  @override
  String get bookingsEmptyBody => 'Pick another day or check back later.';

  @override
  String get bookingsNotFoundTitle => 'Not found';

  @override
  String get bookingsNotFoundBody => 'No booking matches your search.';

  @override
  String get bookingPaid => 'Paid';

  @override
  String get bookingCancelled => 'Cancelled';

  @override
  String bookingDebt(String amount) {
    return 'Due: $amount';
  }

  @override
  String get bookingPeriod => 'Period';

  @override
  String get bookingGuests => 'Guests';

  @override
  String get bookingPhone => 'Phone';

  @override
  String get bookingNote => 'Note';

  @override
  String get bookingTotal => 'Total';

  @override
  String get bookingPaidAmount => 'Paid';

  @override
  String get bookingRemaining => 'Remaining';

  @override
  String get bookingReadOnlyHint =>
      'Bookings are view-only here. Editing, taking payment and check-out are done on the large screen.';

  @override
  String get previousDay => 'Previous day';

  @override
  String get nextDay => 'Next day';

  @override
  String get copied => 'Copied';

  @override
  String get periodToday => 'Today';

  @override
  String get periodYesterday => 'Yesterday';

  @override
  String get periodLast7 => '7 days';

  @override
  String get periodThisMonth => 'This month';

  @override
  String get reportNet => 'Net result';

  @override
  String reportNetBreakdown(String income, String expense) {
    return 'Income $income − expenses $expense';
  }

  @override
  String get reportCollected => 'Money collected';

  @override
  String reportCash(String amount) {
    return 'Cash: $amount';
  }

  @override
  String get reportBookings => 'My bookings';

  @override
  String reportCancelled(int count) {
    return '$count cancelled';
  }

  @override
  String get reportShop => 'Shop sales';

  @override
  String reportShopCount(int count) {
    return '$count sales';
  }

  @override
  String get reportExpenses => 'My expenses';

  @override
  String reportExpenseCount(int count) {
    return '$count entries';
  }

  @override
  String get reportRefunds => 'Refunded';

  @override
  String get reportRefundsHint => 'already deducted';

  @override
  String get reportShopUnpaid => 'Shop due';

  @override
  String get reportShopUnpaidHint => 'charged to bookings';

  @override
  String get reportByMethod => 'By payment method';

  @override
  String get methodCash => 'Cash';

  @override
  String get methodCard => 'Card';

  @override
  String get methodOnline => 'Online';

  @override
  String get methodBankTransfer => 'Bank transfer';

  @override
  String get methodOther => 'Other';

  @override
  String get callWatchTitle => 'Identify guests by phone call';

  @override
  String get callWatchBody =>
      'When a guest calls, their name and room appear on the desktop screen. This needs permission to read the incoming number.';

  @override
  String get callWatchEnable => 'Enable';

  @override
  String get callWatchEnabled => 'Enabled — calls now appear on the desktop';

  @override
  String callMatched(String name) {
    return '$name is calling';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String get tabHome => 'Home';

  @override
  String get tabTeam => 'Team';

  @override
  String get broadcastAction => 'Announce';

  @override
  String get pulseTitle => 'Hotel pulse';

  @override
  String get pulseLive => 'Live';

  @override
  String pulseUpdatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String pulsePartialWarning(int count) {
    return '$count sections failed to load — pull down to refresh';
  }

  @override
  String get occupancyTitle => 'Occupancy';

  @override
  String roomsOf(int busy, int total) {
    return '$busy of $total rooms occupied';
  }

  @override
  String get heroArrivals => 'Arriving';

  @override
  String get heroDepartures => 'Departing';

  @override
  String get heroInHouse => 'In-house';

  @override
  String heroOverdue(int count) {
    return '$count rooms past checkout time';
  }

  @override
  String get todayBookingsTitle => 'Today\'s bookings';

  @override
  String get financeTitle => 'Finance';

  @override
  String get financeIncome => 'Income';

  @override
  String get financeExpenses => 'Expenses';

  @override
  String get financeNet => 'Net';

  @override
  String get financeDebt => 'Outstanding';

  @override
  String financePayments(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count payments',
      one: '$count payment',
    );
    return '$_temp0';
  }

  @override
  String get financeLast7 => 'Income, last 7 days';

  @override
  String get currencySuffix => 'UZS';

  @override
  String get moneyThousand => 'K';

  @override
  String get moneyMillion => 'M';

  @override
  String get hkTitle => 'Housekeeping';

  @override
  String get taskOpen => 'Open';

  @override
  String get taskInProgress => 'In progress';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskCancelled => 'Cancelled';

  @override
  String get hkDoneToday => 'Done today';

  @override
  String hkCleaningRooms(int count) {
    return '$count rooms being cleaned';
  }

  @override
  String get attentionTitle => 'Needs attention';

  @override
  String get attentionNone => 'All clear — nothing needs attention right now';

  @override
  String attentionComplaints(int count) {
    return '$count new complaints';
  }

  @override
  String attentionFeedbackOpen(int count) {
    return '$count open requests';
  }

  @override
  String attentionDebtors(int count, String amount) {
    return '$count debtor bookings · $amount';
  }

  @override
  String attentionProblems(int count) {
    return '$count staff problems open';
  }

  @override
  String attentionHandover(int count) {
    return '$count shifts awaiting handover';
  }

  @override
  String attentionOpenTasks(int count) {
    return '$count tasks unassigned';
  }

  @override
  String teamOnDuty(int onDuty, int total) {
    return '$onDuty of $total staff on duty';
  }

  @override
  String shiftsOpen(int count) {
    return '$count open shifts';
  }

  @override
  String get roomMapTitle => 'Room map';

  @override
  String get roomStateAvailable => 'Available';

  @override
  String get roomStateOccupied => 'Occupied';

  @override
  String get roomStateReserved => 'Reserved';

  @override
  String get roomStateCleaning => 'Cleaning';

  @override
  String get roomStateMaintenance => 'Maintenance';

  @override
  String get roomStateInspection => 'Inspection';

  @override
  String get roomStateOutOfService => 'Out of service';

  @override
  String get roomStateUnknown => 'Unknown';

  @override
  String floorLabel(int number) {
    return 'Floor $number';
  }

  @override
  String get floorOther => 'Other rooms';

  @override
  String get roomsEmptyTitle => 'No rooms found';

  @override
  String get roomsEmptyBody => 'There are no rooms in this state';

  @override
  String roomSinceLabel(String duration) {
    return 'for $duration';
  }

  @override
  String roomCapacity(int count) {
    return '$count guests';
  }

  @override
  String get roomPrice => 'Price';

  @override
  String get roomGuestTitle => 'Guest';

  @override
  String get roomNoStay => 'No active stay';

  @override
  String roomCompanions(String names) {
    return 'Companions: $names';
  }

  @override
  String get roomChangeStatus => 'Change status';

  @override
  String get roomCreateTask => 'Create task';

  @override
  String get roomStatusChanged => 'Room status updated';

  @override
  String get roomStatusBusyHint =>
      'Occupied and reserved states come from bookings — check the guest in or out';

  @override
  String get notesLabel => 'Note';

  @override
  String get hourShort => 'h';

  @override
  String get minuteShort => 'min';

  @override
  String taskCreateTitle(String room) {
    return 'New task · $room';
  }

  @override
  String get taskTypeLabel => 'Task type';

  @override
  String get taskTypeCleaning => 'Cleaning';

  @override
  String get taskTypeDeepCleaning => 'Deep cleaning';

  @override
  String get taskTypeMaintenance => 'Maintenance';

  @override
  String get taskTypeInspection => 'Inspection';

  @override
  String get taskTypeTurnDown => 'Turn-down';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get priorityLow => 'Low';

  @override
  String get priorityMedium => 'Medium';

  @override
  String get priorityHigh => 'High';

  @override
  String get priorityUrgent => 'Urgent';

  @override
  String get assigneeLabel => 'Assignee';

  @override
  String get assigneeNone => 'Automatic (by queue)';

  @override
  String get taskCreated => 'Task created';

  @override
  String get create => 'Create';

  @override
  String get segmentStaff => 'Staff';

  @override
  String get segmentShifts => 'Shifts';

  @override
  String get segmentTasks => 'Tasks';

  @override
  String get segmentProblems => 'Problems';

  @override
  String get staffSearchHint => 'Name, login or phone';

  @override
  String get staffOnDutyBadge => 'On duty';

  @override
  String get staffOffDuty => 'Off duty';

  @override
  String get staffOnline => 'Online now';

  @override
  String get staffStatusInactive => 'Inactive';

  @override
  String get staffStatusTerminated => 'Terminated';

  @override
  String get staffLastLoginLabel => 'Last login';

  @override
  String get staffNeverLoggedIn => 'Never logged in';

  @override
  String get staffEmptyTitle => 'No staff found';

  @override
  String get staffEmptyBody => 'Nobody matches the search';

  @override
  String get shiftsNotCashTitle => 'Cash mode is off';

  @override
  String get shiftsNotCashBody =>
      'Shift sessions are tracked when the cash mode is enabled in settings';

  @override
  String get shiftsOpenTitle => 'Open shifts';

  @override
  String get shiftsClosedTitle => 'Closed shifts';

  @override
  String get shiftsEmpty => 'No shifts yet';

  @override
  String get shiftActive => 'Active';

  @override
  String get shiftPendingHandover => 'Awaiting handover';

  @override
  String get shiftForceClosed => 'Force-closed';

  @override
  String shiftStarted(String time) {
    return 'Started $time';
  }

  @override
  String get shiftDurationLabel => 'Duration';

  @override
  String get shiftOpeningCash => 'Opening cash';

  @override
  String get shiftCounted => 'Counted';

  @override
  String get shiftDiff => 'Difference';

  @override
  String get shiftForceClose => 'Force close';

  @override
  String shiftForceCloseBody(String name) {
    return '$name\'s shift will be closed. Without a counted amount it closes at the expected cash.';
  }

  @override
  String get shiftCountedCashLabel => 'Counted cash (optional)';

  @override
  String get shiftHandOver => 'Hand the cash over to the next employee';

  @override
  String get shiftHandOverHint =>
      'If off, the admin takes the cash and the session closes completely';

  @override
  String get shiftForceClosedDone => 'Shift closed';

  @override
  String get tasksEmptyTitle => 'No tasks';

  @override
  String get tasksEmptyBody => 'You can create a task from the room map';

  @override
  String get taskAssign => 'Assign';

  @override
  String get taskReassign => 'Reassign';

  @override
  String get taskUnassigned => 'Unassigned';

  @override
  String get taskAssigned => 'Task assigned';

  @override
  String get taskComplete => 'Complete';

  @override
  String get taskCancelAction => 'Cancel task';

  @override
  String get taskCompleteConfirm =>
      'Mark the task as completed? For cleaning tasks the room becomes available.';

  @override
  String get taskCancelConfirm => 'Cancel this task?';

  @override
  String taskWaiting(String duration) {
    return 'waiting $duration';
  }

  @override
  String taskWorking(String duration) {
    return 'in work for $duration';
  }

  @override
  String taskChecklist(int done, int total) {
    return '$done/$total items';
  }

  @override
  String get taskChecklistLabel => 'Checklist';

  @override
  String get taskAutoCompleted => 'Auto-completed';

  @override
  String get taskCreatedAt => 'Created';

  @override
  String get taskStartedAt => 'Started';

  @override
  String get assignSheetTitle => 'Assign to whom?';

  @override
  String get problemsEmptyTitle => 'No problems';

  @override
  String get problemsEmptyBody => 'Problems reported by staff appear here';

  @override
  String get problemOpen => 'Open';

  @override
  String get problemResolved => 'Resolved';

  @override
  String get problemTake => 'Take';

  @override
  String get problemResolve => 'Mark resolved';

  @override
  String problemReportedBy(String name) {
    return 'Reported by $name';
  }

  @override
  String get problemResolvedTitle => 'Resolved';

  @override
  String get feedbackTitle => 'Guest feedback';

  @override
  String get feedbackRequest => 'Request';

  @override
  String get feedbackSuggestion => 'Suggestion';

  @override
  String get feedbackComplaint => 'Complaint';

  @override
  String get feedbackNew => 'New';

  @override
  String get feedbackInProgress => 'In progress';

  @override
  String get feedbackResolved => 'Resolved';

  @override
  String get feedbackRejected => 'Rejected';

  @override
  String get feedbackFilterOpen => 'Open';

  @override
  String get feedbackFilterComplaints => 'Complaints';

  @override
  String get feedbackFilterResolved => 'Closed';

  @override
  String get feedbackEmptyTitle => 'No feedback';

  @override
  String get feedbackEmptyBody => 'Guest feedback is entered by the reception';

  @override
  String get feedbackResolveAction => 'Resolve';

  @override
  String get feedbackRejectAction => 'Reject';

  @override
  String get feedbackReopen => 'Reopen';

  @override
  String get feedbackResolutionLabel => 'Resolution';

  @override
  String get feedbackResolutionRequired =>
      'A resolution note is required to close';

  @override
  String feedbackRoom(String number) {
    return 'Room $number';
  }

  @override
  String feedbackAssigned(String name) {
    return 'Assignee: $name';
  }

  @override
  String get feedbackStatusUpdated => 'Feedback status updated';

  @override
  String get broadcastTitle => 'Announcement to all staff';

  @override
  String get broadcastBody =>
      'Sent as a push notification to every active employee';

  @override
  String get broadcastTitleHint => 'Title';

  @override
  String get broadcastMessageHint => 'Message (optional)';

  @override
  String broadcastSent(int count) {
    return 'Announcement sent to $count devices';
  }

  @override
  String roomStayNights(int done, int total) {
    return 'Night $done of $total';
  }

  @override
  String get roomActionsTitle => 'Actions';

  @override
  String get broadcastPreview => 'How it looks on a staff phone';

  @override
  String get broadcastNow => 'now';

  @override
  String broadcastRecipients(int count) {
    return 'Goes to $count active employees';
  }

  @override
  String get broadcastQuick => 'Quick texts';

  @override
  String get broadcastQuick1 => 'Meeting in 10 minutes';

  @override
  String get broadcastQuick2 => 'Don\'t forget the shift handover';

  @override
  String get broadcastQuick3 => 'Pay extra attention to cleanliness';

  @override
  String get broadcastTitlePlaceholder => 'Announcement title';

  @override
  String get broadcastBodyPlaceholder => 'The message text appears here';

  @override
  String get teamOnDutyNow => 'On duty now';

  @override
  String get teamNobodyOnDuty => 'Nobody is on duty right now';

  @override
  String staffActiveTasks(int count) {
    return '$count active tasks';
  }

  @override
  String get staffNoTasks => 'No active tasks';

  @override
  String get taskStepAssigned => 'Assigned';

  @override
  String get taskTimelineTitle => 'Progress';

  @override
  String get taskNotStarted => 'Not started yet';

  @override
  String get shiftSummaryTitle => 'Shift';

  @override
  String get assigneeAuto => 'Auto';

  @override
  String get roomsFreeNow => 'Free now';

  @override
  String get stayCheckIn => 'Check-in';

  @override
  String get stayCheckOut => 'Check-out';

  @override
  String get roleConfigurator => 'Configurator';

  @override
  String get configuratorTitle => 'Configurator account';

  @override
  String get configuratorBody =>
      'Hotels are configured in the web app. Sign in to GoHotel on a computer with this username, choose a hotel and branch — all its sections and settings will then be open to you.';

  @override
  String get configuratorHint => 'The mobile app is meant for hotel staff.';

  @override
  String get financeDetails => 'Details';

  @override
  String get periodCustom => 'Custom';

  @override
  String get financePickRange => 'Choose a period';

  @override
  String get financeRevenue => 'Total revenue';

  @override
  String financeRevenueParts(String bookings, String shop) {
    return 'Bookings: $bookings · Shop: $shop';
  }

  @override
  String financeAvgPayment(String amount) {
    return 'average payment $amount';
  }

  @override
  String get financeVsPrevious => 'vs previous period';

  @override
  String get financeNoPrevious => 'no revenue in the previous period';

  @override
  String get financeInvoices => 'Invoices';

  @override
  String financeInvoicesValue(int count, String amount) {
    return '$count · $amount';
  }

  @override
  String get financeDiscounts => 'Discounts';

  @override
  String get cashNowTitle => 'Cash on hand now';

  @override
  String get cashNowHint => 'Cash that should be in the open drawers right now';

  @override
  String cashDrawersCount(int active, int pending) {
    return 'Open: $active · handing over: $pending';
  }

  @override
  String get cashNoOpen => 'No open cash drawers right now';

  @override
  String get cashSimpleMode =>
      'Cash shifts are not used — cash movement for the period is below';

  @override
  String cashBreakdown(
    String opening,
    String payments,
    String shop,
    String expenses,
  ) {
    return 'Opening $opening + payments $payments + shop $shop − expenses $expenses';
  }

  @override
  String cashCounted(String amount) {
    return 'Counted at handover: $amount';
  }

  @override
  String get cashFlowTitle => 'Cash movement';

  @override
  String get cashIn => 'In';

  @override
  String get cashOut => 'Out';

  @override
  String get cashBalance => 'Balance';

  @override
  String get chartDaily => 'Daily revenue and expenses';

  @override
  String get chartWeekly => 'Weekly revenue and expenses';

  @override
  String chartBest(String day, String amount) {
    return 'Best: $day — $amount';
  }

  @override
  String chartAverage(String amount) {
    return 'Daily average $amount';
  }

  @override
  String get expenseCategoriesTitle => 'Expenses by category';

  @override
  String get expensesNone => 'No expenses in this period';

  @override
  String get debtorsTitle => 'Debtors';

  @override
  String debtorsSummary(int count, String amount) {
    return '$count bookings · total $amount';
  }

  @override
  String get debtorsNone => 'No debtors';

  @override
  String debtorsMore(int count) {
    return '$count more';
  }

  @override
  String debtorRoom(String room) {
    return 'Room $room';
  }

  @override
  String debtorCheckOut(String date) {
    return 'check-out $date';
  }

  @override
  String get shiftsCashTitle => 'Shift cash';

  @override
  String shiftsClosedCount(int count) {
    return 'Shifts closed: $count';
  }

  @override
  String get shiftsShortage => 'Shortage';

  @override
  String get shiftsSurplus => 'Surplus';

  @override
  String get shiftsNoneClosed => 'No shifts closed in this period';

  @override
  String get financeGuestUnknown => 'Guest';

  @override
  String get financePenalties => 'Penalties';

  @override
  String financePenaltiesValue(int count, String amount) {
    return '$count · $amount';
  }

  @override
  String get financePenaltiesHint =>
      'For late check-out and damage — added to the booking debt';

  @override
  String get staffRevenueTitle => 'Revenue by staff';

  @override
  String get staffRevenueHint => 'Who took how much: booking payments and shop';

  @override
  String get staffRevenueNone => 'No money was taken by staff in this period';

  @override
  String staffRevenueShare(String percent) {
    return '$percent of total revenue';
  }

  @override
  String staffRevenueShowAll(int count) {
    return 'Show all ($count)';
  }

  @override
  String get staffRevenueShowLess => 'Show less';

  @override
  String get staffUnknown => 'Unknown staff member';

  @override
  String get staffInactive => 'Inactive';

  @override
  String get staffBookings => 'Booking payments';

  @override
  String get staffCashTitle => 'Cash';

  @override
  String staffCounts(int payments, int sales, int expenses) {
    return '$payments payments · $sales sales · $expenses expenses';
  }

  @override
  String get staffCashIn => 'Cash taken';

  @override
  String get staffCashOut => 'Cash expenses';

  @override
  String get staffCashNet => 'Balance';

  @override
  String staffShopShort(String amount) {
    return 'shop $amount';
  }

  @override
  String get handoversTitle => 'Cash passed between shifts';

  @override
  String get handoversHint =>
      'Every handed-over drawer: from whom to whom, the counted amount and the difference';

  @override
  String get handoversPassed => 'To next shift';

  @override
  String get handoversTakenOut => 'Taken out';

  @override
  String get handoversPending => 'Awaiting';

  @override
  String handoversMore(int count) {
    return '$count more — the full list is on the Shifts page on the web';
  }

  @override
  String get handoverKindPending => 'Awaiting acceptance';

  @override
  String get handoverKindCashOut => 'Taken out (day close)';

  @override
  String get handoverKindForceTaken => 'Force-closed — taken by manager';

  @override
  String handoverAccepted(String time) {
    return 'accepted: $time';
  }

  @override
  String get handoverCorrected => 'Corrected';

  @override
  String handoverReceivedOpening(String amount) {
    return 'The receiver started with $amount';
  }

  @override
  String handoverExpected(String amount) {
    return 'expected $amount';
  }

  @override
  String get debtWhy => 'Why';

  @override
  String debtReasonRoom(String room) {
    return 'Accommodation (room $room)';
  }

  @override
  String get debtReasonRoomPlain => 'Accommodation';

  @override
  String get debtReasonExtension => 'Recalculated at check-out (extension)';

  @override
  String debtReasonService(String name) {
    return 'Service: $name';
  }

  @override
  String get debtReasonPenalty => 'Penalty';

  @override
  String debtReasonPenaltyWith(String details) {
    return 'Penalty ($details)';
  }

  @override
  String debtReasonShop(String products) {
    return 'Shop: $products';
  }

  @override
  String get debtReasonShopPlain => 'Shop';

  @override
  String get debtPenaltyLate => 'late check-out';

  @override
  String get debtPenaltyDamage => 'damage';

  @override
  String get debtPenaltyOther => 'other';

  @override
  String debtAcknowledged(String note) {
    return 'Checked out with debt: $note';
  }

  @override
  String debtOverdueDays(int days) {
    return 'for $days days';
  }

  @override
  String get debtLeftWithDebt => 'The guest left with a debt';

  @override
  String get debtTakeBeforeLeave => 'Take the payment before the guest leaves';
}
