import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/api_config.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/movie_details.dart';
import '../shared/widgets/cast_list.dart';
import '../shared/widgets/shimmer_loading.dart';
import '../shared/widgets/state_widgets.dart';
import 'detail_viewmodel.dart';

class DetailScreen extends StatelessWidget {
  final int movieId;

  const DetailScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<DetailViewModel>()..load(movieId),
      child: Scaffold(
        body: Consumer<DetailViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const _DetailSkeleton();
            }
            if (vm.error != null || vm.movie == null) {
              return Stack(
                children: [
                  ErrorState(
                    message: vm.error?.message ?? 'Filme não encontrado.',
                    onRetry: () => vm.load(movieId),
                  ),
                  const _BackButton(),
                ],
              );
            }
            return _DetailContent(vm: vm);
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final DetailViewModel vm;

  const _DetailContent({required this.vm});

  @override
  Widget build(BuildContext context) {
    final movie = vm.movie!;
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 320,
              leadingWidth: 72,
              leading: const Padding(
                padding: EdgeInsets.all(14),
                child: _BackButton(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _DetailHeader(
                  movie: movie,
                  isFavorite: vm.isFavorite,
                  onFavorite: vm.toggleFavorite,
                  onShare: vm.share,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _DetailBody(movie: movie),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _WatchNowBar(movie: movie),
        ),
      ],
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final MovieDetails movie;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  const _DetailHeader({
    required this.movie,
    required this.isFavorite,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genres = movie.genres.map((g) => g.name).join(', ');

    return Stack(
      fit: StackFit.expand,
      children: [
        if (movie.backdropUrl != null)
          CachedNetworkImage(
            imageUrl: movie.backdropUrl!,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ShimmerBox(),
            errorWidget: (_, _, _) => const _HeaderPlaceholder(),
          )
        else
          const _HeaderPlaceholder(),
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
        Positioned(
          left: AppSpacing.marginMain,
          right: AppSpacing.marginMain,
          bottom: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        Formatters.year(movie.releaseDate),
                        genres,
                        if (movie.runtime > 0)
                          Formatters.runtime(movie.runtime),
                      ].where((s) => s.isNotEmpty).join(' • '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: onShare,
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: onFavorite,
                    icon: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailBody extends StatelessWidget {
  final MovieDetails movie;

  const _DetailBody({required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.marginMain,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.stackMd),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                Formatters.rating(movie.rating),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: 6),
              Text('Nota', style: theme.textTheme.bodySmall),
              Container(
                width: 1,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                color: AppColors.surfaceHigh,
              ),
              const Icon(
                Icons.people_alt_outlined,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                Formatters.votes(movie.voteCount),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(width: 6),
              Text('Votos', style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppSpacing.stackLg),
          if (movie.overview.isNotEmpty) ...[
            _SectionTitle('Sinopse'),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              movie.overview,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: AppSpacing.stackLg),
          ],
          if (movie.cast.isNotEmpty) ...[
            _SectionTitle('Elenco'),
            const SizedBox(height: AppSpacing.stackSm),
            CastList(cast: movie.cast),
            const SizedBox(height: AppSpacing.stackLg),
          ],
          if (movie.director != null) ...[
            _SectionTitle('Diretor'),
            const SizedBox(height: AppSpacing.stackSm),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceHigh,
                  child: Text(
                    _initials(movie.director!),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  movie.director!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _WatchNowBar extends StatelessWidget {
  final MovieDetails movie;

  const _WatchNowBar({required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.marginMain,
        AppSpacing.stackMd,
        AppSpacing.marginMain,
        bottom + AppSpacing.stackSm,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withValues(alpha: 0.9),
            AppColors.background,
          ],
        ),
      ),
      child: FilledButton.icon(
        onPressed: () => launchUrl(
          Uri.parse('${ApiConfig.moviePageUrl}${movie.id}'),
          mode: LaunchMode.externalApplication,
        ),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.play_arrow_rounded),
        label: Text('Assistir Agora', style: theme.textTheme.titleMedium),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _HeaderPlaceholder extends StatelessWidget {
  const _HeaderPlaceholder();

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

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: const [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 320,
          child: ShimmerBox(),
        ),
        Positioned(
          left: AppSpacing.marginMain,
          right: AppSpacing.marginMain,
          top: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
                width: 160,
                child: ShimmerBox(),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 14,
                width: double.infinity,
                child: ShimmerBox(),
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 14,
                width: 260,
                child: ShimmerBox(),
              ),
              SizedBox(height: 32),
              SizedBox(
                height: 16,
                width: 120,
                child: ShimmerBox(),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 12,
                width: double.infinity,
                child: ShimmerBox(),
              ),
              SizedBox(height: 8),
              SizedBox(
                height: 12,
                width: 200,
                child: ShimmerBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
