# Estrutura do Projeto FLUTTMOV App

## Organização de Diretórios

```
lib/
├── initialization.dart      # Inicialização e configuração do app
├── main.dart               # Ponto de entrada do Flutter
└── src/
    ├── app.dart           # Widget principal do app (MaterialApp + Tema Dark)
    ├── src.dart           # Arquivo barrel para exports centralizados
    ├── core/             # Funcionalidades e utilitários centrais
    │   ├── config/       # Configuração do app (base URL TMDB, api_key)
    │   ├── constants/    # Constantes e enums (gêneros, endpoints, tamanhos de imagem)
    │   ├── error/        # Tratamento de erros (exceções customizadas, falhas de API)
    │   ├── injections/   # Configuração de injeção de dependência (repositórios, services)
    │   ├── services/     # Serviços centrais (API client, compartilhamento, armazenamento)
    │   │   ├── api/             # Cliente HTTP e interceptors para TMDB
    │   │   ├── share/           # Serviço de compartilhamento nativo
    │   │   ├── storage/         # Serviço de armazenamento local (favoritos, cache)
    │   │   └── connectivity/    # Serviço de verificação de conexão
    │   ├── theme/        # Tema do app (Dark Mode - cores, tipografia, bordas)
    │   │   ├── app_colors.dart        # Paleta de cores (#0D0D0D, #1A1A1A, #E5B143, etc.)
    │   │   ├── app_typography.dart    # Tipografia (Inter / SF Pro Display)
    │   │   ├── app_icons.dart         # Ícones Feather personalizados
    │   │   └── app_theme.dart         # ThemeData completo do MaterialApp
    │   └── utils/        # Funções utilitárias (formatação de data, nota, URL de imagem)
    │       ├── date_formatter.dart    # Formatação de datas da API
    │       ├── image_url_builder.dart # Construtor de URLs de pôsteres TMDB
    │       └── rating_formatter.dart  # Formatação de notas e estrelas
    │
    ├── data/            # Camada de dados
    │   ├── datasources/ # Implementações de fontes de dados
    │   │   ├── remote/            # Fontes remotas
    │   │   │   ├── movie_remote_datasource.dart    # Chamadas à API TMDB
    │   │   │   ├── genre_remote_datasource.dart    # Chamadas de gêneros
    │   │   │   └── tmdb_api_client.dart            # Cliente HTTP configurado (Dio/http)
    │   │   └── local/             # Fontes locais
    │   │       ├── favorites_local_datasource.dart  # Favoritos no AsyncStorage/Hive
    │   │       └── cache_local_datasource.dart      # Cache de imagens e respostas
    │   ├── models/      # Modelos de dados (DTOs, JSON serialization)
    │   │   ├── movie_model.dart         # Modelo completo do filme
    │   │   ├── movie_summary_model.dart # Modelo resumido (cards e listas)
    │   │   ├── genre_model.dart         # Modelo de gênero
    │   │   ├── cast_model.dart          # Modelo de elenco
    │   │   ├── crew_model.dart          # Modelo de equipe (diretor)
    │   │   └── paginated_response.dart  # Modelo de resposta paginada da API
    │   └── repositories/ # Implementações de repositórios
    │       ├── movie_repository_impl.dart  # Implementação do repositório de filmes
    │       ├── genre_repository_impl.dart  # Implementação do repositório de gêneros
    │       └── favorites_repository_impl.dart # Implementação do repositório de favoritos
    │
    ├── domain/         # Camada de domínio
    │   ├── entities/   # Entidades de negócio (puras, sem dependências externas)
    │   │   ├── movie.dart              # Entidade Movie
    │   │   ├── movie_details.dart      # Entidade MovieDetails
    │   │   ├── genre.dart              # Entidade Genre
    │   │   ├── cast_member.dart        # Entidade CastMember
    │   │   └── movie_filter.dart       # Entidade MovieFilter (gênero, ano, etc.)
    │   ├── repositories/ # Interfaces de repositórios (contratos)
    │   │   ├── movie_repository.dart      # Interface MovieRepository
    │   │   ├── genre_repository.dart      # Interface GenreRepository
    │   │   └── favorites_repository.dart  # Interface FavoritesRepository
    │   └── usecases/   # Casos de uso (lógica de negócio)
    │       ├── get_now_playing_movies.dart  # Buscar filmes em cartaz (carrossel)
    │       ├── get_popular_movies.dart      # Buscar filmes populares (grid)
    │       ├── get_trending_movies.dart     # Buscar tendências da semana
    │       ├── get_movies_by_genre.dart     # Buscar filmes por gênero (catálogo)
    │       ├── get_movie_details.dart       # Buscar detalhes do filme
    │       ├── get_movie_credits.dart       # Buscar elenco e equipe
    │       ├── get_genres.dart              # Buscar lista de gêneros
    │       ├── toggle_favorite.dart         # Adicionar/remover favorito
    │       ├── get_favorites.dart           # Listar favoritos salvos
    │       └── share_movie.dart             # Compartilhar filme
    │
    └── presentation/   # Camada de apresentação
        ├── components/ # Componentes de UI reutilizáveis
        │   ├── movie_card.dart              # Card de filme (grid e lista)
        │   ├── movie_carousel.dart          # Carrossel horizontal automático
        │   ├── page_indicator.dart          # Indicador de página (bolinhas)
        │   ├── genre_banner.dart            # Banner de gênero com parallax
        │   ├── cast_list.dart               # Lista horizontal de elenco (fotos circulares)
        │   ├── rating_stars.dart            # Componente de estrelas de avaliação
        │   ├── shimmer_loading.dart         # Esqueleto de carregamento (shimmer)
        │   ├── error_state_widget.dart      # Widget de estado de erro com retry
        │   ├── empty_state_widget.dart      # Widget de estado vazio
        │   └── bottom_nav_bar.dart          # Barra de navegação inferior fixa
        │
        ├── pages/     # Páginas/telas do app
        │   ├── home/                        # Tela Home
        │   │   └── home_page.dart           # Carrossel + Grid "Em Alta"
        │   ├── movie/                       # Tela Movie (Catálogo por Gênero)
        │   │   └── movie_list_page.dart     # Banner + Lista com scroll infinito
        │   ├── movie_detail/                # Tela MovieDetail
        │   │   └── movie_detail_page.dart   # Pôster + Ficha técnica + Ações
        │   ├── favorites/                   # Tela de Favoritos (opcional)
        │   │   └── favorites_page.dart      # Grid de filmes favoritados
        │   └── splash/                      # Tela de Splash (opcional)
        │       └── splash_page.dart         # Logo + carregamento inicial
        │
        └── viewmodels/ # ViewModels para gerenciamento de estado (Cubit/Bloc/ChangeNotifier)
            ├── home_viewmodel.dart              # Estado da Home (carrossel + grid)
            ├── movie_list_viewmodel.dart        # Estado do catálogo por gênero
            ├── movie_detail_viewmodel.dart      # Estado dos detalhes do filme
            └── favorites_viewmodel.dart         # Estado dos favoritos

assets/               # Assets estáticos
├── fonts/           # Fontes customizadas (Inter, SF Pro Display)
│   ├── Inter-Regular.ttf
│   ├── Inter-Bold.ttf
│   └── Inter-Medium.ttf
├── images/         # Assets de imagem
│   ├── logo.png           # Logo do FLUTTMOV
│   ├── placeholder.png    # Imagem placeholder para carregamento
│   └── splash_bg.png      # Background da splash screen
└── icons/          # Ícones personalizados (se necessário)

docs/               # Documentação do projeto
├── ARCHITECTURE.md # Documentação da arquitetura (Clean Architecture)
├── STRUCTURE.md    # Documentação da estrutura do projeto (este arquivo)
├── FEATURES.md     # Documentação de funcionalidades
├── INDEX.md        # Visão geral do projeto
└── API.md          # Documentação da integração com TMDB

test/              # Arquivos de teste
├── unit/          # Testes unitários
│   ├── data/
│   │   ├── datasources/
│   │   └── repositories/
│   ├── domain/
│   │   └── usecases/
│   └── presentation/
│       └── viewmodels/
├── widget/        # Testes de widget (componentes e páginas)
│   ├── components/
│   └── pages/
└── integration/   # Testes de integração (fluxos completos)
    ├── home_flow_test.dart
    ├── movie_detail_flow_test.dart
    └── share_flow_test.dart
```

