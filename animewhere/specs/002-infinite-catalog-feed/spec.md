# Feature Specification: Infinite Catalog Feed

**Feature Branch**: `002-infinite-catalog-feed`

**Created**: 2026-08-14

**Status**: Draft

**Input**: User description: "The app will have three sections on the Home screen: jikan: will feature a carousel, followed by two image scrolls following the recommendations; anilist: will feature a carousel, followed by two image scrolls following the recommendations; kitsu: will have the carousel, followed by two scrollable sections with images based on the recommendations. All carousels should load only 10 images at a time to avoid exceeding the request limit, and the scrollable sections will be infinite, displaying 10 images at a time"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Per-provider Home Sections (Priority: P1)

The Home screen is organized into three sections — one per catalog provider
(Jikan, AniList, Kitsu) — and each section opens with a featured carousel
followed by two horizontal image rows populated from that provider's
recommendations. A user lands on the Home screen and sees all three sections
with their carousel and two rows, and can tap any title to open its details.

**Why this priority**: This is the core of the request — the screen structure
every other behavior hangs off. Without it, there is no feature.

**Independent Test**: Can be fully tested by opening the Home screen and
verifying three provider sections render, each with a carousel plus two image
rows containing real titles and 2:3 posters.

**Acceptance Scenarios**:

1. **Given** the app is open on the Home screen, **When** the screen finishes
   loading, **Then** three provider sections appear in order (Jikan, AniList,
   Kitsu), each containing a carousel and two horizontally scrollable rows.
2. **Given** a provider section is visible, **When** the user taps any title,
   **Then** the title's detail screen opens.
3. **Given** one provider fails to respond, **When** the Home screen loads,
   **Then** that provider's section shows a retryable error while the other two
   sections render normally.

---

### User Story 2 - Ten-at-a-Time Carousel Loading (Priority: P1)

Every carousel on the Home screen loads a strict maximum of 10 titles at a
time, so the provider's request limit is not exceeded during normal use. The
carousel shows exactly the 10 loaded titles and does not request more until
the user interacts with it.

**Why this priority**: The user explicitly requested the 10-item cap to avoid
hitting provider request limits; it is a hard constraint on the primary
experience.

**Independent Test**: Can be fully tested by loading the Home screen and
confirming each of the three carousels fetched exactly 10 titles (no more) on
its initial load, and that no further requests occur without user action.

**Acceptance Scenarios**:

1. **Given** the Home screen has just loaded, **When** the carousels finish,
   **Then** each carousel contains exactly 10 titles.
2. **Given** a carousel is idle on screen, **When** the user does not interact,
   **Then** no additional title requests are made for that carousel.

---

### User Story 3 - Infinite Recommendation Rows (Priority: P2)

The two recommendation rows in each provider section are infinite: as the user
scrolls to the end of a row, the next 10 titles load automatically and the row
keeps scrolling. This continues until the provider has no more titles, at
which point loading stops cleanly.

**Why this priority**: Core to the "infinite" requirement, but secondary to
having the sections and 10-item carousel cap in place first.

**Independent Test**: Can be fully tested by scrolling a recommendation row to
its end and confirming a new page of 10 titles loads automatically, repeating
until the provider's catalog is exhausted and the row stops quietly.

**Acceptance Scenarios**:

1. **Given** a recommendation row is scrolled to its last visible title,
   **When** the user reaches the end, **Then** a new batch of exactly 10 titles
   loads and the row extends.
2. **Given** the provider has returned every title it has, **When** the user
   scrolls to the end again, **Then** no further requests are made and the row
   does not show an endless loading indicator.
3. **Given** the user scrolls quickly to the end several times, **When** a page
   is already loading, **Then** only one page request is in flight at a time and
   no duplicate titles are appended.
4. **Given** a page request fails, **When** the row is at the end, **Then** a
   retryable error appears for that row and previously loaded titles remain
   visible.

---

### Edge Cases

- One provider is offline or slow: its section shows loading/error/retry while
  the other two sections keep working.
- A provider returns fewer than 10 titles (or an empty page): the row treats
  it as the end of the catalog and stops loading.
- Fast scrolling to the row end while a page is already loading: no duplicate
  requests, no duplicate titles, no overlapping pages.
- The catalog is exhausted: the row stops silently without an endless spinner.
- A page request fails mid-infinite-scroll: previously loaded titles stay
  visible and the row offers a retry.
- A title appears again in a later page: duplicate titles within a single row
  are avoided so users do not see the same entry twice.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Home screen MUST display three sections — one for each
  catalog provider (Jikan, AniList, Kitsu) — in a fixed, consistent order.
- **FR-002**: Each provider section MUST show a featured carousel followed by
  two horizontally scrollable recommendation rows.
- **FR-003**: Each carousel MUST request at most 10 titles on its initial load.
- **FR-004**: Recommendation rows MUST load the next page automatically when
  the user reaches the end of the row (infinite scroll).
- **FR-005**: Each infinite row MUST request exactly 10 titles per page.
- **FR-006**: The system MUST NOT issue more than one page request at a time
  per row, even under rapid scrolling.
- **FR-007**: When a provider has no more titles, its rows MUST stop loading
  and MUST NOT show a perpetual loading indicator.
- **FR-008**: A failure in one provider's section MUST NOT prevent the other
  two sections from loading and rendering.
- **FR-009**: Each section/row MUST expose clear loading, error, and empty
  states, with retry for errors.
- **FR-010**: Tapping any title in a carousel or row MUST open the title's
  details (reusing the existing detail flow).
- **FR-011**: Duplicate titles within a single row MUST be avoided as pages
  load.

### Key Entities *(include if feature involves data)*

- **CatalogProvider**: One of the three content sources (Jikan, AniList,
  Kitsu). Each owns its section's carousel and rows and its own pagination.
- **CatalogSection**: A provider's block on the Home screen — its featured
  carousel plus its two recommendation rows.
- **CatalogRow**: A single horizontally scrollable, infinitely loading list of
  titles with a 10-item page size and a paging position.
- **Title**: A catalog entry (poster, name, metadata) reusing the existing
  title concept; tap opens details.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: All three provider sections (carousel + two rows each) are
  visible on the Home screen within 3 seconds on a standard connection.
- **SC-002**: Every carousel loads exactly 10 titles on its initial load, and
  no additional carousel requests occur without user action.
- **SC-003**: Each infinite row extends by exactly 10 new titles per automatic
  load and continues until the provider's catalog is exhausted.
- **SC-004**: When any single provider fails, the other two sections still
  render fully and remain interactive.
- **SC-005**: No duplicate titles appear within a single provider section
  across all loaded pages.
- **SC-006**: Infinite rows never show an endless loading state after the end
  of the catalog is reached.

## Assumptions

- The three catalog providers (Jikan, AniList, Kitsu) continue to be the
  content sources for the app, as in the existing catalog browser feature.
- "Recommendations" refers to each provider's default curated/ranked lists
  (already available from the existing integrations); no new recommendation
  algorithm is required.
- The 10-item batch applies to both carousels (initial load) and infinite rows
  (per page).
- "Infinite" rows continue until the provider has no more titles to return,
  then stop cleanly; they are not literally unbounded.
- This feature reworks the existing Home screen layout; existing title detail
  and share behaviors remain unchanged and stay reachable from every title.
- Users have a stable network connection; offline browsing is out of scope for
  this feature.
