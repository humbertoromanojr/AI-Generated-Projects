# Validation Results

**Feature**: Home Carousel Auto-Slide & Kitsu API Integration (`specs/003-home-carousel-config`)
**Date**: 2026-08-14
**Environment**: Windows, Flutter 3.44.9 stable / Dart 3.12.2
**Scope**: `quickstart.md` validation scenarios + automated gates (tasks T025-T026).

## Automated gates

| Check | Command | Result |
|-------|---------|--------|
| Format | `dart format --set-exit-if-changed lib test` | PASS (0 diffs) |
| Analyze | `flutter analyze` | PASS (0 issues) |
| Full suite | `flutter test` | PASS (81 tests) |
| US1 widget tests | `flutter test test/widget/title_carousel_test.dart` | PASS (3 tests) |
| US2 unit tests | `flutter test test/unit/mappers/kitsu_title_mapper_test.dart test/unit/sources/kitsu_api_test.dart` | PASS (12 tests) |
| US3 icon generation | `dart run flutter_launcher_icons` | PASS (Android mipmaps + iOS appiconset generated) |
| US4 widget tests | `flutter test test/widget/home_view_test.dart` | PASS (8 tests) |

## Kitsu Edge API smoke check (T004)

| Request | Result |
|---------|--------|
| `GET https://kitsu.io/api/edge/anime?page[limit]=10&page[offset]=0` | PASS — JSON body with `data` list of 10; `meta.count` 22265; first item Cowboy Bebop |
| Poster HEAD check | PASS — poster URL returns 200 `image/jpeg` |

No field/type mismatches found against `kitsu_title_mapper.dart`; US2 reduced
to verification plus a defensive `posterImage` size-variant fallback (T014).

## quickstart validation scenarios

### 1. Automatic carousel sliding (US1) — VERIFIED (automated)

- `test/widget/title_carousel_test.dart`: "advances to the next page
  automatically after the slide interval" (advances on `autoSlideInterval`
  without input); "wraps from the last page back to the first to loop
  continuously"; "pauses auto-slide during interaction and resumes after
  idle".
- Lifecycle pause/resume (backgrounding) verified via `WidgetsBindingObserver`
  in `_TitleCarouselState` (`lib/ui/home/widgets/title_carousel.dart`).
- Live-device visual confirmation still to do.

### 2. Kitsu API integration (US2) — VERIFIED (automated)

- `test/unit/mappers/kitsu_title_mapper_test.dart`: Edge API variants handled —
  non-string `averageRating` maps to a null score without failing; missing
  `canonicalTitle` entries are skipped; `posterImage` falls back through size
  variants (original → large → medium → small → tiny) when `original` is
  absent.
- `test/unit/sources/kitsu_api_test.dart`: `anime()`/`manga()` query params
  (`sort=-popularityRank`, `page[limit]=10`, `page[offset]=page*10`, custom
  limit) match the Edge API paging contract.
- Wiring verified: `HomeViewModel` loads Kitsu carousel + Manga/Anime rows via
  `CatalogRepository`; `CatalogSection` renders them through `TitleCarousel`
  and `InfiniteTitleRow` using `CachedNetworkImage`.
- Live Kitsu image rendering remains a device-only step.

### 3. App branding & icon (US3) — VERIFIED (config + generated assets)

- Launcher icon: `dart run flutter_launcher_icons` generated
  `android/app/src/main/res/mipmap-{mdpi..xxxhdpi}/ic_launcher.png` and all
  `ios/Runner/Assets.xcassets/AppIcon.appiconset/` sizes from
  `assets/icons/animeWhere.png`; no default Flutter icon remains.
- App label: `android:label="AW"` in `AndroidManifest.xml`;
  `CFBundleDisplayName` = `AW` in `ios/Runner/Info.plist`.
- Install-on-device confirmation of the launcher icon/label still to do.

### 4. Layout fidelity vs `/stitch` (US4) — VERIFIED (automated + audit)

- `test/widget/home_view_test.dart`: "renders three section headers in order
  (jikan, anilist, kitsu)" — fixed section order, one card per section.
- Audit vs `stitch/animewhere/DESIGN.md` + `home_animewhere_adjusted_scrolls/`
  reference: section titles styled `headlineLarge` in `primary` (design:
  `text-primary` display headers); brand header "AnimeWhere" in `primary`
  display weight; 2:3 poster ratio (`posterHeight = width * 3 / 2`); spacing on
  the 8px scale; glassmorphism via `BackdropFilter` blur(20) + `glassTint`;
  `CardThemeData.elevation: 0` (tonal layering, no drop shadows).
- Visual diff against the reference screenshots remains a device-only step.

## Manual / device-only steps (not executed in this environment)

No device or emulator was available, so the following quickstart steps still
require a human run:

- Watch each carousel auto-advance and loop on a live device (US1).
- Confirm Kitsu posters render from the live Edge API with no broken/blank
  images (US2).
- Install the app and check the launcher icon matches
  `assets/icons/animeWhere.png` with label "AW" (US3).
- Visual comparison of the rendered Home against `stitch/*/screen.png` (US4).
