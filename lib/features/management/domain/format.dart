/// Boshqaruv ekranlari uchun raqam va vaqt formatlari.
///
/// Uchala tilda ham bir xil o'qiladigan RAQAMLI shakllar — lokal
/// sana-belgilariga bog'lanmaymiz (farrosh moduli bilan bir xil yondashuv).
library;

/// Ming ajratgichi bilan: 1 250 000. Manfiy bo'lsa oldiga "-".
String formatMoney(num value) {
  final negative = value < 0;
  final text = value
      .abs()
      .round()
      .toString()
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
  return negative ? '-$text' : text;
}

/// Katta summalar qisqa: 1,2 mln · 850 ming · 12 500.
///
/// Sarlavha raqamlari uchun — to'liq raqam yoniga sig'maydi, lekin
/// miqyosi bir qarashda bilinishi kerak.
String compactMoney(num value, {required String thousand, required String million}) {
  final abs = value.abs();
  String body;
  if (abs >= 1000000) {
    final v = abs / 1000000;
    body = '${_trim(v)} $million';
  } else if (abs >= 100000) {
    body = '${(abs / 1000).round()} $thousand';
  } else {
    body = formatMoney(abs);
  }
  return value < 0 ? '-$body' : body;
}

String _trim(double v) {
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s.replaceAll('.', ',');
}

/// "1 s 20 d" / "35 d" — davomiylik.
String formatDuration(Duration d, {required String h, required String m}) {
  final hours = d.inHours;
  final minutes = d.inMinutes % 60;
  if (hours <= 0) return '$minutes $m';
  return '$hours $h $minutes $m';
}

/// Foiz (0..1) → "72%".
String formatPercent(double ratio) => '${(ratio * 100).round()}%';

/// "14:30" yoki "02.09, 14:30" (bugun bo'lmasa).
String formatWhen(DateTime value, DateTime now) {
  String two(int n) => n.toString().padLeft(2, '0');
  final hhmm = '${two(value.hour)}:${two(value.minute)}';
  final sameDay =
      value.year == now.year && value.month == now.month && value.day == now.day;
  return sameDay ? hhmm : '${two(value.day)}.${two(value.month)}, $hhmm';
}

/// "dd.MM" — chiziq ostidagi kun belgilari uchun.
String shortDay(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}.${two(value.month)}';
}

/// Sana MAHALLIY zonada `yyyy-MM-dd` — backend query uchun.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
