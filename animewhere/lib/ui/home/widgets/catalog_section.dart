import 'package:flutter/material.dart';
import 'package:animewhere/core/models/title.dart' as model;
import 'package:animewhere/ui/home/home_view_model.dart';

import 'infinite_title_row.dart';
import 'title_carousel.dart';

class CatalogSection extends StatelessWidget {
  const CatalogSection({
    super.key,
    required this.section,
    required this.onTitleTap,
    required this.onTitleShare,
    required this.onRetry,
    required this.onLoadMore,
  });

  final SectionState section;
  final void Function(model.Title title)? onTitleTap;
  final void Function(model.Title title)? onTitleShare;
  final VoidCallback onRetry;
  final void Function(String sectionId, String rowId) onLoadMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.label, style: textTheme.titleLarge),
            const SizedBox(height: 12),
            TitleCarousel(
              result: section.carousel,
              onTitleTap: onTitleTap,
              onTitleShare: onTitleShare,
              onRetry: onRetry,
            ),
            const SizedBox(height: 12),
            InfiniteTitleRow(
              titles: section.rows[0].titles,
              label: section.rows[0].label,
              hasMore: section.rows[0].hasMore,
              isLoadingMore: section.rows[0].isLoadingMore,
              loadFailed: section.rows[0].loadFailed,
              onLoadMore: () => onLoadMore(section.id, section.rows[0].id),
              onTitleTap: onTitleTap,
              onTitleShare: onTitleShare,
              onRetry: onRetry,
            ),
            const SizedBox(height: 8),
            InfiniteTitleRow(
              titles: section.rows[1].titles,
              label: section.rows[1].label,
              hasMore: section.rows[1].hasMore,
              isLoadingMore: section.rows[1].isLoadingMore,
              loadFailed: section.rows[1].loadFailed,
              onLoadMore: () => onLoadMore(section.id, section.rows[1].id),
              onTitleTap: onTitleTap,
              onTitleShare: onTitleShare,
              onRetry: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
