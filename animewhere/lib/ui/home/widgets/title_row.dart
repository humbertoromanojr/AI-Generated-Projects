import 'package:flutter/material.dart' hide Title;

import 'package:animewhere/app/theme/app_text_theme.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/ui/widgets/error_view.dart';
import 'package:animewhere/ui/widgets/loading_view.dart';
import 'package:animewhere/ui/widgets/title_card.dart';

class TitleRow extends StatelessWidget {
  const TitleRow({
    super.key,
    required this.label,
    required this.result,
    this.onTitleTap,
    this.onTitleShare,
    this.onRetry,
  });

  final String label;
  final Result<List<Title>> result;
  final void Function(Title title)? onTitleTap;
  final void Function(Title title)? onTitleShare;
  final VoidCallback? onRetry;

  static const double _cardAreaHeight = 258;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.spacingStackLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.spacingMarginMobile,
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: AppDimens.spacingStackMd),
          SizedBox(height: _cardAreaHeight, child: _body(context)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    switch (result) {
      case Loading():
        return const LoadingView();
      case Failure():
        return ErrorView(
          error: (result as Failure).error,
          onRetry: onRetry ?? () {},
        );
      case Empty():
        return Center(
          child: Text(
            'No titles yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        );
      case Data():
        final titles = (result as Data).value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingMarginMobile,
          ),
          itemCount: titles.length,
          separatorBuilder: (_, _) =>
              const SizedBox(width: AppDimens.spacingStackMd),
          itemBuilder: (context, index) {
            final title = titles[index];
            return TitleCard(
              title: title,
              onTap: () => onTitleTap?.call(title),
              onShare: onTitleShare == null ? null : () => onTitleShare!(title),
            );
          },
        );
    }
  }
}
