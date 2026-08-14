import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide Title;

import 'package:animewhere/app/theme/app_theme.dart';
import 'package:animewhere/app/theme/app_text_theme.dart';
import 'package:animewhere/core/models/title.dart';
import 'package:animewhere/core/models/title_page.dart';
import 'package:animewhere/core/utils/result.dart';
import 'package:animewhere/ui/widgets/error_view.dart';
import 'package:animewhere/ui/widgets/loading_view.dart';

class TitleCarousel extends StatefulWidget {
  const TitleCarousel({
    super.key,
    required this.result,
    this.onTitleTap,
    this.onTitleShare,
    this.onRetry,
    this.height = 280,
  });

  final Result<TitlePage> result;
  final void Function(Title title)? onTitleTap;
  final void Function(Title title)? onTitleShare;
  final VoidCallback? onRetry;
  final double height;

  @override
  State<TitleCarousel> createState() => _TitleCarouselState();
}

class _TitleCarouselState extends State<TitleCarousel> {
  final PageController _controller = PageController(viewportFraction: 0.72);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: switch (widget.result) {
        Loading() => const LoadingView(),
        Empty() => const _MessageView(
          icon: Icons.movie_outlined,
          message: 'No titles yet',
        ),
        Failure() => ErrorView(
          error: (widget.result as Failure).error,
          onRetry: widget.onRetry ?? () {},
        ),
        Data<TitlePage>() => _data(
          context,
          (widget.result as Data<TitlePage>).value.titles,
        ),
      },
    );
  }

  Widget _data(BuildContext context, List<Title> titles) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: titles.length,
          onPageChanged: (index) => setState(() => _page = index),
          itemBuilder: (context, index) => _featuredCard(titles[index]),
        ),
        Positioned(
          bottom: 16,
          child: _GlassNavigation(
            page: _page,
            count: titles.length,
            onPrevious: _page > 0
                ? () => _controller.previousPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  )
                : null,
            onNext: _page < titles.length - 1
                ? () => _controller.nextPage(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _featuredCard(Title title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => widget.onTitleTap?.call(title),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: title.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: AppTheme.surfaceContainerHigh),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.surfaceContainerHigh,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.spacingStackSm,
                    vertical: AppDimens.spacingStackXs,
                  ),
                  color: AppTheme.glassTint,
                  child: Text(
                    title.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (widget.onTitleShare != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => widget.onTitleShare?.call(title),
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
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassNavigation extends StatelessWidget {
  const _GlassNavigation({
    required this.page,
    required this.count,
    this.onPrevious,
    this.onNext,
  });

  final int page;
  final int count;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacingStackSm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppTheme.glassTint,
            borderRadius: BorderRadius.circular(AppDimens.radiusFull),
            border: Border.all(
              color: AppTheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onPrevious,
                icon: const Icon(Icons.chevron_left),
                color: onPrevious == null
                    ? AppTheme.onSurfaceVariant.withValues(alpha: 0.3)
                    : AppTheme.onSurface,
              ),
              Text(
                '${page + 1} / $count',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_right),
                color: onNext == null
                    ? AppTheme.onSurfaceVariant.withValues(alpha: 0.3)
                    : AppTheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.outline, size: 28),
          const SizedBox(height: AppDimens.spacingStackXs),
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
