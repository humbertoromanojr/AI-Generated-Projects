---

description: "Task list for the Anime & Manga Browser feature"
---

# Tasks: Anime & Manga Browser

**Input**: Design documents from `/specs/001-anime-manga-browser/`

**Prerequisites**: plan.md, spec.md, research.md, data-model.md, contracts/

**Tests**: Test tasks are included in every user story phase. They are MANDATORY
in this project per constitution Principle V (Tested-by-Construction): unit
(mappers, repositories, ViewModels), widget (screens), and integration
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
  `test/integration`)

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and verified toolchain

- [X] T001 Verify scaffold matches the plan: create directories `lib/app`,
      `lib/app/theme`, `lib/core/di`, `lib/core/network`, `lib/core/models`,
      `lib/core/utils`, `lib/data/repositories`, `lib/data/sources/{jikan,
      anilist,kitsu}`, `lib/ui/{home,detail,share,widgets,web/share_preview}`,
      `test/{unit/mappers,unit/repositories,unit/view_models,widget,integration}`
- [X] T002 [P] Add runtime dependencies via `flutter pub add provider go_router
      http share_plus cached_network_image` in `pubspec.yaml`
- [X] T003 [P] Add dev dependency `flutter_lints` (already ^6.0.0) and confirm
      `analysis_options.yaml` enables the recommended flutter_lints set
- [X] T004 Replace the demo counter scaffold in `lib/main.dart` and
      `test/widget_test.dart` with a minimal placeholder entry point (a
      `MaterialApp` stub) so the project compiles; remove `MyApp`/
      `MyHomePage` demo code

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story
can be implemented

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T005 [P] Create `TitleSource` enum (`jikan | anilist | kitsu`) in
      `lib/core/models/title_source.dart`
- [X] T006 [P] Create immutable `Title` model (required: id, source, kind,
      title, imageUrl; optional: description, score, seasonYear, format,
      providerUrl; `copyWith`; validation helpers) in
      `lib/core/models/title.dart`
- [X] T007 [P] Create immutable `Collection` model and `HomeCatalog` (carousel +
      rows) in `lib/core/models/collection.dart`
- [X] T008 [P] Create typed error taxonomy (`NetworkError`, `HttpError`,
      `RateLimitError`, `ParseError`) in `lib/core/network/network_error.dart`
- [X] T009 [P] Create shared `http` client wrapper (timeouts, JSON headers,
      error mapping) in `lib/core/network/http_client.dart`
- [X] T010 [P] Create `Result<T>` union (loading/data/error/empty) in
      `lib/core/utils/result.dart`
