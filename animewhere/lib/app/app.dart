import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/di/providers.dart';
import '../core/models/title_source.dart';
import '../ui/detail/detail_view.dart';
import '../ui/home/home_view.dart';
import '../ui/web/share_preview/share_preview_view.dart';
import 'theme/app_theme.dart';

class AnimeWhereApp extends StatelessWidget {
  const AnimeWhereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        appHttpClientProvider,
        catalogRepositoryProvider,
        homeViewModelProvider,
        shareRepositoryProvider,
        shareServiceProvider,
      ],
      child: MaterialApp.router(
        title: 'AnimeWhere',
        theme: AppTheme.themeData,
        routerConfig: AppRouter.router,
      ),
    );
  }
}

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/title/:source/:id',
        name: 'title',
        builder: (context, state) {
          final source = titleSourceFromName(state.pathParameters['source']);
          final id = state.pathParameters['id'] ?? '';
          if (kIsWeb && source != null && id.isNotEmpty) {
            return SharePreviewView(source: source, id: id);
          }
          return DetailView(source: source ?? TitleSource.jikan, id: id);
        },
      ),
    ],
  );
}
