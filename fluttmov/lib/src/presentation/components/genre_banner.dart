import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/image_url_builder.dart';
import 'movie_image.dart';

class GenreBanner extends StatelessWidget {
  const GenreBanner({
    super.key,
    required this.genreName,
    required this.imageUrl,
  });

  final String genreName;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MovieImage(imageUrl: ImageUrlBuilder.backdrop(imageUrl)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.0),
                AppColors.background.withValues(alpha: 0.6),
                AppColors.background,
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Text(
              genreName,
              textAlign: TextAlign.center,
              style: AppTypography.headlineLg.copyWith(
                shadows: const [
                  Shadow(blurRadius: 10, color: Colors.black54),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
