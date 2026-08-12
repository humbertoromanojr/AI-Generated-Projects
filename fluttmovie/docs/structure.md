# Estrutura do Projeto FLUTTMOV App

## Visão Geral

Este documento descreve a organização de diretórios e arquivos do FLUTTMOV App, seguindo as recomendações de estruturação de projetos Flutter da documentação oficial. A estrutura prioriza clareza, navegabilidade e escalabilidade, com separação de responsabilidades entre UI, lógica de negócio e dados.

## Diretório Raiz

```
fluttmov/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   └── features/
│       └── movies/
├── test/
├── assets/
└── pubspec.yaml
```

## Estrutura Principal (`lib/`)

```
lib/
├── main.dart                       # Ponto de entrada, inicialização
├── app.dart                        # MaterialApp.router, tema, rotas
│
├── core/                           # Infraestrutura compartilhada
│   ├── theme/
│   │   └── app_theme.dart          # ThemeData dark mode
│   ├── routing/
│   │   └── app_router.dart         # GoRouter config
│   ├── network/
│   │   └── tmdb_client.dart        # Dio instance + interceptors
│   ├── storage/
│   │   └── hive_service.dart       # Inicialização Hive
│   ├── di/
│   │   └── service_locator.dart    # GetIt registration
│   └── utils/
│       ├── image_urls.dart         # TMDB image URL builder
│       └── formatters.dart         # Date, rating formatters
│
├── data/                           # Camada de dados
│   ├── models/
│   │   ├── movie_model.dart        # JSON serialization
│   │   └── genre_model.dart
│   ├── datasources/
│   │   ├── movie_remote.dart       # TMDB API calls
│   │   ├── genre_remote.dart       # Genre endpoints
│   │   └── favorites_local.dart    # Hive operations
│   └── repositories/
│       ├── movie_repository.dart   # Implementation
│       └── favorites_repository.dart
│
├── domain/                         # Camada de domínio
│   ├── entities/
│   │   ├── movie.dart              # Pure data class
│   │   ├── movie_details.dart
│   │   └── genre.dart
│   ├── repositories/               # Abstract interfaces
│   │   ├── movie_repository.dart
│   │   └── favorites_repository.dart
│   └── usecases/
│       ├── get_movies.dart         # Now playing + popular
│       ├── get_movie_details.dart
│       ├── get_genres.dart
│       └── toggle_favorite.dart
│
└── features/                       # Feature-based organization
    └── movies/
        ├── home/
        │   ├── home_screen.dart
        │   └── home_viewmodel.dart
        ├── detail/
        │   ├── detail_screen.dart
        │   └── detail_viewmodel.dart
        ├── favorites/
        │   ├── favorites_screen.dart
        │   └── favorites_viewmodel.dart
        └── shared/
            └── widgets/
                ├── movie_card.dart
                ├── movie_carousel.dart
                ├── cast_list.dart
                ├── rating_stars.dart
                ├── genre_banner.dart
                ├── shimmer_loading.dart
                ├── error_state.dart
                └── empty_state.dart
```

## Pontos de Entrada

### `main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa serviços core
  await HiveService.init();
  ServiceLocator.init();

  runApp(const FluttmovApp());
}
```

### `app.dart`

```dart
class FluttmovApp extends StatelessWidget {
  const FluttmovApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FLUTTMOV',
      theme: AppTheme.dark,
      routerConfig: AppRouter.config,
    );
  }
}
```

## Core - Infraestrutura Compartilhada

### `core/theme/app_theme.dart`

```dart
class AppTheme {
  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    colorScheme: const ColorScheme.dark(
      surface: Color(0xFF1A1A1A),
      primary: Color(0xFFE5B143),
    ),
    // ...textTheme, cardTheme, etc.
  );
}
```

### `core/routing/app_router.dart`

```dart
class AppRouter {
  static final config = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/movie/:id',
        builder: (_, state) => DetailScreen(
          movieId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/favorites',
        builder: (_, __) => const FavoritesScreen(),
      ),
    ],
  );
}
```

### `core/di/service_locator.dart`

```dart
final sl = GetIt.instance;