- [X] T011 [P] Create `AppTheme` mapping the DESIGN.md color tokens one-to-one
      (primary #adc6ff, surface #131313, surface-bright #262626,
      surface-container-lowest #0e0e0e, error #ffb4ab, 5% white glass tint)
      into a Material 3 `ColorScheme` in `lib/app/theme/app_theme.dart`
- [X] T012 [P] Create `AppTextTheme` with the Inter type scale (display,
      headline-lg, headline-md, body-lg, body-md, label-md, label-sm) and
      radii/spacing tokens from `stitch/animewhere/DESIGN.md` in
      `lib/app/theme/app_text_theme.dart`
- [X] T013 Create `AnimeWhereApp` with `MaterialApp` + `GoRouter` route table
      (`/`, `/title/:source/:id`) wired to placeholder views in
      `lib/app/app.dart`
- [X] T014 [P] Create provider DI registrations (http client, repository
      placeholders) in `lib/core/di/providers.dart`
- [X] T015 Update `lib/main.dart` bootstrap to `runApp(const AnimeWhereApp())`
      and remove all remaining demo references (including
      `test/widget_test.dart`)

**Checkpoint**: Foundation ready - user story implementation can now begin in
parallel

---

## Phase 3: User Story 1 - Browse anime and manga (Priority: P1) — MVP

**Goal**: Home screen renders a featured carousel (Jikan top anime) plus three
scroll rows: Trending and Popular (AniList), Latest/Simulcast (Jikan), and
manga (Kitsu), each entry showing a 2:3 poster with a label.

**Independent Test**: Open the app; the carousel and at least two rows populate
with real titles/images; swiping loads more; tapping an entry navigates to the
detail screen.

### Tests for User Story 1 (constitution Principle V — write FIRST, verify FAIL)

- [X] T016 [P] [US1] Add fixture JSON payloads (Jikan top/seasons, AniList
      Page.media, Kitsu manga) in `test/fixtures/`
- [X] T017 [P] [US1] Unit test `JikanTitleMapper` (valid + malformed entries
      skipped) in `test/unit/mappers/jikan_title_mapper_test.dart`
- [X] T018 [P] [US1] Unit test `AniListTitleMapper` in
      `test/unit/mappers/anilist_title_mapper_test.dart`
- [X] T019 [P] [US1] Unit test `KitsuTitleMapper` in
      `test/unit/mappers/kitsu_title_mapper_test.dart`
- [X] T020 [P] [US1] Unit test `CatalogRepository` (TTL cache, typed errors,
      per-source failure isolation) in
      `test/unit/repositories/catalog_repository_test.dart`
- [X] T021 [P] [US1] Unit test `HomeViewModel` (loading/data/error states;
      a Jikan failure must not blank AniList/Kitsu rows) in
      `test/unit/view_models/home_view_model_test.dart`

### Implementation for User Story 1

- [X] T022 [P] [US1] Implement Jikan REST client (`GET /top/anime`,
      `GET /seasons/now`, typed parsing) in `lib/data/sources/jikan/jikan_api.dart`
- [X] T023 [P] [US1] Implement `JikanTitleMapper` (score x10 to 0..100;
      validates mal_id/title/large_image_url) in
      `lib/data/sources/jikan/jikan_title_mapper.dart`
- [X] T024 [P] [US1] Define AniList GraphQL queries (Page.media
      TRENDING_DESC perPage 10, POPULARITY_DESC perPage 20) in
      `lib/data/sources/anilist/anilist_queries.dart`
- [X] T025 [P] [US1] Implement AniList client (HTTP POST JSON to
      `https://graphql.anilist.co`) in
      `lib/data/sources/anilist/anilist_api.dart`
- [X] T026 [P] [US1] Implement `AniListTitleMapper` (romaji/english fallback;
      averageScore direct) in
      `lib/data/sources/anilist/anilist_title_mapper.dart`
- [X] T027 [P] [US1] Implement Kitsu REST client
      (`GET /edge/manga?sort=-popularityRank&page[limit]=10`) in
      `lib/data/sources/kitsu/kitsu_api.dart`
- [X] T028 [P] [US1] Implement `KitsuTitleMapper` (JSON:API attributes mapping;
      averageRating direct) in
      `lib/data/sources/kitsu/kitsu_title_mapper.dart`
- [X] T029 [US1] Implement `CatalogRepository` facade: carousel + latest (Jikan),
      trending + popular (AniList), manga (Kitsu) with 5-minute TTL in-memory
      cache and sequential throttled requests in
      `lib/data/repositories/catalog_repository.dart`
- [X] T030 [P] [US1] Create `TitleCard` widget (2:3 poster, short label,
      tap + share affordances) in `lib/ui/widgets/title_card.dart`
- [X] T031 [P] [US1] Create `LoadingView` and `ErrorView` (friendly retry)
      widgets in `lib/ui/widgets/loading_view.dart` and
      `lib/ui/widgets/error_view.dart`
- [X] T032 [P] [US1] Create `TitleCarousel` widget (featured carousel,
      glassmorphic navigation surface) in
      `lib/ui/home/widgets/title_carousel.dart`
- [X] T033 [P] [US1] Create `TitleRow` widget (horizontal scroll row) in
      `lib/ui/home/widgets/title_row.dart`
- [X] T034 [US1] Implement `HomeViewModel` (assembles `HomeCatalog` from the
      repository; independent per-row state) in `lib/ui/home/home_view_model.dart`
- [X] T035 [US1] Implement `HomeView` (carousel + Trending/Popular/Latest/manga
      rows, pull-refresh keeping content visible) in `lib/ui/home/home_view.dart`
- [X] T036 [US1] Wire the `/` route to `HomeView` and register
      `CatalogRepository` in `lib/app/app.dart` and
      `lib/core/di/providers.dart`
- [X] T037 [P] [US1] Widget test `HomeView` (rows render, loading/error/empty
      states) in `test/widget/home_view_test.dart`

**Checkpoint**: At this point, User Story 1 should be fully functional and
testable independently (MVP)

---

## Phase 4: User Story 2 - Share a title on social media (Priority: P2)

**Goal**: Every title exposes a share action producing a link that, when
opened, renders the title image with "AnimeWhere" below it via the hosted web
build (`/title/<source>/<id>`).

**Independent Test**: From any carousel or row entry, tap share -> system share
sheet with the title's link; opening the link in a browser shows the title
image with the app name below it. Cancel leaves no state loss.

### Tests for User Story 2 (constitution Principle V — write FIRST, verify FAIL)

- [X] T038 [P] [US2] Unit test `ShareRepository` URL contract
      (`<web-host>/title/<source>/<id>` per `contracts/share-preview.md`) in
      `test/unit/repositories/share_repository_test.dart`
- [X] T039 [P] [US2] Widget test `SharePreviewView` (image + "AnimeWhere" below)
      in `test/widget/share_preview_view_test.dart`

### Implementation for User Story 2

- [X] T040 [P] [US2] Create `ShareTarget` model (source, id, derived shareUrl)
      in `lib/core/models/share_target.dart`
- [X] T041 [P] [US2] Implement `ShareRepository` (shareUrl builder using the
      deployed web host) in `lib/data/repositories/share_repository.dart`
- [X] T042 [P] [US2] Implement `ShareService` (system share sheet via
      `share_plus`; share completes in <= 3 taps) in `lib/ui/share/share_service.dart`
- [X] T043 [P] [US2] Implement `SharePreviewView` (web entry: fetch title from
      the matching API, render 2:3 poster with "AnimeWhere" below; loading/
      error states) in `lib/ui/web/share_preview/share_preview_view.dart`
- [X] T044 [US2] Wire the web build so `/title/:source/:id` renders
      `SharePreviewView` (web router + `web/index.html` base href) — detail
      route stays native on mobile
- [X] T045 [US2] Wire the share action into `TitleCard`/carousel/rows using
      `ShareService` + `ShareRepository`

**Checkpoint**: At this point, User Stories 1 AND 2 should both work
independently

---

## Phase 5: User Story 3 - View title details (Priority: P3)

**Goal**: Tapping a title opens a detail view (image, description, type,
score) fetched from the source that supplied it; missing optional fields are
omitted gracefully. Share is available from the detail view.

**Independent Test**: Open any title from a Jikan, AniList, or Kitsu source and
verify the detail information renders; a title missing optional data renders
without errors.

### Tests for User Story 3 (constitution Principle V — write FIRST, verify FAIL)

- [X] T047 [P] [US3] Unit test `DetailViewModel` (per-source detail fetch,
      missing-optional-field handling) in
      `test/unit/view_models/detail_view_model_test.dart`
- [X] T048 [P] [US3] Widget test `DetailView` (image, description, type, score)
      in `test/widget/detail_view_test.dart`

### Implementation for User Story 3

- [X] T049 [P] [US3] Add Jikan detail request (`GET /anime/{id}`) in
      `lib/data/sources/jikan/jikan_api.dart`
- [X] T050 [P] [US3] Add AniList `Media(id: $id)` query in
      `lib/data/sources/anilist/anilist_queries.dart` and fetch method in
      `lib/data/sources/anilist/anilist_api.dart`
- [X] T051 [P] [US3] Add Kitsu detail request (`GET /edge/{anime|manga}/{id}`)
      in `lib/data/sources/kitsu/kitsu_api.dart`
- [X] T052 [US3] Implement `DetailViewModel` (fetch by source + id; graceful
      omission of null fields) in `lib/ui/detail/detail_view_model.dart`
- [X] T053 [US3] Implement `DetailView` (image, description, type, score,
      share button) in `lib/ui/detail/detail_view.dart`
- [X] T054 [US3] Wire `/title/:source/:id` to `DetailView` in
      `lib/app/app.dart` and navigation from `TitleCard` taps
- [X] T055 [US3] Integrate the US2 `ShareService` share action into the detail
      view

**Checkpoint**: All user stories should now be independently functional

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories and final
validation

- [X] T056 [P] Add end-to-end integration test (browse -> detail -> share
      journey) in `test/integration/browse_share_test.dart`
- [X] T057 [P] Run the `quickstart.md` validation scenarios manually
      (browse, details, share, failure handling) and record results
- [X] T058 [P] Update `README.md` with setup/run instructions for the app
- [X] T059 [P] Performance pass: verify `cached_network_image` poster caching,
      lazy loading, and placeholder handling on slow networks (SC-002)
- [X] T060 Final quality gate: `dart format` (no diffs), `flutter analyze`
      (0 errors, 0 warnings), `flutter test` (full suite green)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user
  stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can proceed sequentially in priority order (US1 -> US2 -> US3)
- **Polish (Final Phase)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - no
  dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - integrates
  share affordances into US1 components (T045) but is independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - reuses US2
  `ShareService` (T055) but is independently testable

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Mappers/API clients before the repository facade
- ViewModel before View
- View before route wiring
- Story complete before moving to next priority

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] (T005-T014) can run in parallel
- Within US1: contract tests (T016-T021) in parallel; then source clients and
  mappers (T022-T028) in parallel; then widgets (T030-T033) in parallel
