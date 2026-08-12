import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_theme.dart';

class ShimmerBox extends StatelessWidget {
  final BorderRadius? radius;

  const ShimmerBox({super.key, this.radius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceHigh,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: radius ?? BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.marginMain),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.stackMd,
        crossAxisSpacing: AppSpacing.gutter,
        childAspectRatio: 0.58,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(child: ShimmerBox(radius: BorderRadius.all(Radius.circular(16)))),
          SizedBox(height: 8),
          ShimmerBox(radius: BorderRadius.all(Radius.circular(4))),
          SizedBox(height: 6),
          ShimmerBox(radius: BorderRadius.all(Radius.circular(4))),
        ],
      ),
    );
  }
}