class ServiceLocator {
  static void init() {
    // Network
    sl.registerLazySingleton(() => TmdbClient.create());

    // Data sources
    sl.registerLazySingleton<MovieRemoteDataSource>(
      () => MovieRemoteDataSource(sl()),
    );
    sl.registerLazySingleton<FavoritesLocalDataSource>(
      () => FavoritesLocalDataSource(),
    );

    // Repositories
    sl.registerLazySingleton<MovieRepository>(
      () => MovieRepositoryImpl(sl(), sl()),
    );

    // Use cases
    sl.registerLazySingleton(() => GetMovies(sl()));
    sl.registerLazySingleton(() => GetMovieDetails(sl()));
    sl.registerLazySingleton(() => ToggleFavorite(sl()));

    // ViewModels - factory para nova instância por tela
    sl.registerFactory(() => HomeViewModel(sl(), sl()));
    sl.registerFactory(() => DetailViewModel(sl(), sl()));
    sl.registerFactory(() => FavoritesViewModel(sl()));
  }
}
```

## Data - Camada de Dados

### `data/models/movie_model.dart`

Modelos com serialização JSON e mapeamento para entidades:

```dart
@JsonSerializable()
class MovieModel {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final List<int> genreIds;

  MovieModel({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    required this.voteAverage,
    required this.genreIds,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  Movie toEntity() => Movie(
    id: id,
    title: title,
    overview: overview ?? '',
    posterUrl: posterPath != null
        ? TmdbImageUrls.poster500(posterPath!)
        : null,
    backdropUrl: backdropPath != null
        ? TmdbImageUrls.backdrop780(backdropPath!)
        : null,
    rating: voteAverage,
    genreIds: genreIds,
  );
}
```

### `data/datasources/movie_remote.dart`

```dart
class MovieRemoteDataSource {
  final Dio _client;

  MovieRemoteDataSource(this._client);

  Future<PaginatedResponse<MovieModel>> getNowPlaying({int page = 1}) async {
    final response = await _client.get(
      '/movie/now_playing',
      queryParameters: {'page': page, 'language': 'pt-BR'},
    );
    return PaginatedResponse.fromJson(
      response.data,
      (json) => MovieModel.fromJson(json),
    );
  }

  Future<MovieDetailModel> getDetails(int movieId) async {
    final response = await _client.get(
      '/movie/$movieId',
      queryParameters: {'language': 'pt-BR'},
    );
    return MovieDetailModel.fromJson(response.data);
  }
}
```

### `data/repositories/movie_repository.dart`

```dart
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remote;
  final FavoritesLocalDataSource _local;

  MovieRepositoryImpl(this._remote, this._local);

  @override
  Future<Either<Failure, List<Movie>>> getNowPlaying({int page = 1}) async {
    try {
      final response = await _remote.getNowPlaying(page: page);
      return Right(response.results.map((m) => m.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

## Domain - Camada de Domínio

### `domain/entities/movie.dart`

Entidades puras, sem dependências externas:

```dart
class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterUrl;
  final String? backdropUrl;
  final double rating;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterUrl,
    this.backdropUrl,
    required this.rating,
    required this.genreIds,
  });
}
```

### `domain/repositories/movie_repository.dart`

Contratos abstratos que a camada de dados implementa:

```dart
abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getNowPlaying({int page});
  Future<Either<Failure, List<Movie>>> getPopular({int page});
  Future<Either<Failure, MovieDetails>> getDetails(int movieId);
}
```

### `domain/usecases/get_movies.dart`

Casos de uso orquestrando operações de negócio:

```dart
class GetNowPlayingMovies {
  final MovieRepository _repository;

  GetNowPlayingMovies(this._repository);

  Future<Either<Failure, List<Movie>>> call({int page = 1}) {
    return _repository.getNowPlaying(page: page);
  }
}
```

## Features - Organização por Funcionalidade

Cada feature contém sua tela e seu ViewModel no mesmo diretório, mantendo alta coesão.

### `features/movies/home/`

```dart
// home_viewmodel.dart
class HomeViewModel extends ChangeNotifier {
  final GetNowPlayingMovies _getNowPlaying;
  final GetPopularMovies _getPopular;

  List<Movie> _nowPlaying = [];
  List<Movie> _popular = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get nowPlaying => _nowPlaying;
  List<Movie> get popular => _popular;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeViewModel(this._getNowPlaying, this._getPopular);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final results = await Future.wait([
      _getNowPlaying(),
      _getPopular(),
    ]);

    results[0].fold(
      (failure) => _error = failure.message,
      (movies) => _nowPlaying = movies,
    );
    results[1].fold(
      (failure) => _error ??= failure.message,
      (movies) => _popular = movies,
    );

    _isLoading = false;
    notifyListeners();
  }
}
```

```dart
// home_screen.dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => sl<HomeViewModel>()..load(),
      child: Scaffold(
        body: Consumer<HomeViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) return const ShimmerLoading();
            if (vm.error != null) return ErrorState(message: vm.error!);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: MovieCarousel(movies: vm.nowPlaying),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: gridDelegate,
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => MovieCard(movie: vm.popular[index]),
                      childCount: vm.popular.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

### `features/movies/detail/`

```dart
// detail_viewmodel.dart
class DetailViewModel extends ChangeNotifier {
  final GetMovieDetails _getDetails;
  final ToggleFavorite _toggleFavorite;

  MovieDetails? _movie;
  bool _isFavorite = false;
  bool _isLoading = false;

  MovieDetails? get movie => _movie;
  bool get isFavorite => _isFavorite;
  bool get isLoading => _isLoading;

  DetailViewModel(this._getDetails, this._toggleFavorite);

  Future<void> load(int movieId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _getDetails(movieId);
    result.fold(
      (failure) => _error = failure.message,
      (movie) {
        _movie = movie;
        _isFavorite = movie.isFavorite;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    if (_movie == null) return;
    await _toggleFavorite(_movie!.id);
    _isFavorite = !_isFavorite;
    notifyListeners();
  }
}
```

## Componentes Compartilhados

### `features/movies/shared/widgets/movie_card.dart`

```dart
class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onTap;

  const MovieCard({required this.movie, this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: movie.posterUrl != null
            ? CachedNetworkImage(
                imageUrl: movie.posterUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ShimmerBox(),
              )
            : const PlaceholderImage(),
      ),
    );
  }
}
```

## Assets

```
assets/
├── fonts/
│   └── Inter/
│       ├── Inter-Regular.ttf
│       ├── Inter-Medium.ttf
│       └── Inter-Bold.ttf
└── images/
    ├── logo.png
    └── placeholder.png
```

Configuração no `pubspec.yaml`:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter/Inter-Bold.ttf
          weight: 700
```

## Dependências (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.0
  get_it: ^7.6.0
  dio: ^5.3.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  share_plus: ^7.0.0
  cached_network_image: ^3.2.0
  go_router: ^12.0.0
  json_annotation: ^4.8.0
  connectivity_plus: ^5.0.0
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
  mocktail: ^1.0.0
  flutter_lints: ^3.0.0
```

## Estrutura de Testes

```
test/
├── domain/
│   └── usecases/
│       └── get_movies_test.dart
├── data/
│   └── repositories/
│       └── movie_repository_test.dart
├── features/
│   └── movies/
│       ├── home/
│       │   ├── home_viewmodel_test.dart
│       │   └── home_screen_test.dart
│       └── shared/
│           └── widgets/
│               └── movie_card_test.dart
└── integration/
    └── home_flow_test.dart
```

## Convenções

### Nomenclatura

| Tipo                     | Convenção                          | Exemplo                 |
| ------------------------ | ---------------------------------- | ----------------------- |
| Arquivos                 | `snake_case`                       | `movie_card.dart`       |
| Classes                  | `PascalCase`                       | `HomeViewModel`         |
| Métodos/Variáveis        | `camelCase`                        | `getNowPlaying`         |
| Constantes               | `camelCase`                        | `baseUrl`               |
| Entidades                | Substantivo                        | `Movie`                 |
| ViewModels               | `Nome + ViewModel`                 | `HomeViewModel`         |
| Repositórios (interface) | `Nome + Repository`                | `MovieRepository`       |
| Repositórios (impl)      | `Nome + RepositoryImpl`            | `MovieRepositoryImpl`   |
| Data sources             | `Nome + Remote/Local + DataSource` | `MovieRemoteDataSource` |

### Organização de Imports

```dart
// 1. SDK
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';

// 3. Pacotes externos
import 'package:dio/dio.dart';

// 4. Core
import 'package:fluttmov/core/theme/app_theme.dart';

// 5. Domain
import 'package:fluttmov/domain/entities/movie.dart';

// 6. Data
import 'package:fluttmov/data/models/movie_model.dart';

// 7. Feature
import 'package:fluttmov/features/movies/shared/widgets/movie_card.dart';
```

## Resumo das Telas

| Tela      | Rota         | ViewModel            | Responsabilidade                          |
| --------- | ------------ | -------------------- | ----------------------------------------- |
| Home      | `/`          | `HomeViewModel`      | Carrossel now playing + grid popular      |
| Detalhes  | `/movie/:id` | `DetailViewModel`    | Info completa + elenco + favorito + share |
| Favoritos | `/favorites` | `FavoritesViewModel` | Grid de filmes salvos offline             |