- Within US2/US3: tests run first, then their [P] implementation tasks
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```text
# Launch all US1 tests together (write first, verify they fail):
Task: "Add fixture payloads in test/fixtures/"
Task: "JikanTitleMapper test in test/unit/mappers/jikan_title_mapper_test.dart"
Task: "AniListTitleMapper test in test/unit/mappers/anilist_title_mapper_test.dart"
Task: "KitsuTitleMapper test in test/unit/mappers/kitsu_title_mapper_test.dart"
Task: "CatalogRepository test in test/unit/repositories/catalog_repository_test.dart"
Task: "HomeViewModel test in test/unit/view_models/home_view_model_test.dart"

# Launch all three source adapters + mappers together:
Task: "Jikan client in lib/data/sources/jikan/jikan_api.dart"
Task: "JikanTitleMapper in lib/data/sources/jikan/jikan_title_mapper.dart"
Task: "AniList queries + client in lib/data/sources/anilist/"
Task: "Kitsu client in lib/data/sources/kitsu/kitsu_api.dart"
Task: "KitsuTitleMapper in lib/data/sources/kitsu/kitsu_title_mapper.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1 (browse)
4. **STOP and VALIDATE**: Test User Story 1 independently (home renders
   carousel + rows from Jikan/AniList/Kitsu)
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational -> Foundation ready
2. Add User Story 1 -> Test independently -> Deploy/Demo (MVP!)
3. Add User Story 2 (share) -> Test independently -> Deploy/Demo
4. Add User Story 3 (details) -> Test independently -> Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (browse)
   - Developer B: User Story 2 (share)
   - Developer C: User Story 3 (details)
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
- Design token fidelity (Principle III) applies to T011/T012 and every UI
  widget task: match `stitch/animewhere/DESIGN.md` and the `/stitch` mockups
