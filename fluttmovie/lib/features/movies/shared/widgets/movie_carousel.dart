import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../domain/entities/movie.dart';
import 'shimmer_loading.dart';

class MovieCarousel extends StatefulWidget {
  final List<Movie> movies;
  final String? Function(int genreId)? genreNameOf;
  final ValueChanged<Movie>? onMovieTap;
  final ValueChanged<Movie>? onToggleFavorite;

  const MovieCarousel({
    super.key,
    required this.movies,
    this.genreNameOf,
    this.onMovieTap,
    this.onToggleFavorite,
  });

  @override
  State<MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<MovieCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    if (widget.movies.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!_controller.hasClients) return;
        final next = (_current + 1) % widget.movies.length;
        _controller.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox(
        height: 400,
        child: ShimmerBox(radius: BorderRadius.all(Radius.circular(24))),
      );
    }

    final screenHeight = MediaQuery.sizeOf(context).height;
    final height = (screenHeight * 0.6).clamp(400.0, 560.0);
    final movie = widget.movies[_current];
    final genreName = movie.genreIds.isNotEmpty
        ? widget.genreNameOf?.call(movie.genreIds.first)
        : null;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMain,
                0,
                AppSpacing.marginMain,
                28,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.movies.length,
                  onPageChanged: (index) =>
                      setState(() => _current = index),
                  itemBuilder: (context, index) =>
                      _HeroImage(movie: widget.movies[index]),
                ),
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.marginMain + 8,
            right: AppSpacing.marginMain + 8,
            bottom: 52,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _HeroContent(
                key: ValueKey(movie.id),
                movie: movie,
                genreName: genreName,
                onPlay: () => widget.onMovieTap?.call(movie),
                onFavorite: () => widget.onToggleFavorite?.call(movie),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: _Dots(count: widget.movies.length, active: _current),
          ),
        ],
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Movie movie;

  const _HeroImage({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (movie.backdropUrl != null)
          CachedNetworkImage(
            imageUrl: movie.backdropUrl!,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ShimmerBox(),
            errorWidget: (_, _, _) => const _HeroPlaceholder(),
          )
        else
          const _HeroPlaceholder(),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                AppColors.background,
                AppColors.background.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  final Movie movie;
  final String? genreName;
  final VoidCallback? onPlay;
  final VoidCallback? onFavorite;

  const _HeroContent({
    super.key,
    required this.movie,
    this.genreName,
    this.onPlay,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = genreName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (label != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 2),
                Text(
                  Formatters.rating(movie.rating),
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.stackSm),
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            shadows: const [Shadow(color: Colors.black45, blurRadius: 8)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          movie.overview,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FilledButton.icon(
              onPressed: onPlay,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                'Play Now',
                style: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: onFavorite,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surface.withValues(alpha: 0.5),
                foregroundColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              icon: const Icon(Icons.add, size: 22),
            ),
          ],
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;

  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

class _HeroPlaceholder extends StatelessWidget {
  const _HeroPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: Icon(
        Icons.movie_outlined,
        size: 56,
        color: AppColors.textSecondary.withValues(alpha: 0.4),
      ),
    );
  }
}
