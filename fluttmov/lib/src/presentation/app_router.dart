import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/favorites/favorites_page.dart';
import 'pages/home/home_page.dart';
import 'pages/movie/movie_list_page.dart';
import 'pages/movie_detail/movie_detail_page.dart';
import 'pages/splash/splash_page.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'splash',
          pageBuilder: (context, state) => _page(const SplashPage(), state),
        ),
        GoRoute(
          path: '/home',
          name: 'home',
          pageBuilder: (context, state) => _page(const HomePage(), state),
        ),
        GoRoute(
          path: '/catalog',
          name: 'catalog',
          pageBuilder: (context, state) => _page(const MovieListPage(), state),
        ),
        GoRoute(
          path: '/movie/:genreId',
          name: 'movieList',
          pageBuilder: (context, state) {
            final genreId = int.tryParse(state.pathParameters['genreId'] ?? '');
            return _page(MovieListPage(initialGenreId: genreId), state);
          },
        ),
        GoRoute(
          path: '/movie/detail/:movieId',
          name: 'movieDetail',
          pageBuilder: (context, state) {
            final movieId =
                int.tryParse(state.pathParameters['movieId'] ?? '') ?? 0;
            return _page(MovieDetailPage(movieId: movieId), state);
          },
        ),
        GoRoute(
          path: '/favorites',
          name: 'favorites',
          pageBuilder: (context, state) => _page(const FavoritesPage(), state),
        ),
      ],
    );
  }

  static CustomTransitionPage<void> _page(
    Widget child,
    GoRouterState state,
  ) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.02),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
