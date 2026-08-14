# Feature Specification: Home Carousel Auto-Slide & Kitsu API Configuration

**Feature Branch**: `003-home-carousel-config`

**Created**: 2026-08-14

**Status**: Draft

**Input**: User description: "- Change the settings on the home screen so that the carousels run automatically, with the images switching to automatic slide mode
- Configure the API at https://kitsu.io/api/edge to ensure it works properly and displays the images
- When the app is installed, display the icon on the phone that is located in the /assets/icons folder, with the name “AW”
- Review the /stitch folder to ensure the app’s layout matches"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Automatic Carousel Sliding (Priority: P1)

The Home screen carousels for Jikan, AniList, and Kitsu should no longer require manual interaction to advance. Instead, they should automatically transition through the available images/titles at a regular interval, providing a dynamic and engaging experience for the user as soon as they arrive on the Home screen.

**Why this priority**: This is a direct change to the core UI behavior and primary engagement mechanism of the app's home screen.

**Independent Test**: Open the Home screen and verify that the carousels for all providers (Jikan, AniList, Kitsu) advance their content automatically without any user swipes or taps.

**Acceptance Scenarios**:

1. **Given** the user is on the Home screen, **When** the app has loaded, **Then** the featured carousels start rotating through their images/titles automatically.
2. **Given** a carousel is auto-sliding, **When** the user interacts with it (e.g., taps or swipes), **Then** the automatic sliding pauses or resets to allow manual control.

---

### User Story 2 - Kitsu API Integration Completion (Priority: P1)

The Kitsu provider section on the Home screen must correctly fetch and display images from the `https://kitsu.io/api/edge` endpoint. This involves ensuring the API adapter is properly configured to parse the specific response structure of the Kitsu edge API so that posters and titles are visible in the carousel and recommendation rows.

**Why this priority**: The app's value depends on having all three providers (Jikan, AniList, Kitsu) working perfectly. Failing to display Kitsu content would mean a broken feature for a major provider.

**Independent Test**: Inspect the network traffic for Kitsu requests and verify that the parsed data correctly populates the Kitsu section with valid titles and images.

**Acceptance Scenarios**:

1. **Given** the app is running, **When** the Kitsu section loads on the Home screen, **Then** it successfully fetches data from `https://kitsu.io/api/edge`.
2. **Given** a successful API response from Kitsu, **When** the UI renders the Kitsu section, **Then** all titles and corresponding images are clearly visible.

---

### User Story 3 - App Icon Configuration (Priority: P2)

Upon installation of the app on a physical device or emulator, the application should present a professional identity by using the specific icon asset located in `/assets/icons`. The icon name/identifier used for the build configuration should reflect "AW".

**Why this priority**: This is part of the app's branding and professional polish, essential for a completed installation experience.

**Independent Test**: Install the generated build on a device/emulator and verify that the app icon displayed on the home screen matches the asset in `/assets/icons`.

**Acceptance Scenarios**:

1. **Given** an app installation is complete, **When** looking at the device's home screen, **Then** the "AW" icon from the assets folder is visible and used as the launcher.

---

### User Story 4 - Layout Consistency via Stitch (Priority: P3)

The application's visual layout and component structure must align with the design specifications/references found in the `/stitch` folder. This ensures that the implementation of carousels, rows, and provider sections follows the intended design system.

**Why this priority**: Ensures design-to-code fidelity and prevents UI regressions or deviations from the established brand style.

**Independent Test**: Compare the rendered UI of the Home screen against the design references in the `/stitch` directory.

**')): 
1. **Given** a new layout implementation, **When** compared to the `/stitch` designs, **Then** all spacing, typography, and component structures are identical.

---

### Edge Cases

- Kitsu API is down or returns an error: The Kitsu section should show a retryable error state while Jikan and AniList sections continue to work perfectly (reusing existing error handling patterns).
- Rapidly switching between apps or backgrounding: The auto-slide timer should pause when the app is in the background to save resources.
- Slow network during Kitsu fetch: The UI should show a loading state instead of an empty or broken section.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-01**: Home screen carousels for Jikan, AniList, and Kitsu MUST transition automatically without user input.
- **FR-02**: The automatic slide interval should be consistent (e.g., 5 seconds) and customizable if possible via settings.
- **FR-03**: The app MUST use the assets located in `/assets/icons` for its launcher icon.
- **FR-04**: The Kitsu API integration MUST correctly interact with `https://kitsu.io/api/edge`.
- **FR-05**: The Kitsu provider section MUST successfully display title information and images fetched from the API.
- **FR-06**: The layout of all Home screen components (carousels, rows) MUST match the design references in the `/stitch` directory.

### Key Entities *(include if feature involves data)*

- **Carousel**: A rotating UI component for featured content.
- **KitsuAPIAdapter**: The service/logic responsible for fetching and parsing data from the Kitsu edge API.
- **AppIcon**: The visual asset used for the application launcher.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-01**: 100% of providers (Jikan, AniList, Kitsu) display content successfully on the Home screen.
- **SC-02**: All carousels transition between items automatically with a consistent interval.
- **SC-03**: The application icon on the device matches the source asset in `/assets/launcher`.
- **SC-04**: Zero layout discrepancies are identified when comparing implemented UI to `/stitch` design references.

## Assumptions

- The automatic slide functionality should pause when the user manually interacts with a carousel (swiping or tapping).
- The Kitsu API endpoint provided is the correct and sole source for Kitsu data integration.
- The `/stitch` folder contains the definitive visual source of truth for the app's design system.
- All existing error handling and loading patterns from previous features can be reused for the Kitsu API failure scenarios.
