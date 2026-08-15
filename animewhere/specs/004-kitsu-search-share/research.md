# Research: Kitsu Section Verification & Share Branding

## Phase 0: Research Objectives

1. Confirm the correct Kitsu JSON:API request/response contract
   (`https://kitsu.io/api/edge`) per the official API documentation so the
   Kitsu carousel and infinite-scroll rows work against the live API.
2. Audit the current Kitsu section code (`lib/data/sources/kitsu/` +
   `lib/ui/home/` Kitsu wiring) for conformance with that contract.
3. Audit the existing share flow to determine how to add app branding
   (image + name "AW - AnimeWhere") and a download link.

## Findings

### 1. Kitsu API Contract (from https://kitsu.docs.apiary.io/)

- **Base**: `https://kitsu.io/api/edge`
- **Protocol**: JSON:API 1.0; Kitsu serves `Content-Type: application/vnd.api+json`
  and expects requests to accept JSON:API media type.
- **Headers**: Kitsu requires a **`User-Agent`** header on every request.
  Requests without a real User-Agent are aggressively rate limited /
  rejected. This is the most likely reason the Kitsu section fails live
  while tests (which mock HTTP) pass.
- **List endpoints** (used by carousel + rows):
  - `GET /anime` — attributes include `slug`, `canonicalTitle`, `titles`,
    `averageRating`, `posterImage` (object with `original/large/medium/small/tiny`),
    `subtype`, `episodeCount`.
  - `GET /manga` — same shape; attributes include `chapterCount`.
  - **Pagination**: `page[limit]` (default 10, max 20) and `page[offset]`.
  - **Sorting**: `sort=-popularityRank` (descending) is a valid documented sort.
  - **Search/filter**: `filter[text]=...`, `filter[season]=...`, etc.
- **Detail endpoint**: `GET /anime/{id}` and `GET /manga/{id}`. The resource
  `type` in the returned `data` object is the source of truth for which
  collection a record belongs to.

### 2. Audit: Current Kitsu section vs. the documented contract

| Area | Current state | Verdict |
|------|---------------|---------|
| `GET /anime` `/GET /manga` + `sort=-popularityRank` | `kitsu_api.dart:16-38` | Conforms |
| Pagination `page[limit]`/`page[offset]` | `kitsu_api.dart` uses offset math | Conforms (offset = page*10; limit is fixed at 10) |
| Detail endpoint | `detail()` always hits `/manga/{id}` (`kitsu_api.dart:41`) | **Defect** — anime titles 404 |
| `User-Agent` header | `AppHttpClient` sends only `Accept: application/json` (`http_client.dart:14-16`) | **Defect** — Kitsu requires a User-Agent |
| JSON:API Accept header | `Accept: application/json` | **Mismatch** — should be `application/vnd.api+json` |
| Poster fallback | `_posterImageUrl` falls back original→large→medium→small→tiny | Conforms |
| Carousel + rows wired to `manga()/anime()` | `catalog_repository.dart:65-75`, `home_view_model.dart` | Conforms |

### 3. Kitsu section wiring

- `HomeViewModel` (lib/ui/home/home_view_model.dart) builds the `kitsu`
  section with a carousel plus two infinite rows (Manga, Anime), driven by
  `CatalogRepository.kitsuCarousel()/kitsuManga()/kitsuAnime()`.
- `CatalogRepository` (lib/data/repositories/catalog_repository.dart) caches
  pages with a 5-minute TTL and caps `hasMore` when a page returns fewer than
  10 titles — the end-of-catalog stop is already implemented.
- Failure isolation already exists per section: a failing Kitsu request yields
  a per-section retry state without blocking Jikan/AniList.

### 4. Share flow (US2 target)

- `ShareService.shareTitle` (lib/ui/share/share_service.dart) currently shares
  only the title's share URL via `share_plus`.
- `ShareRepository.targetFor(title)` (lib/data/repositories/share_repository.dart)
  produces the share URL; the app also has a web share-preview
  (`lib/ui/web/share_preview/share_preview_view.dart`) that renders the shared
  page.
- **Gap**: no app image, no app name, no download link in shared content.
  US2 requires adding the app icon/branding, the name "AW - AnimeWhere", and a
  download link to the shared content.

## Recommended Approach

- **US1**: Add a `User-Agent` header (and JSON:API Accept) to the Kitsu
  requests only — via a Kitsu-scoped header set on the requests made in
  `kitsu_api.dart` (avoids touching the shared HTTP client / other sections),
  and fix `detail()` to route by the returned resource `type`. Extend the
  existing `kitsu_api_test.dart` with header + type-routing coverage.
- **US2**: Extend `ShareService`/`ShareRepository` so shared content includes
  the app name, a download link, and the app image (platform share sheets that
  support images; text fallback keeps name + link).
