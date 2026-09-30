import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data' show Uint8List;
import 'dart:ui' show Offset, Rect, Size;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;

/// Kadrni serverga yuborishdan oldin tayyorlash.
///
/// Kamera 12 MP kadr beradi, hujjat esa uning kichik bir qismini
/// egallaydi. Server rasmni 1600 px gacha kichraytiradi — to'liq kadr
/// yuborilsa, hujjat yozuvlari shu kichraytirishda mayda bo'lib, o'qish
/// aniqligi tushib ketadi. Bundan tashqari hujjat kadr maydonining
/// ~25% idan kichik bo'lsa, serverdagi perspektiv to'g'rilash (rectify)
/// umuman ishga tushmaydi.
///
/// Shuning uchun kadr ekrandagi RAMKA atrofiga qirqiladi: hujjat
/// yuborilgan rasmning asosiy qismini egallaydi, har bir belgiga
/// ikki barobargacha ko'p piksel to'g'ri keladi va to'g'rilash ham
/// ishonchli ishlaydi. Qirqish ATAYLAB mo'l chegara bilan — preview va
/// surat ko'rish maydoni bir-biridan ozgina farq qilishi mumkin, hujjat
/// chetini kesib qo'yish esa eng yomon holat.

/// Ramkaning ekrandagi joyi — kamera sahifasidagi chizma bilan BIR XIL
/// formula. Ikkalasi ajralib ketsa, qirqish chizmaga mos kelmay qoladi.
Rect frameRectFor(Size screen, double aspect) {
  final width = math.min(screen.width * 0.9, 560.0);
  final height = width / aspect;
  return Rect.fromCenter(
    center: Offset(screen.width / 2, screen.height * 0.42),
    width: width,
    height: height,
  );
}

/// Ekrandagi ramka suratning qaysi qismiga to'g'ri kelishini hisoblaydi.
///
/// Preview `BoxFit.cover` bilan ko'rsatiladi: surat ekranni to'liq
/// qoplaguncha kattalashtirilib, ortig'i kesiladi. Shu moslashtirish
/// teskarisiga qo'llanadi. Chegara mo'l qo'yiladi (eni ±16%, bo'yi ±22%).
///
/// `null` — qirqib bo'lmaydi (surat yotiq chiqqan yoki ramka suratga
/// sig'maydi): chaqiruvchi asl kadrni yuboraveradi.
Rect? cropRectFor({
  required Size screen,
  required Size image,
  required double aspect,
}) {
  if (screen.width <= 0 || screen.height <= 0) return null;
  if (image.width <= 0 || image.height <= 0) return null;
  // Ekran tik, surat yotiq — moslashtirish ishonchsiz, qirqilmaydi
  if (screen.height > screen.width && image.width > image.height) return null;

  final frame = frameRectFor(screen, aspect);
  final expanded = Rect.fromCenter(
    center: frame.center,
    width: frame.width * 1.32,
    height: frame.height * 1.44,
  );

  // BoxFit.cover: surat shu masshtabda ekranga yotqizilgan
  final scale = math.max(
    screen.width / image.width,
    screen.height / image.height,
  );
  final offsetX = (image.width - screen.width / scale) / 2;
  final offsetY = (image.height - screen.height / scale) / 2;

  final crop = Rect.fromLTRB(
    (offsetX + expanded.left / scale).clamp(0.0, image.width),
    (offsetY + expanded.top / scale).clamp(0.0, image.height),
    (offsetX + expanded.right / scale).clamp(0.0, image.width),
    (offsetY + expanded.bottom / scale).clamp(0.0, image.height),
  );

  // Qirqim juda kichik bo'lib qolsa — nimadir noto'g'ri, asl kadr afzal
  if (crop.width < image.width * 0.3 || crop.height < 60) return null;
  return crop;
}

/// Qirqilgan hujjat suratining chegaraviy kengligi: serverdagi 1600 px
/// chegarasidan biroz katta — kichraytirishda sifat yo'qolmaydi, yuklash
/// esa 6-8 MB o'rniga bir necha yuz KB bo'ladi.
const int _maxUploadWidth = 2000;

class _PrepareRequest {
  const _PrepareRequest(this.path, this.screen, this.aspect);

  final String path;
  final Size screen;
  final double aspect;
}

