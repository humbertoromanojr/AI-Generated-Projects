# Data Model: Home Carousel & Kitsu API Integration

## Entities

### 1. CatalogProvider (Enum)
Represents the three supported content sources.
- **Values**: `jikan`, `anilist`, `kitsu`

### 2. Title (Domain Model)
The core unit of content displayed in carousels and rows.
- **Fields**:
    - `id`: Unique identifier from the provider (String).
    - `name`: Display name of the anime/manga (String).
    - `posterUrl`: URL to the primary image asset (String/URL).
    - `provider`: The source of this title (`CatalogProvider`).

### 3. CatalogSectionState (UI State)
Represents the state of a single provider section on the Home screen.
- **Fields**:
    - `provider`: Associated `CatalogProvider`.
    - `carouselTitles`: List of titles currently in the carousel [`List<Title>`].
    - `recommendationRows`: List of active rows [`List<List<Title>>`].
    - `isLoading`: Indicates if a request is in flight (`bool`).
    - `error`: Potential error message or object (`String?`).

### 4. CarouselControllerState (UI State)
Man*ages the automatic sliding behavior.
- **Fields**:
    - `isAutoSliding`: Whether the timer is currently active (`bool`).
    - `currentPageIndex`: The current visible item index (`int`).
    - `intervalSeconds`: User-configurable or fixed duration for slide transition (`int`).

## Validation Rules

- **Title Integrity**: Every `Title` MUST have a non-null `name` and a valid, reachable `posterUrl`.
- **Provider Isolation**: A failure in one `CatalogSectionState` (e.g., `error != null`) must not affect the state of other sections.
- **Pagination Bounds**: The number of items requested in any single batch MUST be exactly 10 titles to comply with rate limits.

## State Transitions

1. **Initial Load**: `Loading` $\rightarrow$ `Loaded (Empty or populated)`.
2. **Carousel Transition**: `Page X` $\rightarrow$ `Page X + 1` (automatic via timer OR manual via swipe).
3. **Pagination Trigger**: When user reaches end of row $\rightarrow$ `Trigger Fetch` $\rightarrow$ `Update List with new items`.
4. **Error Recovery**: `Error State` $\rightarrow$ `Retry Attempted` $\rightarrow$ `Loading` $\rightarrow$ `Loaded/Error`.
