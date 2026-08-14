# AnimeWhere

A Flutter app that lets you browse anime and manga from three public catalog
APIs (Jikan, AniList, Kitsu), view title details, and share any title via the
system share sheet.

## Features

- **Browse** — featured carousel (Jikan top anime) plus Trending/Popular
  (AniList), Latest/Simulcast (Jikan), and Manga (Kitsu) rows.
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

## Project structure

- `lib/core/` — domain models, network client, result/error types, DI providers
- `lib/data/` — repositories and per-source API clients + mappers
  (`sources/{jikan,anilist,kitsu}`)
- `lib/ui/` — home, detail, share, and web preview views with their view models
- `test/` — unit, widget, and end-to-end (browse → detail → share) tests
