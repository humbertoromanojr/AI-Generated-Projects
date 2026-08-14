# Validation Results

**Feature**: Anime & Manga Browser (`specs/001-anime-manga-browser`)
**Date**: 2026-08-14
**Environment**: Windows, Flutter 3.44.9 stable / Dart 3.12.2
**Scope**: `quickstart.md` validation scenarios + automated gates (tasks T057/T059).

## Automated gates

| Check | Command | Result |
|-------|---------|--------|
| Format | `dart format --set-exit-if-changed lib test` | PASS (0 diffs) |
| Analyze | `flutter analyze` | PASS (0 issues) |
| Unit tests | `flutter test test/unit` | PASS |
| Widget tests | `flutter test test/widget` | PASS |
| Integration test | `flutter test test/integration/browse_share_test.dart` | PASS |
| Full suite | `flutter test` | PASS (45 tests) |
| Web build | `flutter build web` | PASS |

## API smoke checks (quickstart "API smoke checks")

| API | Command | Result |
|-----|---------|--------|
| Jikan | `GET /v4/top/anime?limit=3` | PASS — 3 items (first: Sousou no Frieren); first attempt timed out, retry succeeded (Jikan throttles/slows intermittently) |
| AniList | `POST /graphql.anilist.co` Page query | PASS — 2 items (first: Tensei Shitara Slime Datta Ken 4th Season) |
| Kitsu | `GET /edge/manga?sort=-popularityRank&page[limit]=2` | PASS — 2 items (first: Gaejamnom) |

## quickstart validation scenarios

### 1. Browse (US1) — VERIFIED (automated)

- Covered by `test/widget/home_view_test.dart` and the integration journey
  (`test/integration/browse_share_test.dart`): carousel + rows populate from
  all three source mappers; title taps navigate.
- Live-device visual confirmation still to do.

### 2. Details (US3) — VERIFIED (automated)

- Covered by `test/unit/view_models/detail_view_model_test.dart` (per-source
  fetch; missing optional fields stay null, never error) and
  `test/widget/detail_view_test.dart` (image, description, type, score; absent
  fields omitted; error state with retry). Integration journey exercises the
  real `/title/:source/:id` route → `DetailView`.

### 3. Share (US2) — VERIFIED (automated)

- URL contract: `test/unit/repositories/share_repository_test.dart`
  (`https://animewhere.app/title/<source>/<id>`).
- Web preview: `test/widget/share_preview_view_test.dart` (2:3 poster +
  "AnimeWhere", loading/error states).
- System share sheet: `ShareService` uses `share_plus` 13.3
  (`SharePlus.instance.share(ShareParams(text: ...))`); the integration journey
  records the shared URL end to end. Actual OS share sheet needs a live device.

### 4. Failure handling — VERIFIED (automated)

- `test/unit/repositories/catalog_repository_test.dart`: per-source isolation
  (one API failure does not blank the others); empty results -> `Empty`.
- `test/widget/home_view_test.dart` / `error_view.dart` mapping: loading/error/
  retry states render without crashes (SC-005).

### Manual / device-only steps (not executed in this environment)

No device or emulator was available in this environment, so the following
quickstart steps still require a human run:

- Browse visually on a device; swipe rows (US1).
- Open detail for a Jikan, AniList, and Kitsu title on-device (US3).
- Tap share -> OS share sheet; open the shared link in a browser -> poster +
  "AnimeWhere" (US2).
- Airplane-mode / block-one-API checks on a real network.

## Performance pass (T059 / SC-002)

- **Caching**: all 4 poster render sites
  (`lib/ui/widgets/title_card.dart`, `lib/ui/home/widgets/title_carousel.dart`,
  `lib/ui/detail/detail_view.dart`, `lib/ui/web/share_preview/share_preview_view.dart`)
  use `CachedNetworkImage` (default disk/memory cache); no bare `Image.network`.
- **Lazy loading**: rows use `ListView.separated` (horizontal), carousel uses
  `PageView.builder`, detail uses `ListView` — off-screen posters are built
  only when scrolled into view.
- **Placeholders / slow networks**: every `CachedNetworkImage` site provides
  `placeholder` and `errorWidget` fallbacks (surface-colored box + broken-image
  icon), so posters degrade gracefully instead of crashing. SC-002 (95% first-
  view image success) is CDN-dependent; the app guarantees no-crash rendering
  on failure.

## Residual notes

- Jikan's rate limiting / slow responses (observed in the smoke check) are
  mitigated by the repository TTL cache and per-source `Failure` isolation.
