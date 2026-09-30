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
}
