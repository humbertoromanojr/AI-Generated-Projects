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
