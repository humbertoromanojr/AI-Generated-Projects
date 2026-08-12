import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceElevated,
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
  });

  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class CarouselSkeleton extends StatelessWidget {
  const CarouselSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerLoading(
      child: SkeletonBox(height: 400, borderRadius: 16),
    );
  }
}

class MovieGridSkeleton extends StatelessWidget {
  const MovieGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.62,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: SkeletonBox(borderRadius: 16)),
            SizedBox(height: 10),
            SkeletonBox(width: double.infinity, height: 14),
            SizedBox(height: 6),
            SkeletonBox(width: 60, height: 12),
          ],
        ),
      ),
    );
  }
}

class MovieListSkeleton extends StatelessWidget {
  const MovieListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const SkeletonBox(width: 100, height: 150, borderRadius: 8),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBox(width: 140, height: 18),
                      SizedBox(height: 10),
                      SkeletonBox(width: double.infinity, height: 14),
                      SizedBox(height: 6),
                      SkeletonBox(width: 200, height: 14),
                      SizedBox(height: 16),
                      SkeletonBox(width: 70, height: 24, borderRadius: 9999),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(height: 320, borderRadius: 0),
          const SizedBox(height: 24),
          const SkeletonBox(width: 220, height: 28),
          const SizedBox(height: 12),
          const SkeletonBox(width: 160, height: 16),
          const SizedBox(height: 32),
          const SkeletonBox(width: 120, height: 20),
          const SizedBox(height: 12),
          const SkeletonBox(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const SkeletonBox(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          const SkeletonBox(width: 240, height: 14),
          const SizedBox(height: 32),
          Row(
            children: List.generate(
              4,
              (_) => Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: const [
                    SkeletonBox(width: 64, height: 64, borderRadius: 32),
                    SizedBox(height: 8),
                    SkeletonBox(width: 64, height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
