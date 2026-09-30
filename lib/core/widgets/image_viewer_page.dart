import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// To'liq ekranli rasm ko'rish: kattalashtirish (pinch-zoom) bilan.
class ImageViewerPage extends StatelessWidget {
  const ImageViewerPage({super.key, required this.imageUrl, this.headers});

  final String imageUrl;
  final Map<String, String>? headers;

  static Future<void> open(
    BuildContext context, {
    required String imageUrl,
    Map<String, String>? headers,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageViewerPage(imageUrl: imageUrl, headers: headers),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          maxScale: 5,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            httpHeaders: headers,
            fit: BoxFit.contain,
            placeholder: (_, _) =>
                const CircularProgressIndicator(color: Colors.white),
            errorWidget: (_, _, _) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.white54,
              size: 64,
            ),
          ),
        ),
      ),
    );
  }
}
