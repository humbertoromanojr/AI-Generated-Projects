# Arquitetura do FLUTTMOV App Architecture.md

## Visão Geral

Este documento descreve os padrões arquiteturais e decisões de design utilizados no FLUTTMOV App. A aplicação segue os princípios da Clean Architecture com uma abordagem em camadas para manter a separação de responsabilidades, testabilidade e escalabilidade. O app consome a API do The Movie Database (TMDB) para exibir filmes em cartaz, populares, por gênero e detalhes completos, com compartilhamento nativo e armazenamento local de favoritos.

## Padrões Arquiteturais

### Clean Architecture

A aplicação está estruturada seguindo os princípios da Clean Architecture, com separação clara entre as seguintes camadas:

1. **Camada de Apresentação** (`/lib/src/presentation/`)
   - Contém todos os componentes de UI (widgets, páginas)
   - Implementa o padrão MVVM (Model-View-ViewModel) utilizando Cubit/Bloc para gerenciamento de estado
   - Usa ViewModels (Cubits) para gerenciar estado da UI e lógica de apresentação
   - Comunica com a camada de domínio através de casos de uso (usecases)
   - Componentes reutilizáveis como MovieCard, MovieCarousel, ShimmerLoading garantem consistência visual
   - Design System Dark Mode implementado via ThemeData centralizado

2. **Camada de Domínio** (`/lib/src/domain/`)
   - Contém a lógica de negócio e regras da aplicação
   - Define interfaces de repositórios (contratos)
   - Implementa casos de uso específicos: GetNowPlayingMovies, GetPopularMovies, GetMoviesByGenre, GetMovieDetails, GetMovieCredits, ToggleFavorite, ShareMovie, etc.
   - Entidades puras e imutáveis: Movie, MovieDetails, Genre, CastMember, MovieFilter
   - Código Dart puro sem dependências do Flutter ou pacotes externos
   - Utiliza conceitos de programação funcional com tipos Either para tratamento de erros

3. **Camada de Dados** (`/lib/src/data/`)
   - Implementa interfaces de repositórios da camada de domínio
   - Gerencia persistência de dados e comunicação com a API TMDB
   - Fontes de dados remotas: MovieRemoteDataSource, GenreRemoteDataSource (Dio HTTP client)
   - Fontes de dados locais: FavoritesLocalDataSource, CacheLocalDataSource (Hive/AsyncStorage)
   - Contém modelos de dados com serialização JSON (MovieModel, GenreModel, CastModel, etc.)
   - Mapeamento entre modelos (data) e entidades (domain)
   - Gerencia cache de imagens com cached_network_image

### Princípios SOLID Aplicados

- **Single Responsibility**: Cada classe tem uma única responsabilidade (ex: MovieRemoteDataSource apenas chama API)
- **Open/Closed**: Entidades e usecases são extensíveis sem modificação
- **Liskov Substitution**: Interfaces de repositório permitem troca de implementações
- **Interface Segregation**: Repositórios com interfaces específicas (MovieRepository, GenreRepository, FavoritesRepository)
- **Dependency Inversion**: Camadas superiores dependem de abstrações, não de implementações concretas

### Padrões de Design

#### 1. Repository Pattern

- Abstrai fontes de dados remotas (TMDB API) e locais (Hive) por trás de interfaces
- Fornece API limpa para operações de dados
- Implementado no diretório `data/repositories/`
- Exemplo: `MovieRepositoryImpl` implementa `MovieRepository` e orquestra `MovieRemoteDataSource` e `CacheLocalDataSource`

#### 2. Injeção de Dependência

- Usa GetIt como Service Locator para injeção de dependência
- Centralizado em `core/injections/`
- Registra todas as dependências: API client, datasources, repositories, usecases, cubits
- Permite baixo acoplamento e facilita testes unitários com mocks
- Facilita a troca de implementações (ex: mock para testes, real para produção)

#### 3. Data Source Pattern

