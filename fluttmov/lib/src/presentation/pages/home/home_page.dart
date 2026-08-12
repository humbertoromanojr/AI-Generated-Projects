import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/injections/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/entities/movie.dart';
import '../../components/bottom_nav_bar.dart';
import '../../components/error_state_widget.dart';
import '../../components/movie_card.dart';
import '../../components/movie_carousel.dart';
import '../../components/shimmer_loading.dart';
import '../../viewmodels/home_viewmodel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeCubit>()..load(),
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 1:
        context.go('/catalog');
      case 2:
        context.go('/favorites');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: _HomeContent(state: state)),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: const _HomeTopBar(),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: 0,
            onTap: (index) => _onNavTap(context, index),
          ),
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + 64;

    switch (state.status) {
      case HomeStatus.initial:
      case HomeStatus.loading:
        return _HomeSkeleton(topPadding: topPadding);
      case HomeStatus.error:
        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: ErrorStateWidget(
            message: state.errorMessage ?? 'Erro ao carregar os filmes.',
            onRetry: () => context.read<HomeCubit>().load(),
          ),
        );
      case HomeStatus.loaded:
        return _HomeLoaded(state: state, topPadding: topPadding);
    }
  }
}

class _HomeLoaded extends StatelessWidget {
  const _HomeLoaded({required this.state, required this.topPadding});

  final HomeState state;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HomeCubit>();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: SizedBox(height: topPadding)),
        if (state.nowPlaying.isNotEmpty)
          SliverToBoxAdapter(
            child: MovieCarousel(
              movies: state.nowPlaying,
              onMovieTap: (movie) => _openDetail(context, movie),
              onPlayTap: (movie) => _openDetail(context, movie),
              onAddTap: cubit.toggleFavorite,
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.marginMain,
              AppConstants.stackMd,
              AppConstants.marginMain,
              AppConstants.gutter,
            ),
            child: Row(
              children: [
                Text('Em Alta', style: AppTypography.titleMd),
                const Spacer(),
                const Icon(
                  AppIcons.flame,
                  size: 20,
                  color: AppColors.accent,
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.marginMain),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppConstants.gutter,
              crossAxisSpacing: AppConstants.gutter,
              childAspectRatio: 0.53,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final movie = state.popular[index];
                return MovieCard(
                  movie: movie,
                  isFavorite: cubit.isFavorite(movie.id),
                  onTap: () => _openDetail(context, movie),
                  onFavoriteTap: () => cubit.toggleFavorite(movie),
                );
              },
              childCount: state.popular.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppConstants.stackLg)),
      ],
    );
  }

  void _openDetail(BuildContext context, Movie movie) {
    context.push('/movie/detail/${movie.id}');
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton({required this.topPadding});

  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(top: topPadding),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.marginMain),
          child: CarouselSkeleton(),
        ),
        Padding(
          padding: EdgeInsets.all(AppConstants.marginMain),
          child: Text('Em Alta', style: AppTypography.titleMd),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppConstants.marginMain),
          child: MovieGridSkeleton(),
        ),
      ],
    );
  }
}

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          color: AppColors.background.withValues(alpha: 0.8),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.marginMain,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    AppIcons.movie,
                    size: 24,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'FLUTTMOV',
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: AppColors.accent,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.surfaceContainerHigh),
                    ),
                    child: const Icon(
                      AppIcons.person,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
