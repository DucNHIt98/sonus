import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedArtwork extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? fallback;

  const CachedArtwork({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final fallbackWidget =
        fallback ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[850],
          child: const Icon(Icons.music_note, color: Colors.white54),
        );

    if (imageUrl.isEmpty) return fallbackWidget;

    return CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: Duration.zero,
      fadeOutDuration: Duration.zero,
      memCacheWidth: width == null
          ? null
          : (width! * MediaQuery.devicePixelRatioOf(context)).round(),
      memCacheHeight: height == null
          ? null
          : (height! * MediaQuery.devicePixelRatioOf(context)).round(),
      placeholder: (_, __) => fallbackWidget,
      errorWidget: (_, __, ___) => fallbackWidget,
    );
  }
}
