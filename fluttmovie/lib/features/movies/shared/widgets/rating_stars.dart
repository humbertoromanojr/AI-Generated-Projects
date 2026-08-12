import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int count;

  const RatingStars({super.key, required this.rating, this.count = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 18, color: AppColors.primary),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (count > 1) ...[
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }
}
