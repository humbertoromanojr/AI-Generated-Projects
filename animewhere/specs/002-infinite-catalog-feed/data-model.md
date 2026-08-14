# Data Model: Infinite Catalog Feed

**Date**: 2026-08-14
**Source**: `spec.md` (entity list) + `research.md` decisions.

## Overview

Reuses the existing immutable domain models (`Title`, `TitleSource`,
`TitleKind`) and adds the paging/section models needed for the three-section
infinite home. No persistence layer (no login, no database).

## Entities

### Title (unchanged - existing model)

- Fields: `id`, `source` (`TitleSource`), `kind` (`TitleKind`), `title`,
  `imageUrl`, `description?`, `score?`, `seasonYear?`, `format?`,
  `providerUrl?`.
- Rules: immutable; never constructed with empty `id`/`title`/`imageUrl`;
  malformed wire entries are dropped by the mappers (FR-008).

### TitleSource (enum, unchanged)

- Values: `jikan`, `anilist`, `kitsu` - used as the three section labels
  (FR-001) and for detail/share routing (FR-010).

### TitlePage (new)

- Fields:
  - `titles: List<Title>` - the items for one page of a feed.
  - `hasMore: bool` - true iff this page's `titles.length == 10` (the page
    size), meaning another page exists (FR-005, FR-007).
- Rules: computed by the repository at the data boundary; never inferred by
  the UI/ViewModel.

### ProviderSection (new - state container)

- Fields:
  - `id`: one of `jikan` | `anilist` | `kitsu` (matches `TitleSource`).
  - `label`: the section title shown on screen (`jikan`, `anilist`, `kitsu`).
  - `carousel: Result<List<Title>>` - exactly 10 titles on initial load
    (FR-003); `Loading | Data | Failure | Empty`.
  - `rows: List<InfiniteRowState>` - exactly two recommendation rows (FR-002).
- Rules: each section fails independently (FR-008); a section's state never
  mutates another section's state.

### InfiniteRowState (new)

- Fields:
  - `id`: unique within its section (e.g. `seasonal`, `upcoming`, `popular`,
    `top-rated`, `manga`, `anime`).
  - `label`: user-facing row title (e.g. "Seasonal", "Upcoming").
  - `titles: List<Title>` - accumulated titles across loaded pages.
  - `nextPage: int` - 1-based page number for the next request.
  - `hasMore: bool` - end-of-catalog flag (FR-007).
  - `isLoadingMore: bool` - single in-flight request guard (FR-006).
  - `loadFailed: bool` - true after a page error so the UI can offer retry
    (FR-009); previously loaded titles remain visible.
- Rules:
  - Append-only; duplicates (by `source` + `id`) are skipped (FR-011).
  - Mutations only through the owning `HomeViewModel` (unidirectional flow).
  - When `hasMore == false`, no further requests are issued and no loading
    indicator is shown (FR-007).

## Validation rules (FR-008 / Constitution Principle IV)

1. Page payloads are parsed by the per-source mappers with the existing
   required-field validation; invalid entries are skipped.
2. `TitlePage.hasMore` is derived strictly from page length vs. the fixed
   10-item page size.
3. Kitsu items set `Title.kind` from the JSON:API `type` field (`anime` ->
   `TitleKind.anime`, otherwise `manga`).

## State transitions

- **Carousel**: `loading -> data(10) | error(retry) | empty`.
- **Row (initial page)**: `loading -> data(<=10, hasMore?) | error(retry)`.
- **Row (subsequent pages)**: appended when `hasMore && !isLoadingMore`;
  page request sets `isLoadingMore`, clears it on completion; failure sets
  `loadFailed` (retry) without discarding loaded titles; a page with fewer
  than 10 items sets `hasMore = false` permanently.
- **Refresh**: re-fetches all carousels + first pages concurrently, keeping
  previous data visible while refetching.
