import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Title;

import 'package:animewhere/app/theme/app_theme.dart';
import 'package:animewhere/app/theme/app_text_theme.dart';
import 'package:animewhere/core/models/title.dart';

class TitleCard extends StatelessWidget {
  const TitleCard({
    super.key,
    required this.title,
    required this.onTap,
    this.onShare,
    this.width = 140,
  });

  final Title title;
  final VoidCallback onTap;
  final VoidCallback? onShare;
  final double width;

  @override
  Widget build(BuildContext context) {
    final posterHeight = width * 3 / 2;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                  child: CachedNetworkImage(
                    imageUrl: title.imageUrl,
                    width: width,
                    height: posterHeight,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: width,
                      height: posterHeight,
                      color: AppTheme.surfaceContainerHigh,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: width,
                      height: posterHeight,
                      color: AppTheme.surfaceContainerHigh,
                      child: const Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
                if (onShare != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _ShareBadge(onShare: onShare!),
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.spacingStackXs),
            Text(
              title.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareBadge extends StatelessWidget {
  const _ShareBadge({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onShare,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.glassTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.share_outlined,
              size: 16,
              color: AppTheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
