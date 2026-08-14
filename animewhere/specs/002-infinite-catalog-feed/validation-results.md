# Validation Results

**Feature**: Infinite Catalog Feed (`specs/002-infinite-catalog-feed`)
**Date**: 2026-08-14
**Environment**: Windows, Flutter 3.44.9 stable / Dart 3.12.2
**Scope**: `quickstart.md` validation scenarios + automated gates (tasks T031-T035).

## Automated gates

| Check | Command | Result |
|-------|---------|--------|
| Format | `dart format --set-exit-if-changed lib test` | PASS (0 diffs) |
| Analyze | `flutter analyze` | PASS (0 issues) |
| Unit tests | `flutter test test/unit` | PASS (49 tests) |
| Widget tests | `flutter test test/widget` | PASS (20 tests) |
| Integration test | `flutter test test/integration/browse_share_test.dart` | PASS |
| Full suite | `flutter test` | PASS (74 tests) |

## API smoke checks (quickstart "API smoke checks", optional/manual)

| API | Command | Result |
|-----|---------|--------|
| Jikan page 2 | `GET /v4/top/anime?limit=10&page=2` | BLOCKED — 504 Gateway Timeout on 2 attempts (Jikan intermittently throttles; identical symptom recorded in spec 001 results) |
| Jikan upcoming | `GET /v4/seasons/upcoming?limit=10&page=1` | BLOCKED — 504 Gateway Timeout on 2 attempts (same upstream issue) |
| AniList | `POST /graphql.anilist.co` Page + SCORE_DESC query | PASS — 10 items returned |
| Kitsu | `GET /edge/anime?sort=-popularityRank&page[limit]=10&page[offset]=0` | PASS — 10 items returned |

The Jikan 504s are an upstream service condition, not an app defect: the
repository TTL cache and per-source `Failure` isolation (FR-008) keep the
other two sections fully functional while Jikan is degraded (verified by the
failure-isolation tests below).

## quickstart validation scenarios

### 1. Three provider sections (US1 / FR-001, FR-002; SC-001) — VERIFIED (automated)

- `test/widget/home_view_test.dart`: "renders three section headers in order
  (jikan, anilist, kitsu)" — headers appear in fixed order.
- `test/unit/view_models/home_view_model_test.dart`: `HomeViewModel`
  initializes three sections and loads data into all three; each section has
  a carousel plus two rows (asserted by the section-composition tests).
- Integration journey (`test/integration/browse_share_test.dart`) renders the
  real home screen with all three sections populated from live mappers.
- Live-device visual confirmation still to do.

### 2. Ten-at-a-time carousels (US2 / FR-003; SC-002) — VERIFIED (automated)

- `test/unit/sources/jikan_api_test.dart`, `anilist_api_test.dart`,
  `kitsu_api_test.dart`, and `catalog_repository_test.dart`: every carousel
  accessor requests exactly 10 titles on page 1 with no page parameter.
- `test/widget/home_view_test.dart`: "carousels render exactly 10 items and
  issue exactly one request" — fresh home load shows 10 items per carousel
  and a single request per carousel accessor.
- `home_view_model_test.dart`: `load()` issues exactly one carousel request
  per section with no polling or idle auto-refetch (FR-003, SC-002).

### 3. Infinite rows (US3 / FR-004, FR-005; SC-003) — VERIFIED (automated)

- `test/widget/home_view_test.dart` `InfiniteTitleRow` group: scrolling near
  the end triggers `onLoadMore`; trailing mini-spinner while a page loads;
  quiet "End of catalog" marker once the provider stops returning full pages
  (no endless spinner, FR-007 / SC-006).
- `test/unit/view_models/home_view_model_test.dart` `loadMore` group: appends
  the next page exactly once; single-flight guard blocks overlapping loads
  (FR-005); `hasMore` flips false on a short page; duplicates by
  `source`+`id` never repeat within a row (FR-006, FR-011); failure keeps
  loaded titles and sets retry state (FR-008).

### 4. Failure isolation (FR-008; SC-004) — VERIFIED (automated)

- `test/unit/view_models/home_view_model_test.dart`: "a Jikan failure must
  not blank the other two sections" and "refresh keeps previously loaded
  content when a source fails".
- `test/widget/home_view_test.dart` `InfiniteTitleRow` error state: row shows
  retryable error while titles stay visible; `HomeView`/`CatalogSection`
  render loading/error/retry without crashing.
- Airplane-mode / block-one-API checks on a real network remain device-only.

### 5. Detail & share regression (FR-010) — VERIFIED (automated)

- `test/integration/browse_share_test.dart`: full journey — browse the
  3-section home, tap a jikan title into `DetailView`, share it, and record
  `https://animewhere.app/title/jikan/21` end to end.
- Detail/share unit + widget coverage unchanged and green from feature 001
  (`detail_view_model_test.dart`, `detail_view_test.dart`,
  `share_repository_test.dart`, `share_preview_view_test.dart`).

### Manual / device-only steps (not executed in this environment)

No device or emulator was available, so the following quickstart steps still
require a human run:

- Scroll each recommendation row to its end on a device and watch it extend
  by 10 (SC-003); rapid-flick to confirm no duplicates and a single in-flight
  request per row.
- Airplane-mode / block-one-API checks on a real network.
- Visual confirmation of the three-section layout and carousel page counters.

## Performance pass (T033 / SC-003)

- **Per-page cache prevents duplicate requests**: `CatalogRepository._fetchPage`
  caches by feed+page; repeated `loadMore` of the same page (e.g. a retry)
  hits the cache instead of re-requesting, and failed pages are not cached so
  retry re-requests the network.
- **Lazy posters**: every poster render site uses `CachedNetworkImage`
  (disk/memory cache, no bare `Image.network`). `InfiniteTitleRow` renders its
  row with a horizontal `ListView.builder` (converted from an eager
  `SingleChildScrollView`+`Row` during this pass), and the carousel uses
  `PageView.builder` — off-screen posters are only built when scrolled into
  view, so the widget tree stays bounded on long catalogs.
- **No unbounded growth on rapid scrolling**: `InfiniteRowState` dedupes
  appends by `source`+`id` (bounded by catalog size), the single-flight guard
  caps in-flight pages at one per row, `hasMore=false` stops issuing further
  page requests at catalog end, and the lazy `ListView.builder` never holds
  more than the visible row plus cache extent. The end marker replaces any
  endless spinner.

## Residual notes

- Jikan's rate limiting / slow responses (504s observed during the smoke
  check) are mitigated by the repository TTL cache and per-source `Failure`
  isolation; the app renders all three sections when Jikan is degraded.
