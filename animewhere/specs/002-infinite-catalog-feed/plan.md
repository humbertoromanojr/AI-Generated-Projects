# Implementation Plan: Infinite Catalog Feed

**Branch**: `002-infinite-catalog-feed` | **Date**: 2026-08-14 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/002-infinite-catalog-feed/spec.md`

## Summary

The Home screen of AnimeWhere is reworked into three labeled sections — one
per catalog provider, titled **jikan**, **anilist**, and **kitsu** — each
consisting of a featured carousel followed by two horizontally scrollable
recommendation rows. Every carousel loads a strict maximum of 10 titles on its
initial load (protecting against provider request limits), and each
recommendation row is infinite: it automatically fetches the next page of 10
titles when the user reaches the row's end, and stops cleanly when the
provider's catalog is exhausted. The three sections load independently so a
failure in one provider never blanks the other two. The existing title-detail
and share flows are reused unchanged; the current single-carousel/four-row
home is replaced.

## Technical Context

**Language/Version**: Dart 3.12.2 / Flutter 3.44.9 (stable, as specified by
user; matches the pinned `pubspec.yaml` SDK constraint `^3.12.2`)

**Primary Dependencies**: flutter (SDK), provider (DI), go_router (navigation),
http (Jikan/Kitsu REST + AniList GraphQL via JSON POST), share_plus (system
share sheet), cached_network_image (poster loading); dev: flutter_test,
integration_test (SDK), flutter_lints ^6. No new dependencies required — this
feature extends the existing stack.

**Storage**: N/A - no database. In-memory state only; the existing short-TTL
in-memory cache in `CatalogRepository` is extended to cache per list **and**
per page (5-minute TTL) to respect API rate limits (Jikan 3 req/s & 60/min,
AniList 90/min, Kitsu ~100/min).

**Testing**: flutter_test (unit + widget), integration_test (end-to-end
journeys); mappers, repositories, and ViewModels unit-tested per the
tested-by-construction principle. Existing home VM/widget tests are rewritten
for the section-based layout; the browse→detail→share journey test is extended
to the new home composition.

**Target Platform**: Android/iOS (primary); web (share-preview hosting) and
desktop targets remain buildable per constitution.

**Project Type**: mobile-app (Flutter), with a web entry used for share
previews.

**Performance Goals**: All three provider sections visible within 3 s on a
standard connection (SC-001); 60 fps scrolling with lazy-loaded posters;
infinite rows append a 10-title page only on demand (SC-003).

**Constraints**: Three external APIs with independent rate limits; every
payload validated against typed models (constitution Principle IV); carousels
never exceed 10 titles per request (FR-003); at most one in-flight page
request per row (FR-006); no endless loading states (FR-007); no duplicate
titles within a row (FR-011); secrets never committed.

**Scale/Scope**: Medium rework of the existing home screen — 3 sections ×
(carousel + 2 infinite rows); 3 data adapters extended with pagination and two
new list endpoints; no new screens.

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
   glassmorphism over shadows; section titles use the design's headline/body
   tokens: **PASS**.
4. **Structured Data I/O** - every API payload validated against typed models
   at the boundary; malformed data surfaces as typed errors or skipped
   entries, never silent partial state: **PASS**.
5. **Tested-by-Construction** - unit (mappers, repos, ViewModels incl. paging
   logic), widget (section composition, infinite-row trigger), integration
   (browse -> detail -> share journey on the new home): **PASS**.
6. **Technology Stack & Constraints** - SDK constraint `^3.12.2`, provider,
   go_router, flutter_lints, all platform targets buildable, no secrets: **PASS**.
7. **Development Workflow & Quality Gates** - `dart format` + `flutter analyze`
   + `flutter test` green before any merge: **PASS**.

Post-design re-check: no artifact produced in Phase 1 violates a principle
(see Completion Report).

## Project Structure

### Documentation (this feature)

```text
specs/002-infinite-catalog-feed/
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
├── main.dart                        # app bootstrap (unchanged)
├── app/
│   ├── app.dart                     # router wiring (unchanged - home route stays '/')
│   └── theme/                       # design tokens (unchanged)
├── core/
│   ├── di/
│   │   └── providers.dart           # unchanged (repository/VM providers reuse)
│   ├── network/
│   │   ├── http_client.dart         # unchanged
│   │   └── network_error.dart       # unchanged
│   ├── models/
│   │   └── title.dart               # unchanged domain model
│   └── utils/
│       └── result.dart              # unchanged Result<T>
├── data/
│   ├── repositories/
│   │   └── catalog_repository.dart  # [CHANGED] paginated accessors + per-page cache
│   └── sources/
│       ├── jikan/
│       │   └── jikan_api.dart       # [CHANGED] page param + seasonsUpcoming()
│       ├── anilist/
│       │   ├── anilist_api.dart     # [CHANGED] page param + topRatedAnime()
│       │   ├── anilist_queries.dart # [CHANGED] page var in Page query
│       │   └── anilist_title_mapper.dart  # unchanged
│       └── kitsu/
│           ├── kitsu_api.dart       # [CHANGED] offset paging + anime()
│           └── kitsu_title_mapper.dart   # [CHANGED] kind derived from item type
├── ui/
│   ├── home/
│   │   ├── home_view.dart           # [CHANGED] renders 3 CatalogSections
│   │   ├── home_view_model.dart     # [CHANGED] SectionState + InfiniteRowState
│   │   └── widgets/
│   │       ├── catalog_section.dart # [NEW] labeled section (title + carousel + 2 rows)
│   │       ├── infinite_title_row.dart # [NEW] horizontally infinite list row
│   │       ├── title_carousel.dart  # reused as-is
│   │       └── title_row.dart       # replaced by infinite_title_row (deleted)
│   ├── detail/                      # unchanged
│   ├── share/                       # unchanged
│   └── web/share_preview/           # unchanged
```

```text
test/
├── unit/
│   ├── mappers/
│   │   └── kitsu_title_mapper_test.dart   # [CHANGED] anime kind coverage
│   ├── repositories/
│   │   └── catalog_repository_test.dart   # [CHANGED] pagination + per-page cache
│   └── view_models/
│       └── home_view_model_test.dart      # [CHANGED] section structure + paging
├── widget/
│   └── home_view_test.dart                # [CHANGED] 3 sections, carousels=10, infinite rows
└── integration/
    └── browse_share_test.dart             # [CHANGED] journey on new home
```

**Structure Decision**: Single Flutter app with the established strict UI/data
split. The section-based home is expressed as `HomeViewModel` → list of
`SectionState` (carousel + rows), rendered by a new `CatalogSection` widget
composed of the reused `TitleCarousel` and a new `InfiniteTitleRow`. All
pagination and catalog composition logic lives in the repository layer
(per-page cache, per-list accessors) and the ViewModel (append/dedupe/single-
flight), keeping widgets dumb per the constitution.

## Complexity Tracking

No constitution violations to justify. Adding two list endpoints
(Jikan `seasons/upcoming`, Kitsu `/anime`) and pagination to three adapters is
required to give each provider a carousel plus two distinct recommendation
rows with 10-item paging, as the spec requires; the added surface is isolated
behind the existing `CatalogRepository` facade.
