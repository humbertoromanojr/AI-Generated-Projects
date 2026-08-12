import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/movies/detail/detail_screen.dart';
import '../../features/movies/home/home_screen.dart';
import '../../features/movies/movie_list/movie_list_screen.dart';

class AppRouter {
  static final GoRouter config = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const HomeScreen(),
      ),
      GoRoute(
        path: '/movie/:genreId',
        pageBuilder: (_, state) => _fadeSlidePage(
          MovieListScreen(
            genreId: int.parse(state.pathParameters['genreId']!),
          ),
        ),
      ),
      GoRoute(
        path: '/movie/detail/:movieId',
        pageBuilder: (_, state) => _fadeSlidePage(
          DetailScreen(
            movieId: int.parse(state.pathParameters['movieId']!),
          ),
        ),
      ),
    ],
  );

  static Page<void> _fadeSlidePage(Widget child) {
    return CustomTransitionPage<void>(
      child: child,
      transitionsBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}
