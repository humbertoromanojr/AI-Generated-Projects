import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/movie.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/movie_card.dart';
import '../shared/widgets/movie_carousel.dart';
import '../shared/widgets/shimmer_loading.dart';
import '../shared/widgets/state_widgets.dart';
import 'home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<HomeViewModel>()..load(),
      child: Scaffold(
        body: Stack(
          children: [
            const _HomeHeader(),
            Positioned.fill(
              child: Consumer<HomeViewModel>(
                builder: (context, vm, _) {
                  if (vm.isLoading) {
                    return _LoadingBody();
                  }
                  if (vm.error != null && vm.nowPlaying.isEmpty) {
                    return ErrorState(
                      message: vm.error!.message,
                      onRetry: vm.load,
                    );
                  }
                  return _HomeBody(vm: vm);
                },
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Consumer<HomeViewModel>(
                builder: (context, vm, _) => BottomNavBar(
                  active: NavTab.home,
                  onSelect: (tab) => _onNavSelect(context, vm, tab),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onNavSelect(
    BuildContext context,
    HomeViewModel vm,
    NavTab tab,
  ) {
    if (tab == NavTab.search) {
      final genreId = vm.genres.isNotEmpty ? vm.genres.first.id : 28;
      context.push('/movie/$genreId');
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: AppColors.background.withValues(alpha: 0.8),
            padding: EdgeInsets.only(
              top: MediaQuery.paddingOf(context).top + 10,
              left: AppSpacing.marginMain,
              right: AppSpacing.marginMain,
              bottom: 12,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.movie_filter_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'FLUTTMOV',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surfaceHigh),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final HomeViewModel vm;

  const _HomeBody({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MovieCarousel(
          movies: vm.nowPlaying,
          genreNameOf: vm.genreName,
          onMovieTap: (movie) => _openMovie(context, movie),
          onToggleFavorite: (movie) => _toggleFavorite(context, vm, movie),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: vm.load,
            color: AppColors.primary,
            backgroundColor: AppColors.surface,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMain,
                    AppSpacing.stackMd,
                    AppSpacing.marginMain,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Text(
                          'Em Alta',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.local_fire_department_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.marginMain),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.stackMd,
                      crossAxisSpacing: AppSpacing.gutter,
                      childAspectRatio: 0.56,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => MovieCard(
                        movie: vm.popular[index],
                        genreName: vm.popular[index].genreIds.isNotEmpty
                            ? vm.genreName(vm.popular[index].genreIds.first)
                            : null,
                        onTap: () => _openMovie(context, vm.popular[index]),
                      ),
                      childCount: vm.popular.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 96),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openMovie(BuildContext context, Movie movie) {
    context.push('/movie/detail/${movie.id}');
  }

  void _toggleFavorite(BuildContext context, HomeViewModel vm, Movie movie) {
    vm.toggleFavorite(movie);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${movie.title} adicionado aos favoritos'),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _LoadingBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(
            top: 76,
            left: AppSpacing.marginMain,
            right: AppSpacing.marginMain,
          ),
          child: SizedBox(
            height: 400,
            child: ShimmerBox(
              radius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMain),
          child: const SizedBox(
            height: 18,
            width: 120,
            child: ShimmerBox(),
          ),
        ),
        const Expanded(child: ShimmerGrid()),
      ],
    );
  }
}
