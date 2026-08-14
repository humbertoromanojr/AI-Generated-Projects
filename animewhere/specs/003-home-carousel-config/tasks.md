# Tasks: Home Carousel Auto-Slide & Kitsu API Integration

**Input**: Design documents from `/specs/003-home-carousel-config/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, quickstart.md

**Tests**: Tests are REQUIRED for this feature per constitution Principle V (Tested-by-Construction). The project already has unit/widget/integration tests; new behavior MUST ship with tests in the same change.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description with file path`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile (Flutter)**: `lib/`, `test/` at repository root; platform config under `android/` and `ios/`
- Existing project — all files already scaffolded; tasks modify/extend existing files

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Confirm baseline health and configure tooling for this feature

- [X] T001 Run baseline quality gates and confirm green (`dart format` with no diffs, `flutter analyze` zero issues, `flutter test` full suite) before making changes
- [X] T002 [P] Add `flutter_launcher_icons` dev dependency and config block to `pubspec.yaml` (image: `assets/icons/animeWhere.png`, android: true, ios: true)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 Create `lib/core/config/carousel_config.dart` defining `autoSlideInterval` (Duration of 5 seconds) and loop-pause constants used by US1 auto-slide
- [X] T004 Smoke-check the Kitsu Edge API (`GET https://kitsu.io/api/edge/anime?page[limit]=10&page[offset]=0`) returns a JSON body with a `data` list, and record any field/type mismatches with `lib/data/sources/kitsu/kitsu_title_mapper.dart` for US2

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - Automatic Carousel Sliding (Priority: P1) - MVP

**Goal**: All Home carousels (Jikan, AniList, Kitsu) advance automatically every 5 seconds, loop continuously, and yield to manual interaction.

**Independent Test**: Open the Home screen and wait — every carousel advances without any swipe/tap; when the user swipes or taps, auto-slide pauses and resumes after idle. Auto-slide stops when the app is backgrounded.

### Tests for User Story 1

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T005 [P] [US1] Widget test asserting carousel advances page automatically after `autoSlideInterval` without user input in `test/widget/title_carousel_test.dart`
- [X] T006 [P] [US1] Widget test asserting carousel loops from last page back to first in `test/widget/title_carousel_test.dart`
- [X] T007 [P] [US1] Widget test asserting auto-slide pauses on user drag/tap and resumes after idle in `test/widget/title_carousel_test.dart`

### Implementation for User Story 1

- [X] T008 [US1] Add auto-slide `Timer` and `PageController.animateToPage` logic to `_TitleCarouselState` in `lib/ui/home/widgets/title_carousel.dart` using `autoSlideInterval` from `lib/core/config/carousel_config.dart`
- [X] T009 [US1] Implement continuous looping (wrap to first page after last, no dead-end) in `lib/ui/home/widgets/title_carousel.dart`
- [X] T010 [US1] Pause auto-slide on manual interaction (drag/tap) and resume after idle via `NotificationListener<ScrollNotification>`/`onPageChanged` in `lib/ui/home/widgets/title_carousel.dart`
- [X] T011 [US1] Pause/resume auto-slide on app lifecycle changes via `WidgetsBindingObserver` in `lib/ui/home/widgets/title_carousel.dart` (edge case: backgrounding)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Kitsu API Integration Completion (Priority: P1)

**Goal**: The Kitsu provider section fetches and displays titles and images correctly from `https://kitsu.io/api/edge` in carousel and recommendation rows.

**Independent Test**: Open the Home screen and confirm the Kitsu section renders titles with poster images (no broken/blank images); network logs show requests to `https://kitsu.io/api/edge/anime` and `/manga`.

### Tests for User Story 2

> **NOTE: Write these tests FIRST, ensure they FAIL before implementation**

- [X] T012 [P] [US2] Unit test Kitsu mapper handling of Edge API variants (missing `posterImage`, non-string `averageRating`, missing `canonicalTitle`) in `test/unit/mappers/kitsu_title_mapper_test.dart`
- [X] T013 [P] [US2] Unit test Kitsu API query params (`sort`, `page[limit]`, `page[offset]`) for anime/manga endpoints in `test/unit/sources/kitsu_api_test.dart`

### Implementation for User Story 2

- [X] T014 [US2] Fix `_posterImageUrl` in `lib/data/sources/kitsu/kitsu_title_mapper.dart` to fall back through `posterImage` size variants (tiny/small/medium/large/original) per findings from T004
- [X] T015 [US2] Fix `anime()`/`manga()` in `lib/data/sources/kitsu/kitsu_api.dart` query parameters if T004 found mismatches against the Edge API response
- [X] T016 [US2] Verify Kitsu titles/images render in the Kitsu `CatalogSection` on Home and fix any wiring in `lib/ui/home/widgets/catalog_section.dart`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - App Icon Configuration (Priority: P2)

**Goal**: The installed app shows the name "AW" and the launcher icon from `assets/icons/animeWhere.png`.

**Independent Test**: Build and install the app on a device/emulator; the launcher icon matches `assets/icons/animeWhere.png` and the app label reads "AW".

### Implementation for User Story 3

