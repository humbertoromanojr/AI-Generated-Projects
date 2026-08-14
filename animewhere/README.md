# AnimeWhere

A Flutter app that lets you browse anime and manga from three public catalog
APIs (Jikan, AniList, Kitsu), view title details, and share any title via the
system share sheet.

## Features

- **Browse** — the home screen is organized into three provider sections in
  fixed order (**Jikan**, **AniList**, **Kitsu**), each opening with a featured
  carousel (10 items) followed by two horizontally scrollable recommendation
  rows: Jikan → Seasonal/Upcoming, AniList → Popular/Top Rated, Kitsu →
  Manga/Anime.
- **Infinite rows** — the two rows in each section load the next 10 titles as
  you scroll to a row's end, with a single in-flight request per row, no
  duplicate titles, and a quiet stop at catalog end.
- **Details** — tap any title to see its poster, description, type, and score,
  fetched from the source that supplied it.
- **Share** — every title exposes a share action (carousel, rows, and detail)
  that opens the system share sheet with a link to the web preview page
  (`https://animewhere.app/title/<source>/<id>`).

## Prerequisites

- Flutter 3.44.9 (stable) or later with Dart 3.12.2 (`flutter --version`).
- The three catalog APIs (Jikan, AniList, Kitsu) reachable — no API keys.

## Setup

```bash
flutter pub get
dart format .
flutter analyze   # 0 issues expected
flutter test      # full suite green
```

## Run the app

```bash
flutter run -d <device>   # Android/iOS emulator or desktop
```

## Web build (share preview host)

The web build renders the share preview page at `/title/:source/:id`:

```bash
flutter build web
```

The preview shows the title's 2:3 poster with "AnimeWhere" below it. When
deploying, ensure the site's base path is configured via `--base-href`
(see `web/index.html`).

## Validation

The implementation is validated per the feature's
[quickstart](specs/001-anime-manga-browser/quickstart.md) scenarios; results
are recorded in
[validation-results.md](specs/001-anime-manga-browser/validation-results.md).
The infinite catalog feed (three provider sections, 10-item carousels,
infinite rows) is validated per
[quickstart](specs/002-infinite-catalog-feed/quickstart.md), with results in
[validation-results.md](specs/002-infinite-catalog-feed/validation-results.md).
The home carousel auto-slide, Kitsu Edge API integration, AW launcher
label/icon, and stitch layout are validated per
[quickstart](specs/003-home-carousel-config/quickstart.md), with results in
[validation-results.md](specs/003-home-carousel-config/validation-results.md).

## App branding

The launcher label is **AW** on Android (`android:label`) and iOS
(`CFBundleDisplayName`); the launcher icon is generated from
`assets/icons/animeWhere.png` (see `flutter_launcher_icons` in
`pubspec.yaml`). The in-app brand and web share preview keep the
"AnimeWhere" name.

## Project structure

- `lib/core/` — domain models, network client, result/error types, DI providers
- `lib/data/` — repositories and per-source API clients + mappers
  (`sources/{jikan,anilist,kitsu}`)
- `lib/ui/` — home, detail, share, and web preview views with their view models
- `test/` — unit, widget, and end-to-end (browse → detail → share) tests
