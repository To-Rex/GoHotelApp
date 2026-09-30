/// Serverdan qaytgan skaner natijasi.
///
/// Telefonda hech narsa o'qilmaydi — rasm serverga yuboriladi, u yerdagi
/// dvigatel MRZ va bosma maydonlarni ajratadi. Bu yerda faqat natijani
/// KO'RSATISH uchun kerak bo'lgan qismi turadi: to'liq maydonlar veb
/// ekranidagi bandlov oynasiga boradi.
class ScannedDocument {
  const ScannedDocument({
    required this.id,
    required this.documentType,
    required this.matched,
    required this.verified,
    this.documentNumber,
    this.fullName,
    this.guestName,
  });

  final String id;

  /// `ID_CARD` yoki `PASSPORT`.
  final String documentType;

  /// Hujjat raqami bo'yicha mehmon bazadan topildimi.
  ///
  /// Topilsa qabulxona oynasida u tanlangan holda ochiladi; topilmasa
  /// yangi mijoz maydonlari to'ldiriladi.
  final bool matched;

  /// Skaner o'qishni to'liq tasdiqladimi (MRZ nazorat raqamlari).
  final bool verified;

  final String? documentNumber;

  /// Hujjatdagi ism (topilmagan mehmon uchun ham bo'ladi).
  final String? fullName;

  /// Bazadagi mehmon ismi — topilgan bo'lsa.
  final String? guestName;

  /// Ekranda ko'rsatiladigan ism.
  String get displayName => guestName ?? fullName ?? '';

  factory ScannedDocument.fromJson(Map<String, dynamic> json) {
    return ScannedDocument(
      id: json['id'] as String? ?? '',
      documentType: json['document_type'] as String? ?? 'PASSPORT',
      matched: json['matched'] as bool? ?? false,
      verified: json['verified'] as bool? ?? false,
      documentNumber: json['document_number'] as String?,
      fullName: json['full_name'] as String?,
      guestName: json['guest_name'] as String?,
    );
  }
}
