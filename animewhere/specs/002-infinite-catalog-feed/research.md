# Research Notes: Infinite Catalog Feed

**Date**: 2026-08-14
**Scope**: Phase 0 research for `plan.md` - resolves every unknown in the
Technical Context and pins design decisions for Phase 1.

## 1. Home composition: three provider sections

- **Decision**: The Home screen is rebuilt as three independent sections
  labeled `jikan`, `anilist`, and `kitsu`, in that fixed order (FR-001). Each
  section renders a featured carousel followed by two horizontally scrollable
  recommendation rows (FR-002). The previous single-carousel/four-row home is
  removed.
- **Rationale**: The user explicitly named the three section titles and the
  carousel + two scrolls shape per provider. Grouping by provider maps each
  section to one adapter (like the existing one-API-per-part decision),
  avoids cross-source identity/de-duplication, and makes provider failures
  naturally isolated (FR-008).
- **Alternatives considered**:
  - Keep the current one-carousel home and only make rows infinite (rejected:
    contradicts the three-labeled-sections requirement).
  - Interleave lists from all providers under one section (rejected: forces
    cross-source dedup and blurs the per-provider identity the user asked for).

## 2. Per-provider row assignment (two recommendation rows each)

- **Decision**:
  - **jikan** (REST): carousel = `GET /top/anime?limit=10`; row 1 = `GET
    /seasons/now` (seasonal); row 2 = `GET /seasons/upcoming` (new endpoint
    added to `JikanApi`).
  - **anilist** (GraphQL): carousel = `Page(perPage:10, sort:TRENDING_DESC)`;
    row 1 = `Page(perPage:10, sort:POPULARITY_DESC)`; row 2 = new
    `Page(perPage:10, sort:SCORE_DESC)` (new `topRatedAnime` method).
  - **kitsu** (REST): carousel = `GET /edge/manga?sort=-popularityRank`;
    row 1 = same manga list (paginated); row 2 = new `GET /edge/anime?sort=
    -popularityRank` (new `anime()` method).
- **Rationale**: Each provider's two rows use distinct ranked lists already
  offered by that provider (seasonal vs. upcoming; popularity vs. rating vs.
  trending), giving visual variety without inventing a recommendation
  algorithm. New endpoints reuse existing mappers and the existing `Title`
  model, so no new domain concepts are introduced.
- **Alternatives considered**: Same list twice with different pages (rejected:
  duplicate-looking UI); Kitsu anime excluded (rejected: kitsu needs two
  distinct scrolls and anime is its natural second catalog).

## 3. Pagination mechanics per API

- **Decision**:
  - **Jikan**: add `page` (1-based) to `topAnime`/`seasonsNow` and the new
    `seasonsUpcoming`; keep `limit` (default 10 for rows/carousels).
  - **AniList**: add `page` variable to the `Page` query; perPage stays 10 for
    all feeds (trending, popular, top-rated).
  - **Kitsu**: switch from `page[limit]`-only to `page[limit]` + `page[offset]`
    (offset = `page * 10`), which is simpler and stable for infinite lists than
    cursor paging.
- **Rationale**: All three providers document simple page/offset pagination.
  Jikan and AniList expose 1-based `page`; Kitsu exposes both
  `page[number]` and `page[offset]` — offset is chosen to avoid any ambiguity
  about page boundaries. Page size is pinned to 10 everywhere so rows extend
  by exactly 10 titles per load (FR-005).
- **Alternatives considered**: cursor/token paging (rejected: not offered by
  these providers without extra calls); Kitsu `page[number]` (rejected: offset
  is explicit and testable).

## 4. End-of-catalog detection (hasMore)

- **Decision**: A page has more titles iff the returned list length equals the
  requested page size (10). A page with fewer than 10 items (or empty) marks
  the row as exhausted. This is evaluated in the repository, not the UI.
- **Rationale**: Simple, provider-agnostic, and testable with fixture pages of
  exactly/less-than 10 items (SC-003, FR-007). Jikan/AniList/Kitsu all
  silently return short final pages rather than a reliable "last page" flag.
- **Alternatives considered**: reading provider pagination metadata
  (Jikan `pagination.has_next_page`, AniList `PageInfo.hasNextPage`, Kitsu
  `meta.count`) (rejected: three different schemas, and length-based detection
  is uniform and sufficient for 10-item pages).

## 5. Repository contract & caching (per-page)