- [X] T017 [US3] Run `dart run flutter_launcher_icons` to generate Android mipmap and iOS app-icon assets from `assets/icons/animeWhere.png`
- [X] T018 [P] [US3] Set `android:label="AW"` on `<application>` in `android/app/src/main/AndroidManifest.xml`
- [X] T019 [P] [US3] Set `CFBundleDisplayName` to `AW` in `ios/Runner/Info.plist`
- [X] T020 [P] [US3] Verify generated icons are referenced in `android/app/src/main/res/mipmap-*/` and `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (no default Flutter icon remains)

**Checkpoint**: At this point, User Stories 1, 2 AND 3 should all work independently

---

## Phase 6: User Story 4 - Layout Consistency via Stitch (Priority: P3)

**Goal**: The Home screen layout matches the `/stitch` design references (section titles jikan/anilist/kitsu, spacing, typography, 2:3 posters, glassmorphism).

**Independent Test**: Compare the rendered Home screen against `stitch/animewhere/DESIGN.md`; zero layout discrepancies for section order, titles, spacing, and card aspect ratios.

### Tests for User Story 4

- [X] T021 [P] [US4] Widget test asserting Home renders three sections labeled `jikan`, `anilist`, `kitsu` in order in `test/widget/home_view_test.dart`

### Implementation for User Story 4

- [X] T022 [US4] Audit `lib/ui/home/home_view.dart` against `stitch/animewhere/DESIGN.md`; fix section ordering, section titles, and vertical spacing deviations
- [X] T023 [P] [US4] Audit `lib/ui/home/widgets/title_carousel.dart` and `lib/ui/home/widgets/infinite_title_row.dart` against stitch tokens (2:3 poster aspect ratio, glassmorphism not shadows)
- [X] T024 [US4] Update `lib/app/theme/app_theme.dart` and `lib/app/theme/app_text_theme.dart` to map any stitch tokens currently missing from `ThemeData`

**Checkpoint**: All user stories should now be independently functional

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories

- [X] T025 [P] Run `dart format` and `flutter analyze`; fix all formatting and lint issues
- [X] T026 Run the full `flutter test` suite and fix any regressions across `test/unit/`, `test/widget/`, `test/integration/`
- [X] T027 Run `quickstart.md` validation scenarios (auto-slide, Kitsu image display, AW icon/name, stitch layout) and record outcomes
- [X] T028 [P] Update any stale documentation references (e.g., app name "animewhere" -> "AW") in `README.md` and `specs/003-home-carousel-config/` artifacts

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - US1 (T005-T011) and US2 (T012-T016) can proceed in parallel (touch different files)
  - US3 (T017-T020) is fully independent (platform config + pubspec only)
  - US4 (T021-T024) depends on US1 and US2 being merged (shared files: `title_carousel.dart`, `home_view.dart`)
- **Polish (Phase 7)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - no dependencies on other stories
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - independent of US1
- **User Story 3 (P2)**: Can start after Setup (T002) - independent of US1/US2
- **User Story 4 (P3)**: Can start after US1 and US2 merge (shared UI files) - should be independently testable

### Within Each User Story

- Tests (included per constitution) MUST be written and FAIL before implementation
- Test scaffolding before implementation logic
- Core implementation before integration/verification
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes: US1, US2, and US3 can start in parallel (different files)
- All tests within a user story marked [P] can run in parallel
- US4 starts only after US1 + US2 merge (shared file conflicts)
- Polish tasks marked [P] run in parallel; T026 depends on T025

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (tests first, expected to FAIL):
Task: "Widget test for auto-slide advance in test/widget/title_carousel_test.dart"
Task: "Widget test for continuous loop in test/widget/title_carousel_test.dart"
Task: "Widget test for pause/resume on interaction in test/widget/title_carousel_test.dart"

# Launch implementation tasks after tests fail (sequential, same file):
Task: "Add auto-slide Timer logic in lib/ui/home/widgets/title_carousel.dart"
Task: "Implement continuous looping in lib/ui/home/widgets/title_carousel.dart"
Task: "Pause/resume on user interaction in lib/ui/home/widgets/title_carousel.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (auto-slide carousels)
4. **STOP and VALIDATE**: Test User Story 1 independently (T005-T007 green, manual swipe check)
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational - Foundation ready
2. Add User Story 1 - Test independently - Deploy/Demo (MVP!)
3. Add User Story 2 - Test independently - Deploy/Demo (Kitsu images verified)
4. Add User Story 3 - Test independently - Deploy/Demo (AW branding)
5. Add User Story 4 - Test independently - Deploy/Demo (stitch fidelity)
6. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (auto-slide)
   - Developer B: User Story 2 (Kitsu API)
   - Developer C: User Story 3 (icon + name)
3. US4 starts after US1/US2 merge
4. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
- Kitsu mapper/api already exist (`lib/data/sources/kitsu/`) - US2 tasks fix/verify, not create
- `assets/icons/animeWhere.png` is the source icon asset (952 KB PNG); `flutter_launcher_icons` must be configured in `pubspec.yaml` (T002) before US3
- All UI changes MUST satisfy constitution Principle III (design-system fidelity against `stitch/animewhere/DESIGN.md`)
