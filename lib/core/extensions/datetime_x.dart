extension DateTimeX on DateTime {
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  String _two(int n) => n.toString().padLeft(2, '0');

  /// "14:30" — soat:daqiqa.
  String get hhmm => '${_two(hour)}:${_two(minute)}';

  /// "Bugun 14:30" yoki "02.09, 14:30" — uch tilda ham bir xil tushunarli
  /// bo'lgan raqamli format (lokal sana-belgilariga bog'lanmaymiz).
  String shortWhen({required String todayLabel}) {
    final now = DateTime.now();
    if (isSameDay(now)) return '$todayLabel $hhmm';
    return '${_two(day)}.${_two(month)}, $hhmm';
  }
}