- **Decision**: `CatalogRepository` exposes page-based accessors returning
  `Result<TitlePage>` where `TitlePage { List<Title> titles; bool hasMore; }`.
  Each page is cached under `"<feed>:<page>"` with the existing 5-minute TTL;
  carousels cache under `"<feed>:carousel"`. Cache hits short-circuit the
  request; refresh/`loadMore` for an already-fetched page returns cached data.
- **Rationale**: Reuses the existing TTL cache (respects rate limits) while
  making each page independently cacheable (FR-003, FR-005). Keeping
  `hasMore` in the repository keeps the ViewModel simple.
- **Alternatives considered**: caching whole feeds and slicing locally
  (rejected: defeats the 10-at-a-time rate-limit protection); no caching
  (rejected: violates SC-001 and invites 429s on rapid infinite scrolling).

## 6. Infinite-row ViewModel & single-flight (FR-006, FR-011)

- **Decision**: `HomeViewModel` owns one `SectionState` per provider and each
  holds an `InfiniteRowState` per row. `loadMore(section, row)` guards with an
  `isLoadingMore` flag (one in-flight request per row), appends non-duplicate
  titles keyed by `(source, id)`, and flips `hasMore` off at exhaustion.
  Initial section load fetches all carousels + first row pages concurrently
  (`Future.wait`), each failing independently.
- **Rationale**: A single flag per row gives FR-006 for free under rapid
  scrolling; append-with-dedup satisfies FR-011; per-section isolation
  satisfies FR-008. Unidirectional flow is preserved (UI -> VM -> repository).
- **Alternatives considered**: a `ScrollController`-based widget that fires
  `loadMore` per pixel event (rejected: needs the VM single-flight guard
  anyway and would duplicate state); a paging package (rejected: not justified
  for horizontal rows).

## 7. Infinite-row UI trigger

- **Decision**: `InfiniteTitleRow` is a horizontally scrollable `ListView`
  driven by the accumulated `List<Title>`; a `ScrollController` listener
  triggers `onLoadMore` when the user scrolls within ~200px of the row's max
  extent while `hasMore` is true and the row is not already loading. While a
  page loads, a trailing mini-spinner shows; at exhaustion, a quiet end marker
  appears once (no perpetual spinner, FR-007). Row-level error surfaces with a
  retry affordance (FR-009).
- **Rationale**: Standard infinite-scroll pattern; the threshold keeps requests
  ahead of the user (SC-003) while the single-flight guard prevents duplicate
  loads (FR-006). Design tokens (spacing, glassmorphism, 2:3 cards) are reused
  from the existing `TitleRow`/`TitleCard`.
- **Alternatives considered**: `Scrollbar` + `ListView` with `NotificationListener`
  (same effect, more boilerplate); paging widget packages (rejected above).

## 8. Kitsu kind derivation

- **Decision**: The Kitsu mapper derives `Title.kind` from the JSON:API item's
  top-level `type` field (`anime` vs `manga`) instead of hardcoding `manga`.
  Existing manga fixtures remain valid; new anime fixtures pin the mapping.
- **Rationale**: The new `GET /edge/anime` feed must yield `TitleKind.anime`
  so detail/share behavior matches the source (FR-010). The response already
  carries `type` at the item level, so no extra call is needed.
- **Alternatives considered**: separate anime/manga mappers (rejected:
  unnecessary duplication; one mapper keyed on `type` is enough).

## 9. Design tokens (stitch/animewhere/DESIGN.md)

- **Decision**: Reuse the existing theme one-to-one. Section headers use
  `headlineMd`/`labelMd` tokens; the carousel reuses `TitleCarousel` unchanged;
  rows reuse 2:3 poster cards, 8px spacing rhythm, and glass accents. No new
  tokens are introduced.
- **Rationale**: Constitution Principle III (Design-System Fidelity) is
  non-negotiable; the section layout is a composition of existing components,
  so no re-derivation is needed.
- **Alternatives considered**: new section-specific styling (rejected: deviates
  from the mockups for no user value).

## 10. Dependencies

- **Decision**: No new dependencies. Pagination, caching, and infinite-scroll
  are implemented with existing `http`, `provider`, `go_router`,
  `cached_network_image`, and the SDK's `flutter_test`/`integration_test`.
- **Rationale**: The feature is a data/UI composition change; adding a
  pagination or paging-scroll package would increase surface without benefit.
