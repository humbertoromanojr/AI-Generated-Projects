import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/injections/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/genre.dart';
import '../../components/bottom_nav_bar.dart';
import '../../components/empty_state_widget.dart';
import '../../components/error_state_widget.dart';
import '../../components/genre_banner.dart';
import '../../components/movie_card.dart';
import '../../components/shimmer_loading.dart';
import '../../viewmodels/movie_list_viewmodel.dart';

class MovieListPage extends StatelessWidget {
  const MovieListPage({super.key, this.initialGenreId});

  final int? initialGenreId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MovieListCubit>(param1: initialGenreId)..load(),
      child: const MovieListView(),
    );
  }
}

class MovieListView extends StatelessWidget {
  const MovieListView({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 2:
        context.go('/favorites');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieListCubit, MovieListState>(
      builder: (context, state) {
        return Scaffold(
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 300) {
                context.read<MovieListCubit>().loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: AppConstants.categoryBannerHeight,
                  pinned: true,
                  backgroundColor: AppColors.background,
                  foregroundColor: AppColors.textPrimary,
                  leading: context.canPop()
                      ? const _BannerBackButton()
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    background: GenreBanner(
                      genreName: state.selectedGenre?.name ?? 'Catálogo',
                      imageUrl: state.bannerPath,
                    ),
                  ),
                ),
                if (state.genres.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _GenreChips(
                      genres: state.genres,
                      selectedGenreId: state.selectedGenre?.id,
                    ),
                  ),
                ..._buildContent(context, state),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: 1,
            onTap: (index) => _onNavTap(context, index),
          ),
        );
      },
    );
  }

  List<Widget> _buildContent(BuildContext context, MovieListState state) {
    switch (state.status) {
      case MovieListStatus.initial:
      case MovieListStatus.loading:
        return const [
          SliverPadding(
            padding: EdgeInsets.all(AppConstants.marginMain),
            sliver: SliverToBoxAdapter(child: MovieListSkeleton()),
          ),
        ];
      case MovieListStatus.error:
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorStateWidget(
              message: state.errorMessage ?? 'Erro ao carregar os filmes.',
              onRetry: () => context.read<MovieListCubit>().load(),
            ),
          ),
        ];
      case MovieListStatus.loaded:
      case MovieListStatus.loadingMore:
        if (state.movies.isEmpty) {
          return [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                message: 'Nenhum filme encontrado neste gênero.',
              ),
            ),
          ];
        }
        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.marginMain,
              AppConstants.stackSm,
              AppConstants.marginMain,
              AppConstants.stackLg,
            ),
            sliver: SliverList.separated(
              itemCount: state.movies.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                if (index >= state.movies.length) {
                  return _LoadingMoreIndicator(
                    show: state.status == MovieListStatus.loadingMore,
                  );
                }
                final movie = state.movies[index];
                return MovieHorizontalCard(
                  movie: movie,
                  onTap: () => context.push('/movie/detail/${movie.id}'),
                );
              },
            ),
          ),
        ];
    }
  }
}

class _GenreChips extends StatelessWidget {  const _GenreChips({required this.genres, required this.selectedGenreId});

  final List<Genre> genres;
  final int? selectedGenreId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.marginMain),
        itemCount: genres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final selected = genre.id == selectedGenreId;
          return GestureDetector(
            onTap: () => context.read<MovieListCubit>().selectGenre(genre),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(9999),
                border: selected
                    ? null
                    : Border.all(color: AppColors.outline),
              ),
              child: Text(
                genre.name,
                style: AppTypography.labelCaps.copyWith(
                  color: selected
                      ? AppColors.onAccent
                      : AppColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingMoreIndicator extends StatelessWidget {
  const _LoadingMoreIndicator({required this.show});

  final bool show;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: show
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              )
            : const SizedBox(height: 20),
      ),
    );
  }
}

class _BannerBackButton extends StatelessWidget {
  const _BannerBackButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => context.pop(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            AppIcons.back,
            size: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
