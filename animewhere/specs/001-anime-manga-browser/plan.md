# Implementation Plan: Anime & Manga Browser

**Branch**: `001-anime-manga-browser` | **Date**: 2026-08-14 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-anime-manga-browser/spec.md`

## Summary

AnimeWhere is a simple Flutter app that lists anime and manga images and
information. There is no login and no database: all content is fetched live
from three public catalog APIs, one per app part - Jikan REST (featured
carousel + latest/seasonal anime), AniList GraphQL (trending and popular
anime), and Kitsu REST (manga rows). The home screen shows a carousel plus
three scroll rows; each title opens a detail view and exposes a share action
whose link renders the title image with the app name ("AnimeWhere") below it
on a hosted web page. The app is built with Dart 3.12.2 and Flutter 3.44.9
(stable) using the layered MVVM + repository architecture required by the
constitution, with the design tokens from `stitch/animewhere/DESIGN.md` mapped
one-to-one into the theme.

## Technical Context

**Language/Version**: Dart 3.12.2 / Flutter 3.44.9 (stable, as specified by
user; matches the pinned `pubspec.yaml` SDK constraint `^3.12.2`)

**Primary Dependencies**: flutter (SDK), provider (DI), go_router (navigation),
http (Jikan/Kitsu REST + AniList GraphQL via JSON POST), share_plus (system
share sheet), cached_network_image (poster loading); dev: flutter_test,
integration_test (SDK), flutter_lints ^6. Exact versions pinned via
`flutter pub add` at implementation time (latest stable).

**Storage**: N/A - no database. In-memory state only; short-TTL in-memory
cache per repository to respect API rate limits (Jikan 3 req/s & 60/min,
AniList 90/min, Kitsu ~100/min).

**Testing**: flutter_test (unit + widget), integration_test (end-to-end
journeys); mappers, repositories, and ViewModels unit-tested per the
tested-by-construction principle.

**Target Platform**: Android/iOS (primary); web (share-preview hosting) and
desktop targets remain buildable per constitution.

**Project Type**: mobile-app (Flutter), with a web entry used for share
previews.

**Performance Goals**: Home carousel + rows visible within 3 s on a standard
connection (SC-001); 60 fps scrolling with lazy-loaded posters; >= 95% image
load success (SC-002).

**Constraints**: No login, no database, no on-disk cache; three external APIs
with independent rate limits; all payloads validated against typed models
(constitution Principle IV); secrets never committed.

**Scale/Scope**: Small app - home + detail screens plus share flow; 3 data
adapters; unified domain model with ~5 types.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

1. **Layered Architecture** - UI/Data separation, MVVM (dumb widgets +
   ViewModels), repository pattern, DI via provider, go_router navigation,
   unidirectional data flow, immutable models: **PASS** (structure below).
2. **Official Flutter & Dart Best Practices** - latest stable toolchain
   (Dart 3.12.2 / Flutter 3.44.9), flutter_lints zero warnings, `dart format`,
   Material 3 theming: **PASS**.
3. **Design-System Fidelity (NON-NEGOTIABLE)** - tokens from
   `stitch/animewhere/DESIGN.md` mapped one-to-one into ThemeData; 2:3 posters;
   glassmorphism over shadows; screens matched to the `/stitch` mockups: **PASS**.
4. **Structured Data I/O** - every API payload validated against typed models
   at the boundary; malformed data surfaces as typed errors or skipped
   entries, never silent partial state: **PASS**.
5. **Tested-by-Construction** - unit (mappers, repos, ViewModels), widget
   (screens), integration (browse -> detail -> share journey): **PASS**.
6. **Technology Stack & Constraints** - SDK constraint `^3.12.2`, provider,
   go_router, flutter_lints, all platform targets buildable, no secrets: **PASS**.
7. **Development Workflow & Quality Gates** - `dart format` + `flutter analyze`
   + `flutter test` green before any merge: **PASS**.

Post-design re-check: no artifact produced in Phase 1 violates a principle
(see Completion Report).

## Project Structure

### Documentation (this feature)

```text
specs/001-anime-manga-browser/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── main.dart                        # app bootstrap
├── app/
│   ├── app.dart                     # MaterialApp + router wiring + theme
│   └── theme/
│       ├── app_theme.dart           # ColorScheme from stitch/animewhere tokens
│       └── app_text_theme.dart      # Inter typography tokens
├── core/
│   ├── di/
│   │   └── providers.dart           # provider-based DI registrations
│   ├── network/
│   │   ├── http_client.dart         # shared client (timeouts, headers)
│   │   └── network_error.dart       # typed error taxonomy
│   ├── models/
│   │   ├── title.dart               # unified immutable domain model
│   │   ├── collection.dart
│   │   └── title_source.dart        # jikan | anilist | kitsu
│   └── utils/
│       └── result.dart              # typed Result<T> for fetch outcomes
├── data/
│   ├── repositories/
│   │   ├── catalog_repository.dart  # facade over the three sources
│   │   └── share_repository.dart    # share URL builder + share_plus wrapper
│   └── sources/
│       ├── jikan/
│       │   ├── jikan_api.dart
│       │   └── jikan_title_mapper.dart
│       ├── anilist/
│       │   ├── anilist_api.dart
│       │   ├── anilist_queries.dart
│       │   └── anilist_title_mapper.dart
│       └── kitsu/
│           ├── kitsu_api.dart
│           └── kitsu_title_mapper.dart
├── ui/
│   ├── home/
│   │   ├── home_view.dart
│   │   ├── home_view_model.dart
│   │   └── widgets/
│   │       ├── title_carousel.dart
│   │       └── title_row.dart
│   ├── detail/
│   │   ├── detail_view.dart
│   │   └── detail_view_model.dart
│   ├── share/
│   │   └── share_service.dart       # share action orchestration
│   ├── widgets/
│   │   ├── title_card.dart
│   │   ├── error_view.dart
│   │   └── loading_view.dart
│   └── web/
│       └── share_preview/
│           └── share_preview_view.dart  # web entry: image + app name
└── web/                             # web host wiring for /title/<source>/<id>

test/
├── unit/
│   ├── mappers/                     # jikan/anilist/kitsu mapper tests
│   ├── repositories/                # repository + cache tests
│   └── view_models/                 # home/detail/share VM tests
├── widget/
│   ├── home_view_test.dart
│   └── detail_view_test.dart
└── integration/
    └── browse_share_test.dart       # end-to-end journey
```

**Structure Decision**: Single Flutter app with a strict UI/data split per the
Flutter architecture recommendations: `lib/ui` holds Views + ViewModels (MVVM),
`lib/data` holds repositories and the three source adapters, `lib/core` holds
shared domain models and networking. The three-API requirement is isolated
behind the `CatalogRepository` facade so the UI never depends on a specific
provider. Feature-first grouping under `lib/ui` keeps each screen's widgets and
state together.

## Complexity Tracking

No constitution violations to justify. The three-source adapter layer is
required complexity introduced by the user's one-API-per-app-part decision; it
is isolated behind a single `CatalogRepository` facade so the UI layer is not
aware of it. No simpler alternative satisfies the stated three-part
requirement.
