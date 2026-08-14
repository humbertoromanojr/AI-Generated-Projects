# Home Feed UI Contract

**Purpose**: Behavior contract for the three-section home screen and its
infinite rows, as required by `spec.md` (FR-001..FR-011). Tests and the UI
implementation must pin this behavior.

## Sections (FR-001, FR-002)

- The Home screen MUST render exactly three sections, in this fixed order:
  `jikan`, `anilist`, `kitsu`.
- Each section shows a title header labeled exactly `jikan`, `anilist`, or
  `kitsu`, followed by a featured carousel and exactly two horizontally
  scrollable recommendation rows.
- Tapping any title (carousel or row) opens the existing detail route
  `/title/<source>/<id>` (FR-010). The existing share action remains available.

## Carousels (FR-003)

- Each carousel MUST request exactly 10 titles on its initial load and MUST
  NOT issue further requests while idle.
- Carousels reuse the existing `TitleCarousel` component (2:3 posters, glass
  navigation).

## Infinite rows (FR-004, FR-005, FR-006, FR-007, FR-009, FR-011)

- Each row starts by loading its first page (10 titles).
- When the user scrolls to within ~200px of the row's end, the row MUST load
  the next page of exactly 10 titles (FR-004, FR-005).
- At most one page request MAY be in flight per row at any time, even under
  rapid scrolling (FR-006).
- When a page returns fewer than 10 titles (or the provider is exhausted),
  the row MUST stop loading and MUST NOT show a perpetual loading indicator
  (FR-007).
- Duplicate titles within a single row (by `source` + `id`) MUST NOT appear
  (FR-011).
- Page-load failure MUST keep previously loaded titles visible and MUST
  surface a retry affordance (FR-009).

## Isolation (FR-008)

- Carousels and rows of one section MUST load independently of the others; a
  failure in one provider's section MUST NOT prevent the other two sections
  from loading and rendering.

## Loading / error / empty states (FR-009)

- Each carousel and each row renders explicit loading, error (with retry), and
  empty states using the existing `LoadingView` / `ErrorView` patterns and
  design tokens.

## Navigation (unchanged)

See [navigation.md](navigation.md) - routes `/` and `/title/:source/:id`
remain unchanged.
