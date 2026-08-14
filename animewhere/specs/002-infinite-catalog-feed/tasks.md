---

description: "Task list for the Infinite Catalog Feed feature"
---

# Tasks: Infinite Catalog Feed

**Input**: Design documents from `/specs/002-infinite-catalog-feed/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Test tasks are included in every phase. They are MANDATORY in this
project per constitution Principle V (Tested-by-Construction): unit (sources,
mappers, repositories, ViewModels), widget (screens), and integration
(journeys). Write tests first and verify they FAIL before implementing.

**Organization**: Tasks are grouped by user story to enable independent
implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Flutter app: `lib/` and `test/` at repository root (per `plan.md` structure:
  `lib/app`, `lib/core`, `lib/data`, `lib/ui`, `test/unit`, `test/widget`,
  `test/integration`, `test/fixtures`)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Verify the existing toolchain and establish the baseline gate
before any changes. This feature extends the existing project (feature 001
complete), so no scaffolding is required.

- [ ] T001 Run `flutter pub get`, `dart format` (no diffs), `flutter analyze`
      (0 errors, 0 warnings), and `flutter test` (full suite green) to
      establish the baseline before changes
- [ ] T002 [P] Confirm no new dependencies are needed: verify `pubspec.yaml`
      already provides `http` (pagination), `flutter_test` +
      `integration_test` (paging tests), and `cached_network_image` (lazy
      posters)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core data-layer infrastructure that MUST be complete before ANY
user story can be implemented — pagination across all three source adapters,
the `TitlePage` result, Kitsu anime kind, and the page-based repository with a
per-page cache. Blocking: the home sections (US1) need first pages, carousels
(US2) need the 10-item cap, and infinite rows (US3) need subsequent pages.

**CRITICAL**: No user story work can begin until this phase is complete

### Tests for Foundational (constitution Principle V — write FIRST, verify FAIL)

- [ ] T003 [P] Unit test `JikanApi` pagination (`page`/`limit` passthrough,
      `seasonsUpcoming` hitting `/seasons/upcoming`) via MockClient in
      `test/unit/sources/jikan_api_test.dart`
- [ ] T004 [P] Unit test `AniListApi` pagination (`page`/`perPage` variables,
      `topRatedAnime` sending `SCORE_DESC`) via MockClient in
      `test/unit/sources/anilist_api_test.dart`
- [ ] T005 [P] Unit test `KitsuApi` pagination (`page[offset]` = page*10,
      `anime()` hitting `/edge/anime`) via MockClient in
      `test/unit/sources/kitsu_api_test.dart`
- [ ] T006 [P] Extend `KitsuTitleMapper` test: anime items map to
      `TitleKind.anime` via the JSON:API `type` field in
      `test/unit/mappers/kitsu_title_mapper_test.dart`
- [ ] T007 [P] Rework `CatalogRepository` test: page-based accessors return
      `Result<TitlePage>`, `hasMore` flips at <10 items, per-page cache
      distinct per page in `test/unit/repositories/catalog_repository_test.dart`

### Implementation for Foundational

- [ ] T008 Create immutable `TitlePage` model (`titles: List<Title>`,
      `hasMore: bool`) in `lib/core/models/title_page.dart`
- [ ] T009 [P] Add `page` param to `topAnime`/`seasonsNow` and add
      `seasonsUpcoming({page, limit = 10})` (`GET /seasons/upcoming`) in
      `lib/data/sources/jikan/jikan_api.dart`
- [ ] T010 [P] Add `page` variable to `AniListQueries.pageQuery` and add
      `topRatedAnime({page, perPage = 10})` (`sort: SCORE_DESC`) + pass `page`
      on existing feeds in `lib/data/sources/anilist/anilist_queries.dart` and
      `lib/data/sources/anilist/anilist_api.dart`
- [ ] T011 [P] Replace `page[limit]`-only paging with `page[limit]=10` +
      `page[offset]=page*10` on `manga` and add `anime({page})`
      (`GET /edge/anime?sort=-popularityRank`) in
      `lib/data/sources/kitsu/kitsu_api.dart`
- [ ] T012 [P] Derive `Title.kind` from the item-level `type` field (`anime`
      -> `TitleKind.anime`, otherwise `manga`) in
      `lib/data/sources/kitsu/kitsu_title_mapper.dart`
- [ ] T013 Rework `CatalogRepository` to page-based accessors returning
      `Result<TitlePage>`: `jikanCarousel()`/`anilistCarousel()`/
      `kitsuCarousel()` (fixed page 1, 10 items) and paged row accessors
      (`jikanSeasonal(page)`, `jikanUpcoming(page)`, `anilistPopular(page)`,
      `anilistTopRated(page)`, `kitsuManga(page)`, `kitsuAnime(page)`) with a
      per-page TTL cache keyed `"<feed>:<page>"` in
      `lib/data/repositories/catalog_repository.dart`

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Per-provider Home Sections (Priority: P1) — MVP

**Goal**: The Home screen renders three labeled sections — **jikan**,
**anilist**, **kitsu** (fixed order) — each with a featured carousel and two
horizontally scrollable recommendation rows populated from that provider;
tapping a title opens its details; a failure in one provider's section does
not blank the other two.

**Independent Test**: Open the app; three section headers appear in order, each
with a carousel plus two rows of real 2:3 posters; tapping any title opens
detail; blocking one API only errors that section.

### Tests for User Story 1 (constitution Principle V — write FIRST, verify FAIL)

- [ ] T014 [P] [US1] Rework `HomeViewModel` unit test: three sections
      (`jikan`/`anilist`/`kitsu`), each with carousel + two rows; initial
      load populates first pages; one provider failing keeps the other two
      sections loaded in `test/unit/view_models/home_view_model_test.dart`
- [ ] T015 [P] [US1] Rework `HomeView` widget test: three section headers in
      order, carousel + two rows per section, tap navigates to detail,
      loading/error/empty states in `test/widget/home_view_test.dart`

### Implementation for User Story 1

- [ ] T016 [US1] Add `SectionState` (id, label, carousel result, rows) and
      `InfiniteRowState` (id, label, titles, nextPage, hasMore, isLoadingMore,
      loadFailed) containers in `lib/ui/home/home_view_model.dart`
- [ ] T017 [US1] Implement `HomeViewModel` section composition: `load()`
      fetches all carousels + first row pages concurrently via `Future.wait`,
      each section independent (isolation per FR-008), refresh keeps previous
      content in `lib/ui/home/home_view_model.dart`
- [ ] T018 [P] [US1] Create `CatalogSection` widget (label header + carousel +
      two rows, tap/share/retry wiring) in `lib/ui/home/widgets/catalog_section.dart`
- [ ] T019 [P] [US1] Create `InfiniteTitleRow` widget (horizontal list of
      accumulated titles, loading/error/empty states, retry affordance; the
      load-more trigger arrives in US3) in `lib/ui/home/widgets/infinite_title_row.dart`
- [ ] T020 [US1] Rework `HomeView` to render three `CatalogSection`s in fixed
      order (`jikan`, `anilist`, `kitsu`) in `lib/ui/home/home_view.dart`
- [ ] T021 [US1] Delete `lib/ui/home/widgets/title_row.dart` and update all
      imports/references (`home_view.dart`) to `InfiniteTitleRow`
- [ ] T022 [P] [US1] Add fixtures `jikan_seasons_upcoming.json` and
      `kitsu_anime.json`, and extend the `browse_share_test` MockClient to
      serve `/seasons/upcoming`, `/edge/anime`, and AniList Page queries in
      `test/fixtures/` and `test/integration/browse_share_test.dart`

**Checkpoint**: User Story 1 fully functional and testable independently (MVP)

---

## Phase 4: User Story 2 - Ten-at-a-Time Carousel Loading (Priority: P1)

**Goal**: Every carousel loads exactly 10 titles on its initial load and makes
no further requests while idle, protecting provider request limits.

**Independent Test**: Fresh home load shows each carousel with exactly 10
items (counter reads `1 / 10`); leaving the screen idle triggers no additional
carousel requests.

### Tests for User Story 2 (constitution Principle V — write FIRST, verify FAIL)

- [ ] T023 [P] [US2] Unit test carousel accessors request exactly 10 titles
      once (fixed page 1, limit/perPage/page[limit] = 10, no page param
      exposed) in `test/unit/repositories/catalog_repository_test.dart`
- [ ] T024 [P] [US2] Widget test: carousels render exactly 10 items and issue
      no further requests while idle (request-count assertion via fake APIs)
      in `test/widget/home_view_test.dart`

### Implementation for User Story 2

- [ ] T025 [US2] Pin carousel accessors (`jikanCarousel`, `anilistCarousel`,
      `kitsuCarousel`) to page 1 with 10-item page size (no page parameter on
      carousel accessors) in `lib/data/repositories/catalog_repository.dart`
- [ ] T026 [US2] Ensure `HomeViewModel` issues exactly one carousel request per
      section on `load()` with no polling or idle auto-refetch in
      `lib/ui/home/home_view_model.dart`

**Checkpoint**: User Stories 1 AND 2 both work independently

---

## Phase 5: User Story 3 - Infinite Recommendation Rows (Priority: P2)

**Goal**: The two recommendation rows in each section are infinite: scrolling
to a row's end loads the next 10 titles automatically, with at most one
in-flight request per row, no duplicate titles, a clean stop at catalog end,
and retry on failure.

**Independent Test**: Scroll any row to its end; a new batch of exactly 10
loads and the row extends; rapid flicking never duplicates titles or issues
parallel loads; at catalog end the row stops without an endless spinner.

### Tests for User Story 3 (constitution Principle V — write FIRST, verify FAIL)

- [ ] T027 [P] [US3] Unit test `HomeViewModel.loadMore`: appends next page
      exactly, single-flight guard blocks overlapping loads, `hasMore` flips
      false on a short page, duplicates (source+id) skipped, failure keeps
      loaded titles and sets retry state in
      `test/unit/view_models/home_view_model_test.dart`
- [ ] T028 [P] [US3] Widget test `InfiniteTitleRow`: scrolling near the end
      triggers `onLoadMore`, trailing spinner while loading, end marker at
      exhaustion, row error with retry in `test/widget/home_view_test.dart`

### Implementation for User Story 3

- [ ] T029 [US3] Implement `HomeViewModel.loadMore(section, row)`: guarded by
      `isLoadingMore`, appends next page, dedupes by `source`+`id`, flips
      `hasMore` false on a page with <10 items, sets `loadFailed` on error
      without discarding titles in `lib/ui/home/home_view_model.dart`
- [ ] T030 [US3] Add the scroll trigger to `InfiniteTitleRow` (ScrollController
      fires `onLoadMore` within ~200px of max extent when `hasMore` and not
      loading), plus trailing mini-spinner, quiet end marker, and row-level
      retry in `lib/ui/home/widgets/infinite_title_row.dart`

**Checkpoint**: All user stories independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final
validation

- [ ] T031 [P] Run the full integration journey (browse 3-section home ->
      detail -> share) with the extended MockClient fixtures in
      `test/integration/browse_share_test.dart`
- [ ] T032 [P] Run the `quickstart.md` validation scenarios manually (three
      sections, 10-item carousels, infinite rows, failure isolation, detail/
      share regression) and record results in
      `specs/002-infinite-catalog-feed/validation-results.md`
- [ ] T033 [P] Performance pass: verify per-page cache prevents duplicate
      requests, lazy `cached_network_image` posters, and no unbounded memory
      growth on rapid infinite scrolling (SC-003)
- [ ] T034 [P] Update `README.md` if it documents the home layout (three
      provider sections, infinite rows)
- [ ] T035 Final quality gate: `dart format` (no diffs), `flutter analyze`
      (0 errors, 0 warnings), `flutter test` (full suite green)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - baseline gate only
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user
  stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories proceed sequentially in priority order (US1 -> US2 -> US3)
- **Polish (Final Phase)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - no
  dependencies on other stories (MVP)
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - enforces the
  carousel cap established by the carousel accessors (T013/T025)
- **User Story 3 (P2)**: Can start after Foundational (Phase 2) - consumes the
  paged row accessors (T013) and the `InfiniteRowState` scaffold (T016)

### Within Each Phase

- Tests MUST be written and FAIL before implementation
- Data-layer (models/accessors) before ViewModel, ViewModel before View
- View before route wiring
- Phase complete before moving to the next

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- Foundational tests (T003-T007) in parallel; then source API changes
  (T009-T012) in parallel; repository rework (T013) last within the phase
- Within US1: tests (T014-T015) first; then section widgets (T018-T019) and
  fixtures (T022) in parallel, VM (T016-T017) and HomeView (T020-T021)
  sequentially after
- Within US2/US3: tests first, then their [P] implementation tasks
- Different user stories can be worked on in parallel by different team members
  (after Foundational)

---

## Parallel Example: User Story 1

```text
# Launch all US1 tests together (write first, verify they fail):
Task: "Rework HomeViewModel unit test in test/unit/view_models/home_view_model_test.dart"
Task: "Rework HomeView widget test in test/widget/home_view_test.dart"

# Launch section widgets + fixtures together:
Task: "CatalogSection widget in lib/ui/home/widgets/catalog_section.dart"
Task: "InfiniteTitleRow widget in lib/ui/home/widgets/infinite_title_row.dart"
Task: "Add fixtures + extend MockClient in test/fixtures/ and test/integration/browse_share_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (baseline gate)
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (three provider sections render + navigate)
4. **STOP and VALIDATE**: Test User Story 1 independently (three sections,
   carousel + rows, tap -> detail, isolation)
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational -> Foundation ready
2. Add User Story 1 -> Test independently -> Deploy/Demo (MVP!)
3. Add User Story 2 (10-item carousels) -> Test independently -> Deploy/Demo
4. Add User Story 3 (infinite rows) -> Test independently -> Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (sections)
   - Developer B: User Story 2 (carousel cap)
   - Developer C: User Story 3 (infinite rows)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing (Principle V)
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break
  independence
- Design token fidelity (Principle III) applies to every UI widget task
  (T018-T020, T030): match `stitch/animewhere/DESIGN.md` and the `/stitch`
  mockups; posters stay 2:3; glassmorphism over shadows
