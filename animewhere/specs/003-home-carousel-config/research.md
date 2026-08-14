# Research: Home Carousel Auto-Slide & Kitsu API Integration

## Phase 0: Research Objectives

### 1. Kitsu Edge API Analysis (Critical)
**Goal**: Analyze the structure of `https://kitsu.io/api/edge` to identify mandatory fields for title name, poster image URL, and relationship mapping needed for `KitsuTitleMapper`.

**Tasks**:
- Inspect a sample JSON response from `https://kitsu.io/api/edge/anime?page[limit]=10`.
- Identify the exact path for:
    - Anime Title (e.g., `data.attributes.name`)
    - Poster Image URL (e.ry, `data.attributes.media.cover.large`)
    - Any necessary relationship links (e.g., related anime).

### 2. Auto-Slide & Looping Implementation
**Goal**: Determine the most efficient way to implement continuous looping in a Flutter `PageView` or `CarouselSlider` without breaking the user's manual interaction state.

**Tasks**:
- Evaluate implementation patterns for "infinite" carousel loops (e.g., using a very large number of pages vs. page duplication).
- Research how to elegantly pause/resume a `Timer` when a user starts/ends an interaction (swipe/tap) in Flutter.

### 3. App Icon & Branding Configuration
**Goal**: Identify the necessary configuration changes for Android and iOS to update the app name to "AW" and use the `/assets/icons` folder assets.

**Tasks**:
- Locate `AndroidManifest.xml` (label change).
- Locate `Info.plist` (Bundle Display Name change).
- Verify how Flutter handles icon replacement via `flutter_launcher_icons` or manual asset updates in `ios/Runner/Assets.xcassets`.

### 4. Layout Audit (/stitch/ alignment)
**Goal**: Extract specific design tokens required for the Home screen layout from the `/stitch` directory.

**Tasks**:
- Review `/stitch/animewhere/DESIGN.md` (or similar in that folder) for:
    - Column spacing between provider sections.
    - Padding for carousel containers.
    - Typography used for section titles (Jikan, AniList, K1tsu).

## Phase 0 Findings (from implementation, T004)

### Kitsu Edge API Smoke-Check Results — NO MISMATCHES FOUND

Live verification on 2026-08-14 against `https://kitsu.io/api/edge`:

- **`/anime?page[limit]=10&page[offset]=0`**: returned `meta.count` = 22265, `data` list of exactly 10 items. First item: id `1`, type `anime`, `canonicalTitle` "Cowboy Bebop", `averageRating` `"82.27"` (string), `synopsis` (1091 chars), `subtype` `"TV"`, `posterImage` map with `tiny/small/medium/large/original` variants.
- **`/manga?page[limit]=10&page[offset]=0`**: identical structure; first item `canonicalTitle` "Guardian Dog", `averageRating` `"71.37"`, `posterImage.original` reachable.
- **Poster URL reachability**: `HEAD https://media.kitsu.app/anime/poster_images/1/original.jpg` → HTTP 200, `Content-Type: image/jpeg`.

**Decision**: The existing `lib/data/sources/kitsu/kitsu_title_mapper.dart` already parses every field the Edge API returns — `data[].id`, `type`, `attributes.canonicalTitle`, `attributes.averageRating` (as String), `attributes.synopsis`, `attributes.subtype`, and `attributes.posterImage.original`. No field/type mismatches were found, so US2 (T014/T015) reduces to verification rather than fixes. The Edge API's JSON:API shape (`data` list, `attributes` object) matches the mapper's expectations exactly.
**Rationale**: Verifying live before changing code avoids unnecessary edits; the integration is already correct.
**Alternatives considered**: Testing the `/anime/{id}` detail endpoint — deferred to US2 if detail rendering shows issues.
