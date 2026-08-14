# Quickstart: Infinite Catalog Feed

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

**Expected (SC-001)**: Home shows three sections titled **jikan**, **anilist**,
and **kitsu**, in that order, each with a featured carousel plus two
horizontally scrollable rows, fully populated within ~3 s on a standard
connection.

## Validation scenarios

### 1. Three provider sections (User Story 1 / FR-001, FR-002; SC-001)

1. Open the app -> three section headers (`jikan`, `anilist`, `kitsu`) appear
   in order.
2. Each section shows a carousel followed by exactly two image rows populated
   with 2:3 posters.
3. Tap a title in any carousel or row -> the detail screen opens.

### 2. Ten-at-a-time carousels (User Story 2 / FR-003; SC-002)

1. On a fresh home load, observe each carousel's page counter - it reads
   `1 / 10` (exactly 10 items).
2. Leave the screen idle -> no additional carousel network requests occur.

### 3. Infinite rows (User Story 3 / FR-004, FR-005; SC-003)

1. Scroll any recommendation row to its end -> a new batch of exactly 10
   titles loads and the row extends.
2. Rapidly flick to the end repeatedly -> at most one page request runs at a
   time and no titles repeat within a row (FR-006, FR-011).
3. Keep scrolling until the provider stops returning full pages -> the row
   stops quietly without an endless spinner (FR-007, SC-006).

### 4. Failure isolation (FR-008; SC-004)

- Enable airplane mode -> each carousel/row shows loading/error/retry; no
  crash.
- Block one API (e.g., Jikan) -> its section shows retryable errors while the
  anilist and kitsu sections still load and scroll.

### 5. Detail & share regression (FR-010)

- From a jikan, anilist, and kitsu title, tap through to detail and share;
  both behave as in feature 001.

### API smoke checks (optional, manual)

```bash
# Jikan paging: page 2 returns 10 items
curl -s "https://api.jikan.moe/v4/top/anime?limit=10&page=2" | jq '.data | length'
# Jikan upcoming
curl -s "https://api.jikan.moe/v4/seasons/upcoming?limit=10&page=1" | jq '.data | length'
# AniList page + SCORE sort
curl -s -X POST https://graphql.anilist.co -H "Content-Type: application/json" \
  -d '{"query":"query($p:Int,$n:Int){Page(page:$p,perPage:$n){media(type:ANIME,sort:SCORE_DESC){id title{romaji}}}}","variables":{"p":1,"n":10}}'
# Kitsu offset paging + anime
curl -s "https://kitsu.io/api/edge/anime?sort=-popularityRank&page[limit]=10&page[offset]=0" | jq '.data | length'
```

## References

- Data model: [data-model.md](data-model.md)
- API / home-feed / navigation contracts: [contracts/](contracts/README.md)
- Research decisions: [research.md](research.md)