- Separa fontes de dados remotas (API TMDB) e locais (Hive/AsyncStorage)
- Permite estratégias de cache e fallback
- `MovieRemoteDataSource`: Chamadas HTTP para endpoints como `/movie/now_playing`, `/movie/popular`, `/movie/{id}`
- `FavoritesLocalDataSource`: Persistência offline de filmes favoritos

#### 4. Use Case Pattern

- Cada caso de uso representa uma ação específica do usuário
- Implementados como classes com método `call()` ou `execute()`
- Exemplos: `GetNowPlayingMovies`, `GetMoviesByGenre`, `ToggleFavorite`, `ShareMovie`
- Orquestram a lógica de negócio utilizando repositórios injetados

## Tratamento de Erros

- Usa tipo `Either<Failure, T>` do pacote dartz para tratamento de erros funcionais
- `Failure` como classe base para falhas: `ServerFailure`, `CacheFailure`, `NetworkFailure`
- Exceções customizadas: `ServerException`, `CacheException`, `NoInternetException`
- Mapeamento consistente de exceções para falhas nos repositories
- Relatórios de erro consistentes através das camadas
- Estados de erro na UI com widget `ErrorStateWidget` reutilizável e opção de retry

## Gerenciamento de Estado

- ViewModels implementados como **Cubits** (do pacote flutter_bloc)
- Cada tela possui seu próprio Cubit gerenciando estados específicos
- Estados imutáveis usando anotações `@freezed` ou classes manualmente implementadas
- Estados comuns: `Initial`, `Loading`, `Loaded(data)`, `Error(message)`
- Exemplos de Cubits:
  - `HomeCubit`: Gerencia carrossel (now playing) e grid (popular)
  - `MovieListCubit`: Gerencia catálogo por gênero com scroll infinito
  - `MovieDetailCubit`: Gerencia detalhes do filme, elenco e favorito
  - `FavoritesCubit`: Gerencia lista de favoritos offline
- Usa `BlocBuilder`, `BlocListener` e `BlocConsumer` para atualizações reativas da UI
- Gerenciamento de scroll infinito com paginação via `page` param da API TMDB

## Design System (Dark Mode)

