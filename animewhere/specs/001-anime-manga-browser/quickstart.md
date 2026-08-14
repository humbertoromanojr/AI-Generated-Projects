# Quickstart: Anime & Manga Browser

Validation guide for the feature. Prerequisites, run commands, and expected
outcomes mapped to the spec's success criteria. No implementation code lives
here; see `tasks.md` for that.

## Prerequisites

- Dart 3.12.2 + Flutter 3.44.9 (stable) installed (`flutter --version`).
- The three catalog APIs reachable (Jikan, AniList, Kitsu) - no keys required.

## Setup

```bash
flutter pub get
dart format .
flutter analyze          # 0 errors, 0 warnings
flutter test             # full suite green
```

## Run the app

```bash
flutter run -d <device>  # Android/iOS emulator or desktop
```

**Expected (SC-001)**: home screen shows the featured carousel (Jikan) plus
rows for Trending/Popular (AniList), Latest/Simulcast (Jikan), and manga
(Kitsu) within ~3 s on a standard connection, with 2:3 posters styled per
`stitch/animewhere/DESIGN.md`.

## Validation scenarios

### 1. Browse (User Story 1)

1. Open the app -> carousel + at least two rows populate with real
   titles/images.
2. Swipe a row -> more titles load and display.
3. Tap a title -> the detail screen opens.

### 2. Details (User Story 3)

- The detail view shows image, description, type, and score for a Jikan-, an
  AniList-, and a Kitsu-sourced title. Missing optional fields render as
  omitted, never as errors.

### 3. Share (User Story 2 / FR-005, FR-006; SC-003, SC-004)

1. From the carousel, a row, or detail, tap share -> the system share sheet
   opens with the title's link.
2. Open the shared link in a browser -> the title's image renders with
   "AnimeWhere" below it.
3. Cancel the share -> no state loss; the user stays on the same screen.

### 4. Failure handling (FR-007, FR-008; SC-005)

- Enable airplane mode -> loading/error/retry states appear; no crash.
- Block one API (e.g., Jikan) -> only its rows show errors; AniList and Kitsu
  rows still load.

### API smoke checks (optional, manual)

```bash
curl -s "https://api.jikan.moe/v4/top/anime?limit=3" | jq '.data | length'
curl -s -X POST https://graphql.anilist.co \
  -H "Content-Type: application/json" \
  -d '{"query":"{ Page(perPage: 2) { media(type: ANIME, sort: TRENDING_DESC) { id title { romaji } } } }"}'
curl -s "https://kitsu.io/api/edge/manga?sort=-popularityRank&page[limit]=2" | jq '.data | length'
```

## References

- Data model: [data-model.md](data-model.md)
- API / share / navigation contracts: [contracts/](contracts/README.md)
- Research decisions: [research.md](research.md)
