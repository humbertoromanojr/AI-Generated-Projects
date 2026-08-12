# Arquitetura do FLUTTMOV App

## Visão Geral

Este documento descreve a arquitetura do FLUTTMOV App seguindo as recomendações oficiais do Flutter para design de aplicações. A aplicação consome a API do The Movie Database (TMDB) para exibir filmes em cartaz, populares, por gênero e detalhes completos, com compartilhamento nativo e armazenamento local de favoritos. A arquitetura é centrada em **separação de responsabilidades**, **fluxo de dados unidirecional (UDF)** e **testabilidade**, utilizando padrões documentados em [docs.flutter.dev/app-architecture](https://docs.flutter.dev/app-architecture).

## Princípios Fundamentais

A documentação oficial do Flutter estabelece cinco princípios-chave que guiam esta arquitetura:

1. **Separação de Responsabilidades**: Cada classe tem um propósito único e bem definido
2. **Fluxo de Dados Unidirecional (UDF)**: Estado flui para baixo, eventos fluem para cima
3. **Gerenciamento de Estado Reativo**: UI reage automaticamente a mudanças de estado
4. **Injeção de Dependência**: Dependências são fornecidas, não criadas internamente
5. **Testabilidade**: Todas as camadas são testáveis isoladamente

## Estrutura de Camadas

Seguindo o modelo de camadas recomendado, a aplicação é dividida em três camadas distintas com responsabilidades claras:

```
┌─────────────────────────────────────────┐
│         Camada de UI (Presentation)      │
│  Widgets, Páginas, Temas, Design System  │
├─────────────────────────────────────────┤
│      Camada de Lógica de Negócio         │
│  ViewModels (Cubits), Casos de Uso       │
├─────────────────────────────────────────┤
│         Camada de Dados                  │
│  Repositórios, Data Sources, Modelos     │
└─────────────────────────────────────────┘
```

### Camada de UI (`/lib/src/presentation/`)

**Responsabilidade**: Renderizar a interface e reagir a eventos do usuário.

- Contém widgets, páginas e componentes reutilizáveis
- Implementa o padrão **MVVM** utilizando **Cubit** como ViewModel
- Utiliza `BlocBuilder`, `BlocListener` e `BlocConsumer` para observação reativa de estado
- Componentes: `MovieCard`, `MovieCarousel`, `ShimmerLoading`, `ErrorStateWidget`
- **Design System Dark Mode**: `ThemeData` centralizado em `core/theme/app_theme.dart`
- **Não contém lógica de negócio** — apenas renderiza estado e dispara eventos

**Fluxo na UI:**

```dart
// Exemplo: HomePage observa HomeCubit
BlocBuilder<HomeCubit, HomeState>(
  builder: (context, state) {
    return switch (state) {
      HomeInitial() => const SizedBox(),
      HomeLoading() => const ShimmerCarousel(),
      HomeLoaded(nowPlaying, popular) => HomeContent(
        nowPlaying: nowPlaying,
        popular: popular,
      ),
      HomeError(message) => ErrorStateWidget(
        message: message,
        onRetry: () => context.read<HomeCubit>().loadHome(),
      ),
    };
  },
)
```

### Camada de Lógica de Negócio (`/lib/src/domain/` e ViewModels)

**Responsabilidade**: Orquestrar operações, manter estado da UI, aplicar regras de negócio.

Esta camada é dividida em dois componentes complementares:

#### ViewModels (Cubits)

Os ViewModels gerenciam o estado da UI e expõem comandos. Seguindo o UDF:

- **Estado** (State): Imutável, desce para a UI
- **Comandos** (Eventos): Disparados pela UI, sobem para o ViewModel
- **Notificações**: ViewModel notifica mudanças de estado, UI reconstrói

```dart
// Exemplo de ViewModel com Cubit
class MovieDetailCubit extends Cubit<MovieDetailState> {
  final GetMovieDetails _getMovieDetails;
  final ToggleFavorite _toggleFavorite;

  MovieDetailCubit(this._getMovieDetails, this._toggleFavorite)
    : super(MovieDetailInitial());

  // Comando disparado pela UI
  Future<void> loadMovieDetails(int movieId) async {
    emit(MovieDetailLoading());
    final result = await _getMovieDetails(movieId);
    result.fold(
      (failure) => emit(MovieDetailError(failure.message)),
      (movie) => emit(MovieDetailLoaded(movie)),
    );
  }
}
```

#### Casos de Uso

Cada ação de negócio é encapsulada em uma classe de caso de uso com método `call()`:

- `GetNowPlayingMovies`
- `GetPopularMovies`
- `GetMoviesByGenre`
- `GetMovieDetails`
- `GetMovieCredits`
- `ToggleFavorite`
- `ShareMovie`

```dart
class GetNowPlayingMovies {
  final MovieRepository _repository;
  GetNowPlayingMovies(this._repository);

  Future<Either<Failure, List<Movie>>> call({int page = 1}) {
    return _repository.getNowPlaying(page: page);
  }
}
```

#### Entidades

Classes puras e imutáveis que representam conceitos de negócio:

- `Movie`, `MovieDetails`, `Genre`, `CastMember`, `MovieFilter`
- Código Dart puro — zero dependências do Flutter ou pacotes externos

### Camada de Dados (`/lib/src/data/`)

**Responsabilidade**: Persistência, comunicação com APIs externas e adaptação de dados.

#### Repositórios

Implementam interfaces definidas na camada de domínio. Orquestram múltiplas fontes de dados:

```dart
class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;
  final CacheLocalDataSource _cacheDataSource;
  final ConnectivityService _connectivity;

  MovieRepositoryImpl(
    this._remoteDataSource,
    this._cacheDataSource,
    this._connectivity,
  );

  @override
  Future<Either<Failure, List<Movie>>> getNowPlaying({int page = 1}) async {
    if (await _connectivity.isConnected) {
      try {
        final movies = await _remoteDataSource.getNowPlaying(page: page);
        await _cacheDataSource.cacheNowPlaying(movies, page);
        return Right(movies.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      try {
        final cached = await _cacheDataSource.getCachedNowPlaying(page);
        return Right(cached.map((model) => model.toEntity()).toList());
      } catch (e) {
        return Left(CacheFailure('Sem conexão e sem cache disponível'));
      }
    }
  }
}
```

#### Data Sources

Separação clara entre fontes de dados remotas e locais:

**Remotas:**

- `MovieRemoteDataSource`: Chamadas HTTP para TMDB API via Dio
- `GenreRemoteDataSource`: Lista de gêneros da TMDB API

**Locais:**

- `FavoritesLocalDataSource`: Persistência offline de favoritos com Hive
- `CacheLocalDataSource`: Cache de respostas para acesso offline

#### Modelos de Dados

Classes com serialização JSON que adaptam dados externos para o domínio:

```dart
// Data Model - camada de dados
@JsonSerializable()
class MovieModel {
  final int id;
  final String title;
  final String? posterPath;

  MovieModel({required this.id, required this.title, this.posterPath});

  factory MovieModel.fromJson(Map<String, dynamic> json) =>
      _$MovieModelFromJson(json);

  // Mapeamento para entidade de domínio
  Movie toEntity() => Movie(
    id: id,
    title: title,
    posterUrl: posterPath != null
      ? 'https://image.tmdb.org/t/p/w500$posterPath'
      : null,
  );
}
```

## Fluxo de Dados Unidirecional (UDF)

O UDF é o padrão central da arquitetura recomendada. No FLUTTMOV:

```
┌──────────┐    Comandos (eventos)    ┌───────────────┐
│          │ ──────────────────────→  │               │
│   UI     │                          │   ViewModel   │
│ (Widgets)│ ←──────────────────────  │   (Cubit)     │
│          │    Estado (State)        │               │
└──────────┘                          └───────┬───────┘
                                              │
                                              │ Chamadas
                                              ↓
                                      ┌───────────────┐
                                      │   Casos de    │
                                      │     Uso       │
                                      └───────┬───────┘
                                              │
                                              │ Orquestração
                                              ↓
                                      ┌───────────────┐
                                      │  Repositório  │
                                      └───────┬───────┘
                                              │
                                        ┌─────┴─────┐
                                        ↓           ↓
                                  ┌─────────┐ ┌─────────┐
                                  │ Remoto  │ │ Local   │
                                  │ (TMDB)  │ │ (Hive)  │
                                  └─────────┘ └─────────┘
```

1. **UI dispara comando**: `context.read<HomeCubit>().loadHome()`
2. **ViewModel processa**: Emite estado `Loading`, chama caso de uso
3. **Caso de uso orquestra**: Delega ao repositório
4. **Repositório decide fonte**: Remota (online) ou Local (offline/cache)
5. **Dado retorna**: Entidade sobe pelas camadas
6. **ViewModel emite novo estado**: UI reconstrói automaticamente

## Gerenciamento de Estado

### ViewModels com Cubit

Cada tela possui seu próprio ViewModel (Cubit) gerenciando estados imutáveis:

- **`HomeCubit`**: Gerencia carrossel (now playing) e grid (popular)
- **`MovieListCubit`**: Catálogo por gênero com scroll infinito e paginação
- **`MovieDetailCubit`**: Detalhes do filme, elenco e estado de favorito
- **`FavoritesCubit`**: Lista de favoritos offline com atualização reativa

### Estados Imutáveis

Estados são modelados como sealed classes (Dart 3) ou classes concretas:

```dart
sealed class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final List<Movie> nowPlaying;
  final List<Movie> popular;
  HomeLoaded({required this.nowPlaying, required this.popular});
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}
```

### Observação Reativa

- `BlocBuilder`: Reconstrói widgets com base em novos estados
- `BlocListener`: Executa efeitos colaterais (snackbars, navegação)
- `BlocConsumer`: Combina ambos quando necessário

## Injeção de Dependência

Seguindo a recomendação oficial de fornecer dependências, utilizamos **GetIt** como service locator:

```dart
// core/injections/injection_container.dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  // API Client
  sl.registerLazySingleton<Dio>(() => TMDBApiClient.create());

  // Data Sources
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => MovieRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(hive: sl()),
  );

  // Repositories
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(
      remoteDataSource: sl(),
      cacheDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNowPlayingMovies(sl()));
  sl.registerLazySingleton(() => GetPopularMovies(sl()));

  // ViewModels (Cubits)
  sl.registerFactory(() => HomeCubit(
    getNowPlaying: sl(),
    getPopular: sl(),
  ));
}
```

**ViewModels são `registerFactory`** (nova instância por tela).  
**Repositórios e Data Sources são `registerLazySingleton`** (instância única).

## Design System (Dark Mode)

Tema centralizado como recomendado, acessível via `Theme.of(context)`:

**Paleta de Cores:**

- Fundo: Preto profundo (`#0D0D0D`)
- Superfícies: Cinza escuro (`#1A1A1A`)
- Textos: Branco puro (`#FFFFFF`)
- Destaque: Dourado queimado (`#E5B143`)
- Textos secundários: Cinza médio (`#A0A0A0`)

**Tipografia**: Inter / SF Pro Display (títulos bold, corpo regular)  
**Ícones**: Feather Icons (linha fina, discretos)  
**Bordas**: 8px cards, 16px imagens principais  
**Sombras**: Glow suave em destaques e botões  
**Grid**: Margens de 20px, gutters consistentes

```dart
// core/theme/app_theme.dart
ThemeData get darkTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF0D0D0D),
  colorScheme: const ColorScheme.dark(
    surface: Color(0xFF1A1A1A),
    primary: Color(0xFFE5B143),
  ),
  textTheme: GoogleFonts.interTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
);
```

## Camada de Rede

- **Dio** como cliente HTTP configurado centralizadamente
- **Base URL**: `https://api.themoviedb.org/3`
- **Interceptors**: Autenticação (`api_key`), idioma (`language=pt-BR`), logging, tratamento de erros
- **Endpoints**:
  - `GET /movie/now_playing` → Carrossel de destaques
  - `GET /movie/popular` → Grid "Em Alta"
  - `GET /trending/movie/week` → Tendências
  - `GET /discover/movie?with_genres={id}` → Filmes por gênero
  - `GET /genre/movie/list` → Lista de gêneros
  - `GET /movie/{id}` → Detalhes
  - `GET /movie/{id}/credits` → Elenco

## Armazenamento Local

- **Hive**: Armazenamento rápido de favoritos e cache
- **AsyncStorage**: Preferências simples
- **cached_network_image**: Cache de imagens com TTL e redimensionamento

## Tratamento de Erros

Erros são tratados funcionalmente com o tipo `Either<Failure, T>` e mapeados para estados de UI:

```dart
// Exemplo no repositório
try {
  final data = await remoteDataSource.fetch();
  return Right(data.toEntity());
} on ServerException {
  return Left(ServerFailure());
} on NetworkException {
  return Left(NetworkFailure('Sem conexão'));
}

// Na UI
state.map(
  error: (e) => ErrorStateWidget(
    message: e.message,
    onRetry: () => viewModel.retry(),
  ),
);
```

## Compartilhamento Nativo

Caso de uso `ShareMovie` seguindo UDF:

1. UI dispara: `context.read<MovieDetailCubit>().shareMovie()`
2. ViewModel chama caso de uso
3. Caso de uso constrói mensagem e aciona `share_plus`
4. Share sheet nativa é exibida (WhatsApp, Instagram, Telegram)

## Navegação

- **GoRouter** para navegação declarativa com deep links
- Rotas:
  - `/` → Splash
  - `/home` → Home (carrossel + grid)
  - `/movie/:genreId` → Catálogo por gênero
  - `/movie/detail/:movieId` → Detalhes + elenco
  - `/favorites` → Favoritos offline
- Transições: fade + slide

## Performance

- **`cached_network_image`**: Placeholders shimmer, tamanhos TMDB otimizados (w500, w780, w1280)
- **Scroll infinito**: Paginação de 20 itens por requisição
- **`const` constructors**: Widgets imutáveis sempre que possível
- **Shimmer loading**: Feedback visual imediato
- **`RepaintBoundary`**: Isolamento de áreas estáticas

## Estratégia de Testes

Seguindo a separação em camadas que permite testes isolados:

### Testes Unitários

- **ViewModels (Cubits)**: Testados com `bloc_test` e casos de uso mockados
- **Casos de Uso**: Testados com repositórios mockados
- **Repositórios**: Testados com data sources mockados
- **Modelos**: Testes de serialização/deserialização

```dart
blocTest<HomeCubit, HomeState>(
  'deve emitir [Loading, Loaded] quando carrega com sucesso',
  build: () => HomeCubit(mockGetNowPlaying, mockGetPopular),
  act: (cubit) => cubit.loadHome(),
  expect: () => [
    HomeLoading(),
    HomeLoaded(nowPlaying: mockMovies, popular: mockMovies),
  ],
);
```

### Testes de Widget

- Componentes isolados (`MovieCard`, `ShimmerLoading`)
- Páginas com estados mockados via `BlocProvider.value`
- Interações de toque e navegação

### Testes de Integração

- Fluxos completos com mock server
- Persistência offline de favoritos
- Navegação entre telas

## Dependências Principais

| Propósito               | Pacote                 |
| ----------------------- | ---------------------- |
| Gerenciamento de Estado | `flutter_bloc`         |
| Injeção de Dependência  | `get_it`               |
| Requisições HTTP        | `dio`                  |
| Programação Funcional   | `dartz`                |
| Armazenamento Local     | `hive`, `hive_flutter` |
| Compartilhamento        | `share_plus`           |
| Cache de Imagens        | `cached_network_image` |
| Roteamento              | `go_router`            |
| Shimmer Loading         | `shimmer`              |
| Conectividade           | `connectivity_plus`    |

## Considerações Futuras

- Analytics com Firebase Analytics
- Crash reporting com Sentry/Crashlytics
- Cache avançado com TTL e invalidação
- Internacionalização (i18n) com `intl`
- Expansão para séries de TV via `/tv/*`
- CI/CD com GitHub Actions para testes e deploy
- Testes de acessibilidade (contraste, leitores de tela)
