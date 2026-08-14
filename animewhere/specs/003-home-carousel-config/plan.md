# Implementation Plan: Home Carousel Auto-Slide & Kitsu API Integration

**Branch**: `003-home-carousel-config` | **Date**: 2026-08-14 | **Spec**: [spec.md](specs/003-home-carousel-config/spec.md)

**Input**: Feature specification from `specs/003-home-carousel-config/spec.md`

## Summary

The Home screen carousels for Jikan, AniList, and Kitsu will be updated to transition automatically at a regular interval (e.g., 5 seconds) without requiring user interaction, while still allowing manual control via swipes or taps. The Kitsu API integration will be completed using the `https://kitsu.io/api/edge` endpoint, ensuring that title information and images are correctly fetched, parsed, and displayed in both carousels and recommendation rows. Additionally, the app's launcher icon will be updated to use the asset from `/assets/icons`, and the app name deployment context should reflect "AW". Finally, the entire Home screen layout (carousels, rows, sections) will be audited against the design references in the `/stitch` folder to ensure high-fidelity implementation of spacing, typography, and component structure.

## Technical Context

**Language/Version**: Dart 3.12.2 / Flutter 3.44.9 (stable)

**Primary Dependencies**: flutter (SDK), provider (DI), go_router (navigation), http (Jikan/Kitsu REST + AniList GraphQL via JSON POST), share_plus, cached_network_image; dev: flutter_test, integration_test, flutter_lints ^6.

**Data Source(s)**:
- Jikan API (REST)
- AniList API (GraphQL)
- Kitsu API (`https://kitsu.io/api/edge` - REST)

**Storage**: In-memory caching in `CatalogRepository` with 5-minute TTL to respect all provider rate limits.

**Testing**: Unit tests for `KitsuAPIAdapter` and mappers; Widget tests for `TitleCarousel` (auto-slide logic) and `CatalogSection`; Integration tests for the full home screen rendering journey.

**Target Platform**: Android/iOS, Web (share preview).

**Performance Goals**: 
- Auto-sliding carousel transitions should be smooth (60 fps).
- Kitsu API response parsing must not block the UI thread.
- All three provider sections must load within 3 seconds.

**Constraints**: 
- Implement continuous looping for carousels.
- Adhere strictly to `/stitch` design tokens.
- Kitsu integration must handle the specific `edge` API payload structure.

**Scale/Scope**: UI/UX update to existing Home screen components and expansion of data adapter logic for Kitsu.

## Constitution Check

1. **Layered Architecture** - **PASS** (Extending existing MVVM/Repository patterns)
2. **Official Flutter & Dart Best Practices** - **PASS**
3. **Design-System Fidelity (NON-NEGOTIABLE)** - **PASS** (Will be verified against `/stitch`)
4. **Structured Data I/O** - **PASS** (Kitsu payload parsing is a core requirement)
5. **Tested-by-Construction** - **PASS** 
6. **Technology Stack & Constraints** - **PASS**
7. **Development Workflow & Quality Gates** - **PASS**

## Project Structure

### Documentation (this feature)

```text
specs/003-home-carousel-config/
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
│   │       ├── kitsu_api.dart       # [NEW] Edge API implementation
│   │       └── kitsu_title_mapper.dart # [NEW] Payload parsing logic
├── ui/
│   ├── home/
│   │   └── widgets/
│   │       └── title_carousel.dart  # [CHANGED] Auto-slide & looping logic
...
```

## Complexity Tracking

No constitution violations identified. The complexity lies in the correct parsing of the Kitsu Edge API response and implementing a seamless, non-disruptive auto-slide timer that responds to user manual interaction (pausing/resuming).