/// Kadrni ramka atrofiga qirqib, yuborishga tayyor faylga yozadi.
///
/// Har qanday muammoda ASL yo'l qaytariladi: sifatni oshirish yo'lida
/// skanerni ishlamay qo'yishga arzimaydi — server to'liq kadrni ham
/// o'qiy oladi, shunchaki pastroq aniqlikda.
Future<String> prepareDocumentImage(
  String path, {
  required Size screen,
  required double aspect,
}) async {
  try {
    return await compute(_prepare, _PrepareRequest(path, screen, aspect));
  } catch (_) {
    return path;
  }
}

Future<String> _prepare(_PrepareRequest request) async {
  final bytes = File(request.path).readAsBytesSync();

  /* Avval platformaning o'z dekoderi (libjpeg-turbo): sof Dart'dagi
     dekoder to'liq kadr uchun sekin protsessorda soniyalab vaqt olardi —
     xodim shuncha vaqt spinnerga qarab turardi. Ishlamay qolsa (eski
     Flutter/qurilma) sinalgan sof Dart yo'liga jim qaytiladi. */
  try {
    final quick = await _decodeNative(bytes);
    if (quick != null) return _cropAndSave(quick, request);
  } catch (_) {
    // Fon izolatida platforma dekoderi mavjud emas — pastdagi yo'l.
  }

  // Kamera har doim JPEG beradi — format aniqlab o'tirilmaydi
  final decoded = img.decodeJpg(bytes) ?? img.decodeImage(bytes);
  if (decoded == null) return request.path;
  return _cropAndSave(_oriented(decoded), request);
}

/// JPEG'ni platforma dekoderi bilan ochadi. dart:ui EXIF yo'nalishini
/// dekodlashda O'ZI qo'llaydi — natija xuddi `bakeOrientation`dan
/// keyingidek: eni/bo'yi allaqachon to'g'ri.
Future<img.Image?> _decodeNative(Uint8List bytes) async {
  final buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ui.ImageDescriptor.encoded(buffer);
  final codec = await descriptor.instantiateCodec();
  final frame = await codec.getNextFrame();
  final image = frame.image;
  try {
    final data = await image.toByteData(
      format: ui.ImageByteFormat.rawStraightRgba,
    );
    if (data == null) return null;
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: data.buffer,
      order: img.ChannelOrder.rgba,
    );
  } finally {
    image.dispose();
    codec.dispose();
    descriptor.dispose();
    buffer.dispose();
  }
}

/// EXIF yo'nalishini qo'llash — sof Dart yo'lida.
///
/// `bakeOrientation` yo'nalish YO'Q bo'lganda ham butun kadrni nusxalab
/// olardi — bo'sh joyga o'nlab MB. Shart kutubxonanikining o'zi.
img.Image _oriented(img.Image decoded) {
  final ifd = decoded.exif.imageIfd;
  if (!ifd.hasOrientation || ifd.orientation == 1) return decoded;
  return img.bakeOrientation(decoded);
}

String _cropAndSave(img.Image oriented, _PrepareRequest request) {
  final crop = cropRectFor(
    screen: request.screen,
    image: Size(oriented.width.toDouble(), oriented.height.toDouble()),
    aspect: request.aspect,
  );

  img.Image result;
  if (crop == null) {
    /* Moslashtirib bo'lmadi. Ilgari ASL kadr yuborilardi — 6-8 MB fayl
       mehmonxona Wi-Fi'sida "o'qilmoqda" oynasini daqiqagacha ushlab
       turardi. Server baribir 1600 px'da o'qiydi: qirqmasdan, faqat
       kichraytirib yuborishning o'zi yetarli. */
    result = oriented;
  } else {
    result = img.copyCrop(
      oriented,
      x: crop.left.round(),
      y: crop.top.round(),
      width: crop.width.round(),
      height: crop.height.round(),
    );
  }
  if (result.width > _maxUploadWidth) {
    // Kichraytirishda chiziqli interpolatsiya yetarli: 2000 px'da harf
    // qirralari baribir tekis chiqadi, kubik esa sof Dart'da bir necha
    // barobar sekin ishlardi
    result = img.copyResize(
      result,
      width: _maxUploadWidth,
      interpolation: img.Interpolation.linear,
    );
  }
  if (result.numChannels != 3) {
    // Platforma dekoderi RGBA beradi — JPEG alfasiz, 3 kanalga o'tkaziladi.
    result = result.convert(numChannels: 3);
  }

  final output = '${request.path}_doc.jpg';
  File(output).writeAsBytesSync(img.encodeJpg(result, quality: 92));
  return output;
}