- Tema centralizado em `core/theme/app_theme.dart`
- **Paleta de Cores**:
  - Fundo: Preto profundo (#0D0D0D)
  - Superfícies: Cinza escuro (#1A1A1A)
  - Textos: Branco puro (#FFFFFF)
  - Destaque: Dourado queimado (#E5B143)
  - Textos secundários: Cinza médio (#A0A0A0)
- **Tipografia**: Inter/SF Pro Display (títulos bold, corpo regular)
- **Ícones**: Feather Icons (linha fina, discretos)
- **Bordas**: 8px para cards, 16px para imagens principais
- **Sombras**: Glow suave apenas em destaques e botões
- **Grid System**: Margens de 20px e gutters consistentes
- Componentes seguem o tema via `Theme.of(context)`

## Camada de Rede (API Client)

- **Dio** como cliente HTTP principal
- Configuração centralizada em `core/services/api/tmdb_api_client.dart`
- **Base URL**: `https://api.themoviedb.org/3`
- **Interceptors**:
  - Autenticação: Adiciona `api_key` automaticamente em todas as requisições
  - Idioma: Parâmetro `language=pt-BR` para conteúdo em português
  - Logging: Log de requisições e respostas em debug
  - Error Handling: Mapeamento de erros HTTP para exceções customizadas
- **Endpoints consumidos**:
  - `GET /movie/now_playing` → Carrossel de destaques
  - `GET /movie/popular` → Grid "Em Alta"
  - `GET /trending/movie/week` → Tendências da semana
  - `GET /discover/movie?with_genres={id}` → Filmes por gênero
  - `GET /genre/movie/list` → Lista de gêneros
  - `GET /movie/{id}` → Detalhes do filme
  - `GET /movie/{id}/credits` → Elenco e equipe
  - `GET /movie/{id}/images` → Pôsteres e backdrops

## Armazenamento Local

- **Hive** para armazenamento rápido de favoritos e cache
- **AsyncStorage** como alternativa para dados simples (preferências)
- `FavoritesLocalDataSource`: Gerencia filmes favoritados offline
- `CacheLocalDataSource`: Cache de respostas da API para acesso offline
- Imagens em cache usando `cached_network_image` com configuração de tamanho e TTL

## Compartilhamento Nativo

- **share_plus** para compartilhamento nativo via SO
- Caso de uso `ShareMovie` orquestra a lógica:
  1. Recebe o filme (título e ID)
  2. Constrói a mensagem: _"Olha esse filme que encontrei no FLUTTMOV: [título] - https://www.themoviedb.org/movie/{id}"_
  3. Inclui link de download do app
  4. Aciona a share sheet nativa (WhatsApp, Instagram, Telegram, etc.)

## Navegação e Roteamento

- **GoRouter** para navegação declarativa
- Rotas definidas:
  - `/` → Splash Page
  - `/home` → Home Page (carrossel + grid)
  - `/movie/:genreId` → Movie List Page (catálogo por gênero)
  - `/movie/detail/:movieId` → Movie Detail Page (detalhes + elenco)
  - `/favorites` → Favorites Page (favoritos offline)
- Transições suaves com animações fade + slide
- Deep link para abrir detalhes do filme diretamente

## Dependências

- **Gerenciamento de Estado**: flutter_bloc (Cubit/Bloc)
- **Injeção de Dependência**: GetIt
- **Requisições HTTP**: Dio
- **Programação Funcional**: dartz (Either)
- **Armazenamento Local**: Hive + hive_flutter
- **Compartilhamento**: share_plus
- **Cache de Imagens**: cached_network_image
- **Roteamento**: go_router
- **Serialização JSON**: json_serializable + json_annotation
- **Efeitos de UI**: shimmer (loading skeletons)
- **Verificação de Conexão**: connectivity_plus
- **Componentes de UI**: Widgets customizados + Material Design 3

## Estratégia de Testes

- **Testes Unitários**:
  - Casos de uso (usecases) com repositórios mockados
  - Repositórios com datasources mockados
  - Cubits/ViewModels com usecases mockados
  - Modelos e serialização JSON
- **Testes de Widget**:
  - Componentes reutilizáveis (MovieCard, MovieCarousel, ShimmerLoading)
  - Páginas completas com estados mockados (loading, loaded, error)
  - Verificação de renderização condicional e interações de toque
- **Testes de Integração**:
  - Fluxos completos: Home → Categoria → Detalhes → Compartilhar
  - Navegação entre telas
  - Chamadas à API com mock server
  - Persistência de favoritos offline
- **Ferramentas**:
  - bloc_test para testar Cubits
  - mocktail para criar mocks
  - flutter_test para testes de widget

## Tratamento de Conectividade

- Serviço `ConnectivityService` monitora estado da conexão
- Verificação antes de chamadas à API
- Estados de UI adaptados: offline mode com dados cacheados
- Widget `ErrorStateWidget` com mensagem "Sem conexão" e botão "Tentar novamente"
- Cache de últimas respostas para acesso offline básico

## Performance e Otimização

- **Lazy Loading de Imagens**: cached_network_image com placeholders shimmer
- **Scroll Infinito**: Paginação com `page` param, carregando 20 itens por vez
- **Shimmer Loading**: Feedback visual imediato enquanto dados carregam
- **Const Constructors**: Widgets declarados como const sempre que possível
- **Repaint Boundry**: Isolamento de áreas que não precisam ser repintadas
- **Image Sizes**: Uso de tamanhos adequados de pôsteres TMDB (w500 para cards, w780/w1280 para detalhes)

## Considerações Futuras

- Implementação de analytics (Firebase Analytics ou similar)
- Monitoramento de performance e crash reports (Sentry/Crashlytics)
- Estratégias avançadas de cache com TTL e invalidação
- Suporte a múltiplos idiomas (i18n) usando `intl`
- Expansão para incluir séries de TV usando endpoints `/tv/*`
- Integração com deep links para compartilhamento cross-app
- Testes de acessibilidade (contraste, leitores de tela, touch targets)
- CI/CD pipeline com GitHub Actions para testes automatizados e deploy
