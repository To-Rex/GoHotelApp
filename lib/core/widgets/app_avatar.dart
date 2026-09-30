import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../extensions/context_x.dart';

/// Xodim avatari: rasm bo'lsa rasm, bo'lmasa ism bosh harflari.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.headers,
    this.size = 48,
  });

  final String name;
  final String? imageUrl;
  final Map<String, String>? headers;
  final double size;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c.brandSoft, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: c.onBrandSoft,
        ),
      ),
    );

    if (imageUrl == null || imageUrl!.isEmpty) return fallback;

    // Kameradan chiqqan surat 3000×4000 px bo'ladi; kichik doira uchun
    // uni to'liq dekodlash sekin va xotirani behuda yeydi — dekod
    // o'lchami ekrandagi o'lchamga bog'lanadi.
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        httpHeaders: headers,
        width: size,
        height: size,
        memCacheWidth: (size * dpr).round(),
        fit: BoxFit.cover,
        placeholder: (_, _) => fallback,
        errorWidget: (_, _, _) => fallback,
      ),
    );
  }
}
