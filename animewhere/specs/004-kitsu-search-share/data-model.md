# Data Model: Kitsu Section Verification & Share Branding

## Entities

### 1. Title (Domain Model) — unchanged
The core unit of content displayed in carousels and rows.
- **Fields**: `id` (String), `source` (`TitleSource`), `kind`
  (`TitleKind.anime|manga`), `title` (String), `imageUrl` (String),
  `description` (String?), `score` (double?), `seasonYear` (int?),
  `format` (String?), `providerUrl` (String?).
- **Kitsu mapping**: `id` ← `data.id`, `kind` ← `data.type` (`anime`→anime,
  anything else→manga), `title` ← `attributes.canonicalTitle`, `imageUrl` ←
  first non-empty of `attributes.posterImage.{original,large,medium,small,tiny}`,
  `score` ← `double.tryParse(attributes.averageRating)`, `format` ←
  `attributes.subtype`, `description` ← `attributes.synopsis`.
- **Validation**: a list/detail record is skipped (not an error) when `id`,
  `canonicalTitle`, or a poster URL is missing/empty.

### 2. TitlePage (Domain Model) — unchanged
Paged collection returned by `CatalogRepository` fetches.
- **Fields**: `titles` (List<Title>), `hasMore` (bool).
- **Kitsu rule**: `hasMore` is true only when a page returns exactly 10 titles
  (`_pageSize` in `catalog_repository.dart`); shorter pages stop infinite scroll.

### 3. KitsuApi (Data Source) — changed
- Requests add a `User-Agent` header and JSON:API `Accept:
  application/vnd.api+json` (currently the shared `AppHttpClient` sends only
  `Accept: application/json` and no User-Agent).
- `manga()` → `GET /anime`-style list at `/manga?sort=-popularityRank&page[limit]=10&page[offset]=N`.
- `anime()` → `/anime?sort=-popularityRank&page[limit]=10&page[offset]=N`.
- `detail(id)` → resolves the collection by the returned resource `type`
  (`anime` vs `manga`) so anime records hit `/anime/{id}` instead of always
  `/manga/{id}` (current defect).

### 4. ShareTarget (Domain Model) — possibly extended
Holds everything needed to share a title.
- **Current fields**: `source` (`TitleSource`), `id` (String), `shareUrl` (String).
- **Planned fields** (for US2): `appName` (String, "AW - AnimeWhere"),
  `appImageUrl` (String? app icon/branding image), `downloadUrl` (String).
- **`ShareRepository.targetFor`** keeps returning a `ShareTarget`; it now also
  populates the app branding fields (name, image, download link).

### 5. Shared Content (Produced Output)
The message/artifact delivered to recipients.
- Contains: the title share URL, the app image (where the platform share sheet
  supports images), the app name "AW - AnimeWhere", and the app download link.
- Text fallback (no-image platforms) still carries the app name and download link.

## Validation Rules

- **Kitsu Header Rule**: every Kitsu request MUST carry a `User-Agent` header
  and `Accept: application/vnd.api+json`; verified by unit tests asserting the
  outgoing request headers.
- **Type Routing Rule**: `detail()` MUST issue `/anime/{id}` when the record
  `type` is `anime` and `/manga/{id}` otherwise; verified by unit tests.
- **Provider Isolation**: a Kitsu failure must never break Jikan/AniList
  sections (already enforced per-section in `HomeViewModel`).
- **Pagination Bounds**: any single Kitsu request requests exactly 10 titles
  (`page[limit]=10`).
- **No Duplicates**: rows de-duplicate by `(source, id)` before appending pages.
- **Branding Completeness**: shared content MUST include the app name and the
  download link in all cases; the image is included where the platform allows.

## State Transitions

1. **Initial Load**: `Loading` → `Loaded (populated rows)` or per-section
   `Error` with retry (existing `HomeViewModel._loadSection` flow).
2. **Infinite Scroll**: user reaches row end → `loadMore` → next 10 titles
   appended → `hasMore` flips false when a short page arrives.
3. **Detail Fetch**: `detail(id)` now hits the correct collection by record
   `type`, so anime and manga both resolve to a `Title`.
4. **Share**: `shareTitle` → build branded `ShareTarget` → platform share sheet
   with image (where supported) + text fallback with app name and download link.
