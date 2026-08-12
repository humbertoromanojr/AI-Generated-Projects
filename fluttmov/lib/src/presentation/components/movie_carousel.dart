import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/image_url_builder.dart';
import '../../domain/entities/movie.dart';
import 'movie_image.dart';
import 'page_indicator.dart';

class MovieCarousel extends StatefulWidget {
  const MovieCarousel({
    super.key,
    required this.movies,
    required this.onMovieTap,
    this.onPlayTap,
    this.onAddTap,
    this.autoPlay = true,
  });

  final List<Movie> movies;
  final ValueChanged<Movie> onMovieTap;
  final ValueChanged<Movie>? onPlayTap;
  final ValueChanged<Movie>? onAddTap;
  final bool autoPlay;

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  PageController? _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(MovieCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.movies.length != widget.movies.length) {
      _restartAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  void _restartAutoPlay() {
    _autoPlayTimer?.cancel();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    if (!widget.autoPlay || widget.movies.length < 2) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _pageController == null || !_pageController!.hasClients) {
        return;
      }
      final next = (_currentIndex + 1) % widget.movies.length;
      _pageController!.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = max(
      MediaQuery.sizeOf(context).height * AppConstants.heroCarouselHeightFactor,
      AppConstants.heroCarouselMinHeight,
    );

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return _HeroItem(
                movie: movie,
                onTap: () => widget.onMovieTap(movie),
                onPlayTap: widget.onPlayTap == null
                    ? null
                    : () => widget.onPlayTap!(movie),
                onAddTap: widget.onAddTap == null
                    ? null
                    : () => widget.onAddTap!(movie),
              );
            },
          ),
          if (widget.movies.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: PageIndicator(
                count: widget.movies.length,
                index: _currentIndex,
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroItem extends StatelessWidget {
  const _HeroItem({
    required this.movie,
    required this.onTap,
    required this.onPlayTap,
    required this.onAddTap,
  });

  final Movie movie;
  final VoidCallback onTap;
  final VoidCallback? onPlayTap;
  final VoidCallback? onAddTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.marginMain,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusImage,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.1),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusImage,
                      ),
                      child: MovieImage(
                        imageUrl: ImageUrlBuilder.backdrop(movie.backdropPath),
                      ),
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusImage,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.55, 1.0],
                        colors: [
                          AppColors.background.withValues(alpha: 0.0),
                          AppColors.background.withValues(alpha: 0.6),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _HeroBadge(),
                        const SizedBox(height: 8),
                        Text(
                          movie.title,
                          style: AppTypography.headlineXl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          movie.overview,
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _PlayButton(onTap: onPlayTap),
                            const SizedBox(width: 12),
                            _AddButton(onTap: onAddTap),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(AppIcons.star, color: AppColors.accent, size: 12),
          const SizedBox(width: 6),
          Text(
            'EM CARTAZ',
            style: AppTypography.labelCaps.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.play, color: AppColors.onAccent, size: 22),
            const SizedBox(width: 8),
            Text(
              'Assistir Agora',
              style: AppTypography.titleMd.copyWith(color: AppColors.onAccent),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: const Icon(AppIcons.add, color: AppColors.textPrimary),
      ),
    );
  }
}
