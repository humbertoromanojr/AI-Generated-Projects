import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/injections/injector.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_typography.dart';
import '../../components/bottom_nav_bar.dart';
import '../../components/empty_state_widget.dart';
import '../../components/error_state_widget.dart';
import '../../components/movie_card.dart';
import '../../components/shimmer_loading.dart';
import '../../viewmodels/favorites_viewmodel.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<FavoritesCubit>()..load(),
      child: const FavoritesView(),
    );
  }
}

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/catalog');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(child: _FavoritesContent(state: state)),
              const Positioned(top: 0, left: 0, right: 0, child: _FavoritesTopBar()),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: 2,
            onTap: (index) => _onNavTap(context, index),
          ),
        );
      },
    );
  }
}

class _FavoritesContent extends StatelessWidget {
  const _FavoritesContent({required this.state});

  final FavoritesState state;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + 64;

    switch (state.status) {
      case FavoritesStatus.initial:
      case FavoritesStatus.loading:
        return ListView(
          padding: EdgeInsets.only(top: topPadding, left: 20, right: 20),
          children: const [MovieGridSkeleton()],
        );
      case FavoritesStatus.error:
        return Padding(
          padding: EdgeInsets.only(top: topPadding),
          child: ErrorStateWidget(
            message: state.errorMessage ?? 'Erro ao carregar favoritos.',
            onRetry: () => context.read<FavoritesCubit>().load(),
          ),
        );
      case FavoritesStatus.loaded:
        if (state.movies.isEmpty) {
          return Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: const EmptyStateWidget(
              icon: AppIcons.favoriteBorder,
              message: 'Nenhum filme favorito ainda.\nToque no coração para salvar.',
            ),
          );
        }
        final cubit = context.read<FavoritesCubit>();
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: topPadding)),
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
                    final movie = state.movies[index];
                    return MovieCard(
                      movie: movie,
                      isFavorite: true,
                      onTap: () => context.push('/movie/detail/${movie.id}'),
                      onFavoriteTap: () => cubit.remove(movie),
                    );
                  },
                  childCount: state.movies.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppConstants.stackLg)),
          ],
        );
    }
  }
}

class _FavoritesTopBar extends StatelessWidget {
  const _FavoritesTopBar();

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
              child: Text(
                'Meus Favoritos',
                style: AppTypography.headlineLgMobile,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
