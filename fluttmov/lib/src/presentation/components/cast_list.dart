import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/image_url_builder.dart';
import '../../domain/entities/cast_member.dart';
import 'movie_image.dart';

class CastList extends StatelessWidget {
  const CastList({
    super.key,
    required this.castMembers,
  });

  final List<CastMember> castMembers;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: castMembers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final member = castMembers[index];
          return SizedBox(
            width: 80,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceContainerHigh),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: MovieImage(
                    imageUrl: ImageUrlBuilder.profile(member.profilePath),
                    borderRadius: 32,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  member.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelCaps,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
