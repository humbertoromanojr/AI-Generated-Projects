# Implementation Plan: Kitsu Section Verification & Share Branding

**Branch**: `004-kitsu-search-share` | **Date**: 2026-08-14 | **Spec**: [spec.md](specs/004-kitsu-search-share/spec.md)

**Input**: Feature specification from `specs/004-kitsu-search-share/spec.md`

## Summary

Two user stories. **US1 (P1)**: verify and fix the Kitsu section (carousel +
two infinite scroll rows) against the official Kitsu API documentation
(`https://kitsu.docs.apiary.io/`), with all changes confined to Kitsu-section
code. Research found the likely root causes of live failures: the app sends
no `User-Agent` header (Kitsu aggressively rate-limits/rejects such requests)
and uses `Accept: application/json` instead of JSON:API's
`application/vnd.api+json`; additionally `KitsuApi.detail()` always calls the
manga endpoint, so anime titles 404 on detail. Pagination, sorting, and poster
fallback already conform. **US2 (P1)**: extend the share flow so shared content
displays the app image, the app name "AW - AnimeWhere", and a download link in
addition to the title share URL.

## Technical Context

**Language/Version**: Dart 3.12.2 / Flutter 3.44.9 (stable)

**Primary Dependencies**: flutter (SDK), provider (DI), go_router (navigation),
http (Kitsu REST), share_plus (native share), cached_network_image; dev:
flutter_test, flutter_lints ^6.

**Data Source(s)**:
- Kitsu API (`https://kitsu.io/api/edge`, JSON:API REST) — carousel + Anime/Manga rows.

**Storage**: Existing in-memory caching in `CatalogRepository` (5-minute TTL).

**Testing**: Unit tests for `KitsuApi` (headers, endpoint routing, paging);
widget tests for the share flow / branded share content. Existing suite baseline
is 81 tests green.

**Target Platform**: Android/iOS; Web (share preview).

**Performance Goals**: Kitsu requests remain non-blocking; carousel and rows
render within the existing 3-second load budget; no regression to Jikan/AniList.

**Constraints**:
- US1 changes confined to Kitsu-section code (`lib/data/sources/kitsu/` and the
  Kitsu section's wiring). Do NOT change the shared `AppHttpClient` defaults in
  a way that alters Jikan/AniList behavior; scope the header fix to Kitsu
  requests.
- Kitsu payloads must be parsed via the existing typed mapper
  (`KitsuTitleMapper`) per the Structured Data I/O principle.
- Design-system fidelity per `stitch/animewhere/DESIGN.md`.

**Scale/Scope**: Fix + test of an existing data source section, plus an
extension of the existing share flow.

## Constitution Check

1. **Layered Architecture** - **PASS** (Extends existing MVVM/Repository
   patterns; header change scoped inside `KitsuApi` data source)
2. **Official Flutter & Dart Best Practices** - **PASS**
3. **Design-System Fidelity (NON-NEGOTIABLE)** - **PASS** (no layout changes to
   sections; branding uses existing design tokens)
4. **Structured Data I/O** - **PASS** (Kitsu payloads continue through the typed
   mapper; malformed data yields typed errors)
5. **Tested-by-Construction** - **PASS** (new tests for headers, endpoint
   routing, and branded share content)
6. **Technology Stack & Constraints** - **PASS**
7. **Development Workflow & Quality Gates** - **PASS** (format → analyze →
   full suite before merge)

## Project Structure

### Documentation (this feature)

```text
specs/004-kitsu-search-share/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (generated later)
```

### Source Code (repository root)

```text
lib/
├── data/
│   ├── sources/
│   │   └── kitsu/
│   │       ├── kitsu_api.dart              # [CHANGED] User-Agent + JSON:API
│   │       │                               #   Accept headers; detail() routes
│   │       │                               #   by returned resource type
│   │       └── kitsu_title_mapper.dart     # [POSSIBLY CHANGED] expose type for
│   │                                       #   detail routing (anime vs manga)
│   └── repositories/
│       └── share_repository.dart           # [CHANGED] app name + download link
└── ui/
    ├── share/
    │   └── share_service.dart              # [CHANGED] include branding in share
    └── web/share_preview/
        └── share_preview_view.dart         # [CHANGED] branding on share preview

test/
├── unit/sources/kitsu_api_test.dart        # [CHANGED] headers + type routing
├── unit/mappers/kitsu_title_mapper_test.dart # [CHANGED if mapper touched]
└── unit/repositories/share_repository_test.dart # [CHANGED] branding target
```

**Structure Decision**: Single Flutter project (existing structure). All US1
changes live under `lib/data/sources/kitsu/` plus the existing Kitsu section
wiring; no changes to Jikan, AniList, or shared Home layout code. US2 changes
live in the existing `lib/ui/share/` + `lib/data/repositories/share_repository.dart`
flow.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No constitution violations identified. Scope stays within existing architecture;
the main risk is live API header requirements, mitigated by unit tests that
assert request headers and endpoint routing.
