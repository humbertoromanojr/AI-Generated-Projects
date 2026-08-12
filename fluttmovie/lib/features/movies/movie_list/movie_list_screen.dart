import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/genre.dart';
import '../../../domain/entities/movie.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/movie_list_card.dart';
import '../shared/widgets/shimmer_loading.dart';
import '../shared/widgets/state_widgets.dart';
import 'movie_list_viewmodel.dart';

class MovieListScreen extends StatelessWidget {
  final int genreId;

  const MovieListScreen({super.key, required this.genreId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<MovieListViewModel>()..load(genreId: genreId),
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Consumer<MovieListViewModel>(
                builder: (context, vm, _) {
                  final banner = vm.movies.isNotEmpty
                      ? vm.movies.first.backdropUrl
                      : null;
                  final title = vm.selectedGenre?.name ?? 'Filmes';

                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 300) {
                        vm.loadMore();
                      }
                      return false;
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          pinned: true,
                          expandedHeight: 220,
                          leadingWidth: 72,
                          leading: Padding(
                            padding: const EdgeInsets.all(14),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color:
                                    AppColors.surfaceHigh.withValues(alpha: 0.5),
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
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: _Banner(
                              imageUrl: banner,
                              title: title,
                            ),
                          ),
                        ),
                        if (vm.genres.isNotEmpty)
                          SliverToBoxAdapter(
                            child: _GenreChips(
                              genres: vm.genres,
                              selectedId: vm.selectedGenreId,
                              onSelect: vm.selectGenre,
                            ),
                          ),
                        ..._bodySlivers(vm),
                      ],
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                active: NavTab.search,
                onSelect: (tab) {
                  if (tab == NavTab.home) context.go('/');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _bodySlivers(MovieListViewModel vm) {
    if (vm.isLoading) {
      return [
        const SliverPadding(
          padding: EdgeInsets.all(AppSpacing.marginMain),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              _shimmerCard,
              childCount: 6,
            ),
          ),
        ),
      ];
    }
    if (vm.error != null && vm.movies.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ErrorState(
            message: vm.error!.message,
            onRetry: () => vm.load(genreId: vm.selectedGenreId),
          ),
        ),
      ];
    }
    if (vm.movies.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(message: 'Nenhum filme encontrado.'),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(AppSpacing.marginMain),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final movie = vm.movies[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.gutter),
                child: MovieListCard(
                  movie: movie,
                  onTap: () => _openMovie(context, movie),
                ),
              );
            },
            childCount: vm.movies.length,
          ),
        ),
      ),
      if (vm.isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Center(
              child: SizedBox(
                width: 200,
                height: 12,
                child: ShimmerBox(
                  radius: BorderRadius.all(Radius.circular(6)),
                ),
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 96)),
    ];
  }

  void _openMovie(BuildContext context, Movie movie) {
    context.push('/movie/detail/${movie.id}');
  }
}

class _Banner extends StatelessWidget {
  final String? imageUrl;
  final String title;

  const _Banner({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (imageUrl != null)
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            placeholder: (_, _) => const ShimmerBox(),
            errorWidget: (_, _, _) => const SizedBox.shrink(),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.background.withValues(alpha: 0.2),
                AppColors.background.withValues(alpha: 0.6),
                AppColors.background,
              ],
            ),
          ),
        ),
        Positioned(
          left: AppSpacing.marginMain,
          right: AppSpacing.marginMain,
          bottom: 24,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 10)],
                ),
          ),
        ),
      ],
    );
  }
}

class _GenreChips extends StatelessWidget {
  final List<Genre> genres;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  const _GenreChips({
    required this.genres,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.marginMain,
          vertical: 6,
        ),
        itemCount: genres.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.stackSm),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre.id == selectedId;
          return ChoiceChip(
            label: Text(genre.name),
            selected: isSelected,
            onSelected: (_) => onSelect(genre.id),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
            showCheckmark: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

Widget _shimmerCard(BuildContext context, int index) => const _ShimmerCard();

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.gutter),
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            const SizedBox(
              width: 100,
              height: 150,
              child: ShimmerBox(
                radius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            const SizedBox(width: AppSpacing.gutter),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(
                    height: 16,
                    width: 140,
                    child: ShimmerBox(),
                  ),
                  SizedBox(height: 12),
                  SizedBox(
                    height: 12,
                    child: ShimmerBox(),
                  ),
                  SizedBox(height: 8),
                  SizedBox(
                    height: 12,
                    width: 100,
                    child: ShimmerBox(),
                  ),
                  Spacer(),
                  SizedBox(
                    height: 20,
                    width: 90,
                    child: ShimmerBox(
                      radius: BorderRadius.all(Radius.circular(999)),
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
