import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/utils/rating_formatter.dart';

class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 16,
  });

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filledStars = RatingFormatter.toFiveStars(rating).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < filledStars ? AppIcons.star : AppIcons.starHalf,
          size: size,
          color: index < filledStars
              ? AppColors.accent
              : AppColors.textSecondary.withValues(alpha: 0.3),
        );
      }),
    );
  }
}
