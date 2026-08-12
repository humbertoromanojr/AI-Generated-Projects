import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';

class MovieImage extends StatelessWidget {
  const MovieImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  final String? imageUrl;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: const Icon(AppIcons.movie, color: AppColors.textSecondary, size: 28),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return placeholder;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: fit,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      ),
    );
  }
}
