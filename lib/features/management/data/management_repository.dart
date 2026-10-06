import '../../../core/network/api_client.dart';
import '../domain/finance_report.dart';
import '../domain/finance_summary.dart';
import '../domain/format.dart';
import '../domain/guest_feedback.dart';
import '../domain/hk_task.dart';
import '../domain/room_tile.dart';
import '../domain/shift_handover.dart';
import '../domain/shift_session.dart';
import '../domain/staff_member.dart';
import '../domain/staff_revenue.dart';

/// Boshqaruv (admin/menejer) so'rovlari — bitta joyda.
///
/// Hammasi mavjud veb-API'lar: mobil uchun alohida endpoint yaratilmagan,
/// shuning uchun veb va telefon bir xil raqamlarni ko'rsatadi. Har metod
/// bitta endpoint — yig'ma hisoblar cubit'da.
class ManagementRepository {
  ManagementRepository(this._api);

  final ApiClient _api;

  // --- Xonalar ------------------------------------------------------------

  Future<List<RoomTile>> getRooms() async {
    final data = await _api.get<List<dynamic>>(
      '/rooms/',
      query: {'limit': 500},
    );
    return data
        .map((e) => RoomTile.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FloorInfo>> getFloors() async {
    final data = await _api.get<List<dynamic>>('/floors/');
    return data
        .map((e) => FloorInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Xona holatini qo'lda o'rnatish (`room.update` ruxsati).
  Future<RoomTile> setRoomStatus(
    String roomId,
    RoomState state, {
    String? notes,
  }) async {
    final data = await _api.patch<Map<String, dynamic>>(
      '/rooms/$roomId/status',
      data: {'status': state.api, 'notes': ?_trimmed(notes)},
    );
    return RoomTile.fromJson(data);
  }

  Future<List<RoomStay>> getRoomStays(String roomId) async {
    final data = await _api.get<List<dynamic>>('/rooms/$roomId/reservations');
    return data
        .map((e) => RoomStay.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- Moliya -------------------------------------------------------------

  Future<FinanceSummary> getFinanceSummary({
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/finance/summary',
      query: {'date_from': isoDate(from), 'date_to': isoDate(to)},
    );
    return FinanceSummary.fromJson(data);
  }

  /// Davr tushumi xodimlar kesimida (`/finance/by-staff`). Ruxsat — admin
  /// yoki moliya/kassa nazorati kodi; bo'lmasa server 403 qaytaradi.
  Future<StaffRevenueReport> getFinanceByStaff({
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/finance/by-staff',
      query: {'date_from': isoDate(from), 'date_to': isoDate(to)},
    );
    return StaffRevenueReport.fromJson(data);
  }

  /// Oxirgi [days] kunning har biri uchun tushum — chiziq uchun.
  ///
  /// Kunlar parallel so'raladi: serverda bu yig'ma so'rov arzon, ketma-ket
  /// kutilsa esa 7 marta tarmoq kechikishi yig'ilardi.
  Future<List<IncomeDay>> getIncomeDays(DateTime today, {int days = 7}) async {
    final dates = [
      for (var i = days - 1; i >= 0; i--)
        DateTime(today.year, today.month, today.day - i),
    ];
    final summaries = await Future.wait([
      for (final d in dates) getFinanceSummary(from: d, to: d),
    ]);
    return [
      for (var i = 0; i < dates.length; i++)
        IncomeDay(date: dates[i], income: summaries[i].income),
    ];
  }

  /// Davrning har kuni bo'yicha tushum, xarajat va do'kon — BITTA so'rovda
  /// (`/finance/daily`, server kun ta'rifi yig'ma bilan bir xil).
  Future<List<FinanceDay>> getFinanceDaily({
    required DateTime from,
    required DateTime to,
  }) async {
    final data = await _api.get<List<dynamic>>(
      '/finance/daily',
      query: {'date_from': isoDate(from), 'date_to': isoDate(to)},
    );
    return [
      for (final d in data)
        if (d is Map<String, dynamic>) FinanceDay.fromJson(d),
    ];
  }

  /// Hozir ochiq kassalarda qancha pul bo'lishi kerak (admin/menejer).
  Future<CashOverview> getCashOverview() async {
    final data = await _api.get<Map<String, dynamic>>('/shifts/cash-overview');
    return CashOverview.fromJson(data);
  }

  /// Qarzdor bronlar ro'yxati va jamlanmasi.
  Future<DebtorsReport> getDebtorsReport() async {
    final data = await _api.get<Map<String, dynamic>>('/finance/debtors');
    return DebtorsReport.fromJson(data);
  }

  /// Qarzdorlar yig'masi: (soni, jami qarz).
  Future<(int, double)> getDebtors() async {
    final data = await _api.get<Map<String, dynamic>>('/finance/debtors');
    final summary = data['summary'] as Map<String, dynamic>? ?? const {};
    return (
      (summary['count'] as num?)?.toInt() ?? 0,
      (summary['total_debt'] as num?)?.toDouble() ?? 0,
    );
  }

  // --- Xo'jalik -----------------------------------------------------------

  Future<List<HkTask>> getTasks({String? status, int limit = 200}) async {
    final data = await _api.get<List<dynamic>>(
      '/housekeeping/tasks',
      query: {'status': ?status, 'limit': limit},
    );
    return data
        .map((e) => HkTask.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<HkTask> createTask({
    required String branchId,
    required String roomId,
    required String taskType,
    String priority = 'MEDIUM',
    String? assignedTo,
    String? notes,
  }) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/housekeeping/tasks',
      data: {
        'branch_id': branchId,
        'room_id': roomId,
        'task_type': taskType,
        'priority': priority,
        'assigned_to': ?assignedTo,
        'notes': ?_trimmed(notes),
      },
    );
    return HkTask.fromJson(data);
  }

  Future<HkTask> assignTask(String taskId, String userId) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/housekeeping/tasks/$taskId/assign',
      data: {'assigned_to': userId},
    );
    return HkTask.fromJson(data);
  }

  Future<HkTask> setTaskStatus(String taskId, String status) async {
    final data = await _api.patch<Map<String, dynamic>>(
      '/housekeeping/tasks/$taskId/status',
      data: {'status': status},
    );
    return HkTask.fromJson(data);
  }

  /// Chiqish vaqti o'tgan xonalar soni (`occupied-rooms` dan).
  Future<int> getOverdueRoomCount() async {
    final data = await _api.get<List<dynamic>>(
      '/housekeeping/occupied-rooms',
      query: {'include_reserved': false},
    );
    return data
        .where((e) => (e as Map<String, dynamic>)['is_overdue'] == true)
        .length;
  }

  // --- Jamoa --------------------------------------------------------------

  /// Xodimlar ro'yxati. DIQQAT: backendda router fayli `users.py`, lekin
  /// manzili `/employees` (veb ham shuni ishlatadi) — `/users/` yo'q, 404.
  Future<List<StaffMember>> getStaff() async {
    final data = await _api.get<List<dynamic>>(
      '/employees/',
      query: {'limit': 200},
    );
    return data
        .map((e) => StaffMember.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // --- Smenalar -----------------------------------------------------------

  /// Smena rejimi: `cash` bo'lsa kassa sessiyalari yuritiladi.
  Future<String> getShiftMode() async {
    final data = await _api.get<Map<String, dynamic>>('/shifts/settings');
    return data['mode'] as String? ?? 'simple';
  }

  /// Smenadan smenaga o'tgan pullar (`/shifts/handovers`, admin yoki
  /// `shift.force_close`). Sana berilmasa — eng oxirgilari.
  Future<HandoverReport> getShiftHandovers({
    DateTime? from,
    DateTime? to,
    int limit = 30,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/shifts/handovers',
      query: {
        'date_from': ?(from == null ? null : isoDate(from)),
        'date_to': ?(to == null ? null : isoDate(to)),
        'limit': limit,
      },
    );
    return HandoverReport.fromJson(data);
  }

  Future<List<ShiftSession>> getShiftHistory({int limit = 50}) async {
    final data = await _api.get<List<dynamic>>(
      '/shifts/history',
      query: {'limit': limit},
    );
    return data
        .map((e) => ShiftSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Majburiy yopish (`shift.force_close` yoki admin). `countedCash`
  /// berilmasa kutilgan summa bo'yicha yopiladi.
  Future<void> forceCloseShift({
    required String sessionId,
    double? countedCash,
    String? notes,
    bool handOver = true,
  }) async {
    await _api.post<dynamic>(
      '/shifts/force-close',
      data: {
        'session_id': sessionId,
        'counted_cash': ?countedCash,
        'notes': ?_trimmed(notes),
        'hand_over': handOver,
      },
    );
  }

  // --- Murojaatlar --------------------------------------------------------

  Future<(List<GuestFeedback>, int)> getFeedback({
    String? status,
    String? type,
    int limit = 200,
  }) async {
    final data = await _api.get<Map<String, dynamic>>(
      '/feedback/',
      query: {'status': ?status, 'feedback_type': ?type, 'limit': limit},
    );
    final items = (data['items'] as List<dynamic>? ?? const [])
        .map((e) => GuestFeedback.fromJson(e as Map<String, dynamic>))
        .toList();
    return (items, (data['total'] as num?)?.toInt() ?? items.length);
  }

  Future<GuestFeedback> setFeedbackStatus(
    String id,
    String status, {
    String? resolution,
  }) async {
    final data = await _api.patch<Map<String, dynamic>>(
      '/feedback/$id/status',
      data: {'status': status, 'resolution': ?_trimmed(resolution)},
    );
    return GuestFeedback.fromJson(data);
  }

  // --- Xodim muammolari ---------------------------------------------------

  Future<List<StaffProblem>> getProblems({String? status, int limit = 100}) async {
    final data = await _api.get<List<dynamic>>(
      '/problems',
      query: {'status': ?status, 'limit': limit},
    );
    return data
        .map((e) => StaffProblem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> setProblemStatus(String id, String status) async {
    await _api.patch<Map<String, dynamic>>(
      '/problems/$id/status',
      data: {'status': status},
    );
  }

  // --- E'lon --------------------------------------------------------------

  /// Mehmonxonaning barcha xodimlariga push (faqat admin). Nechta
  /// qurilmaga yetib borgani qaytadi.
  Future<int> broadcast({required String title, String? body}) async {
    final data = await _api.post<Map<String, dynamic>>(
      '/notifications/broadcast',
      data: {'title': title.trim(), 'body': ?_trimmed(body)},
    );
    return (data['push_sent'] as num?)?.toInt() ?? 0;
  }

  static String? _trimmed(String? value) {
    final text = value?.trim() ?? '';
    return text.isEmpty ? null : text;
  }
}
