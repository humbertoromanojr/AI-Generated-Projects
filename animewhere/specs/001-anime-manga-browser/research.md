# Research Notes: Anime & Manga Browser

**Date**: 2026-08-14
**Scope**: Phase 0 research for `plan.md` - resolves every unknown in the
Technical Context and pins design decisions for Phase 1.

## 1. Part-to-API mapping (the "three parts")

- **Decision**: Part 1 = Jikan (REST) powers the featured carousel (top anime)
  and the Latest/Simulcast row (seasonal anime). Part 2 = AniList (GraphQL)
  powers the Trending and Popular anime rows. Part 3 = Kitsu (REST) powers the
  manga rows. Each title's detail view and share preview fetch from the same
  source that supplied it.
- **Rationale**: The spec's home layout is a carousel plus three rows, and the
  user specified one API per app part; this mapping gives each adapter a single
  responsibility, avoids cross-source de-duplication, and keeps requests
  small. Jikan has canonical top/seasonal endpoints, AniList has native
  TRENDING/POPULARITY sorts, and Kitsu has strong manga data with poster art.
- **Alternatives considered**:
  - Aggregate all three sources into one unified feed - rejected: forces
    identity/de-duplication logic across providers for no user value in a
    simple app.
  - One API per screen - rejected: leaves two of the three APIs unused on the
    home screen and weakens the detail experience.

## 2. Jikan API (https://api.jikan.moe/v4)

- **Decision**: Use REST `GET /top/anime` (carousel), `GET /seasons/now`
  (latest/simulcast), and `GET /anime/{id}` (detail + share preview). Response
  envelope is `{ "data": [...] }`; items carry `mal_id`, `title`,
  `images.jpg.large_image_url`, `score`, `synopsis`, `type`, `season`, `year`.
- **Rationale**: Documented, stable v4 REST; no API key required; official
  limits are 3 req/s and 60 req/min.
- **Alternatives considered**: `/anime?order_by=score` (rejected: `/top` is the
  canonical ranking endpoint).

## 3. AniList GraphQL (https://graphql.anilist.co)

- **Decision**: HTTP POST a single GraphQL document using `Page { media }`
  with `sort: TRENDING_DESC` and `sort: POPULARITY_DESC` (`type: ANIME`) for
  the two anime rows, and `Media(id: $id)` for detail/share previews. Map `id`,
  `title { romaji, english }`, `coverImage { large }`, `description`,
  `averageScore`, `format`, `seasonYear`.
- **Rationale**: GraphQL lets the app request exactly the rendered fields,
  keeping payloads small; AniList is the richest anime metadata source. A
  plain HTTP POST avoids a GraphQL client dependency, keeping the dependency
  surface minimal and stable.
- **Alternatives considered**: `graphql`/`graphql_flutter` packages (rejected:
  heavy, codegen not justified for two queries); a REST mirror (n/a - AniList
  is GraphQL-only).

## 4. Kitsu API (https://kitsu.io/api/edge)

- **Decision**: Use `GET /edge/manga` with `sort=-popularityRank` and
  `page[limit]` for the manga rows, and `GET /edge/{anime|manga}/{id}` for
  detail/share previews. Map `id` and `attributes { slug, canonicalTitle,
  synopsis, averageRating, subtype, posterImage { original } }`.
- **Rationale**: Documented REST with a JSON:API envelope (`data[].attributes`);
  no API key; ~100 req/min allowance.
- **Alternatives considered**: Kitsu trending endpoint (rejected: monthly/
  seasonal scoped; `-popularityRank` sort is stable).

## 5. Rate limiting, caching & refresh (no database)

- **Decision**: In-memory per-repository cache with a short TTL (5 minutes),
  served while a background refresh runs (FR-009). Row loads issue sequential
  requests and throttle to each API's documented limit. On 429/5xx the cache
  (if any) is served; otherwise a typed error state with retry is shown
  (FR-007, SC-005).
- **Rationale**: No database was specified, and the three APIs have independent
  hard rate limits; a TTL cache keeps the UI responsive (SC-001) and avoids
  hammering providers (SC-005).
- **Alternatives considered**: persistent cache via shared_preferences
  (rejected: contradicts the "no database" constraint); no cache at all
  (rejected: violates SC-001 and invites 429s).

## 6. Share preview hosting (no backend)

- **Decision**: Shared links point to the deployed Flutter **web** build at
  `/title/<source>/<id>` (e.g., `https://animewhere.app/title/anilist/21`).
  Opening the link renders a web page that fetches that title from the matching
  API and displays the title image with the app name "AnimeWhere" below it
  (FR-006, SC-003).
- **Rationale**: The project already scaffolds web support; a pure client-side
  route satisfies "recipient sees image + app name below" with no backend or
  database. A static root page provides base social-preview metadata.
- **Alternatives considered**: serverless/edge function (rejected: introduces a
  backend the user excluded); statically generated pages (rejected: the
  catalog is dynamic). Dynamic per-title Open Graph tags require
  server-side rendering and are documented as an out-of-scope v1 limitation.

## 7. Dependencies

- **Decision**: `http` (all three APIs; AniList via JSON POST), `provider`
  (DI), `go_router` (navigation), `share_plus` (system share sheet),
  `cached_network_image` (poster caching); dev: `flutter_test`,
  `integration_test`, `flutter_lints ^6`.
- **Rationale**: Each dependency is stable, widely used, and minimal; provider
  is the constitution-recommended DI/state mechanism.
- **Alternatives considered**: `dio` (rejected: interceptors/cancellation not
  needed); `graphql_flutter` (rejected: overkill); `riverpod`/`bloc` (rejected:
  constitution recommends provider/ChangeNotifier).

## 8. Theme mapping (stitch/animewhere/DESIGN.md)

- **Decision**: Map DESIGN.md tokens one-to-one: `ColorScheme.fromSeed`
  (primary #adc6ff) with the documented surfaces (surface #131313,
  surface-bright #262626, surface-container-lowest #0e0e0e, 5% white glass
  tint), Inter type scale (display, headline-lg, headline-md, body-lg,
  body-md, label-md, label-sm), radii (sm 0.25rem ... full 9999px), 8px
  spacing rhythm, 2:3 poster ratio, and glassmorphism via `BackdropFilter` for
  navigation surfaces.
- **Rationale**: Constitution Principle III (Design-System Fidelity) is
  non-negotiable; exact token mapping is required.
- **Alternatives considered**: deriving an approximate Material palette
  (rejected: violates the non-negotiable fidelity requirement).