## Diretórios e Arquivos Principais

### `lib/`

- Diretório principal do código fonte Flutter
- Contém toda a lógica da aplicação
- Organizado em módulos baseados em Clean Architecture (core, data, domain, presentation)

### `src/core/`

- Contém utilitários e serviços transversais da aplicação
- **config/**: Configurações como base URL da API TMDB e chave de API
- **constants/**: Enums de gêneros, endpoints, tamanhos de imagem TMDB
- **error/**: Exceções customizadas (ServerException, CacheException) e failures
- **injections/**: Registro de dependências com GetIt ou similar
- **services/**: Serviços de API (Dio configurado), compartilhamento nativo, armazenamento local, verificação de conectividade
- **theme/**: Design System Dark Mode completo (cores, tipografia, ícones, ThemeData)
- **utils/**: Funções auxiliares para formatação de datas, construção de URLs de imagens, formatação de notas

### `src/data/`

- Implementa acesso e persistência de dados (remotos e locais)
- **datasources/remote/**: Chamadas HTTP à API TMDB usando Dio/http
- **datasources/local/**: Armazenamento local de favoritos e cache (AsyncStorage, Hive, SharedPreferences)
- **models/**: Modelos com serialização JSON (fromJson/toJson) usando json_serializable ou freezed
- **repositories/**: Implementações concretas das interfaces de repositório do domínio

### `src/domain/`

- Contém lógica de negócio pura, sem dependências externas
- **entities/**: Objetos de negócio imutáveis (Movie, Genre, CastMember, etc.)
- **repositories/**: Interfaces (contratos) que definem operações de dados
- **usecases/**: Casos de uso que orquestram a lógica de negócio (GetNowPlayingMovies, ShareMovie, ToggleFavorite, etc.)

### `src/presentation/`

- Contém todo o código relacionado à UI (Flutter Widgets)
- **components/**: Widgets reutilizáveis em múltiplas telas (MovieCard, MovieCarousel, ShimmerLoading, etc.)
- **pages/**: Telas completas do app (Home, Movie, MovieDetail, Favorites)
- **viewmodels/**: Gerenciamento de estado usando Cubit, Bloc ou ChangeNotifier

### `assets/`

- Armazena recursos estáticos do app
- **fonts/**: Fontes customizadas (Inter, SF Pro Display)
- **images/**: Imagens estáticas (logo, placeholder, splash background)
- **icons/**: Ícones personalizados se necessário

### `docs/`

- Documentação completa do projeto
- **ARCHITECTURE.md**: Explicação detalhada da Clean Architecture aplicada
- **STRUCTURE.md**: Este arquivo, com a estrutura de diretórios
- **FEATURES.md**: Lista completa de funcionalidades
- **INDEX.md**: Visão geral e descrição do projeto
- **API.md**: Documentação dos endpoints TMDB utilizados

### `test/`

- Contém todos os arquivos de teste do projeto
- **unit/**: Testes unitários para usecases, viewmodels, repositories e datasources
- **widget/**: Testes de widget para componentes e páginas
- **integration/**: Testes de integração para fluxos completos (navegação, chamadas API, compartilhamento)

## Convenções de Nomenclatura

### Arquivos Dart

- Use **snake_case** para nomes de arquivos
- Sufixe arquivos baseado no seu tipo:
  - `*_page.dart` para páginas/telas
  - `*_viewmodel.dart` para ViewModels (ou `*_cubit.dart` / `*_bloc.dart`)
  - `*_repository.dart` para repositórios (interfaces e implementações)
  - `*_datasource.dart` para fontes de dados
  - `*_model.dart` para modelos de dados
  - `*_usecase.dart` para casos de uso
  - `*_service.dart` para serviços
  - `*_widget.dart` para componentes de UI reutilizáveis

### Arquivos de Teste

- Espelhe o nome do arquivo sendo testado
- Adicione `_test` ao nome do arquivo
- Exemplos:
  - `home_page_test.dart` (teste de widget)
  - `get_now_playing_movies_test.dart` (teste unitário de usecase)
  - `movie_repository_impl_test.dart` (teste unitário de repository)

### Classes e Métodos

- Use **PascalCase** para nomes de classes, enums e typedefs
- Use **camelCase** para nomes de métodos, variáveis e parâmetros
- Sufixe interfaces de repositórios com o nome da entidade + "Repository" (ex: `MovieRepository`)
- Sufixe implementações com "Impl" (ex: `MovieRepositoryImpl`)
- Use nomes descritivos para usecases seguindo o padrão verbo + substantivo (ex: `GetNowPlayingMovies`, `ToggleFavorite`)

## Organização de Imports

1. Imports do Dart/Flutter SDK
2. Imports de pacotes externos (dependencies)
3. Imports da camada core (config, theme, utils)
4. Imports da camada data (models, datasources)
5. Imports da camada domain (entities, usecases)
6. Imports da camada presentation (components, pages)
7. Imports relativos (para arquivos no mesmo diretório)

## Arquivos de Export (Barrel Files)

- Cada diretório contém um arquivo barrel (ex: `src.dart`, `pages.dart`, `components.dart`)
- Exporta todas as APIs públicas do diretório
- Simplifica imports em outras partes da aplicação
- Exemplo do `src/presentation/components/components.dart`:
  ```dart
  export 'movie_card.dart';
  export 'movie_carousel.dart';
  export 'page_indicator.dart';
  export 'shimmer_loading.dart';
  // ... etc
  ```

## Pacotes e Dependências Principais (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  # Gerenciamento de Estado
  flutter_bloc: ^8.1.0 # Cubit/Bloc
  # Injeção de Dependência
  get_it: ^7.6.0 # Service Locator
  # Requisições HTTP
  dio: ^5.3.0 # Cliente HTTP para API TMDB
  # Armazenamento Local
  hive: ^2.2.3 # Banco local rápido
  hive_flutter: ^1.1.0 # Extensões Hive para Flutter
  # Compartilhamento
  share_plus: ^7.0.0 # API nativa de compartilhamento
  # Imagens
  cached_network_image: ^3.2.0 # Cache de imagens dos pôsteres
  # Roteamento
  go_router: ^12.0.0 # Navegação declarativa
  # Serialização JSON
  json_annotation: ^4.8.0 # Anotações para geração de código
  # Utilitários
  connectivity_plus: ^5.0.0 # Verificação de conexão
  shimmer: ^3.0.0 # Efeito shimmer loading

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0 # Geração de código
  json_serializable: ^6.7.0 # Geração de serialização JSON
  bloc_test: ^9.1.0 # Testes para Bloc/Cubit
  mocktail: ^1.0.0 # Mocking para testes
  flutter_lints: ^3.0.0 # Análise estática
```
