import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../domain/entities/cast_member.dart';
import 'shimmer_loading.dart';

class CastList extends StatelessWidget {
  final List<CastMember> cast;

  const CastList({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMain),
        itemCount: cast.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.gutter),
        itemBuilder: (context, index) {
          final member = cast[index];
          return SizedBox(
            width: 80,
            child: Column(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: member.profileUrl != null
                        ? CachedNetworkImage(
                            imageUrl: member.profileUrl!,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const ShimmerBox(),
                            errorWidget: (_, _, _) =>
                                const _AvatarPlaceholder(),
                          )
                        : const _AvatarPlaceholder(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  member.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceHigh,
      child: Icon(
        Icons.person_outline,
        color: AppColors.textSecondary.withValues(alpha: 0.5),
      ),
    );
  }
}
