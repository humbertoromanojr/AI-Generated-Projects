---

description: "Task list for feature implementation"
---

# Tasks: Kitsu Section Verification & Share Branding

**Input**: Design documents from `specs/004-kitsu-search-share/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md

**Tests**: Test tasks are included per the constitution's Tested-by-Construction
principle and the project's established RED-first unit/widget test convention.

**Organization**: Tasks are grouped by user story to enable independent
implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- **Mobile app**: `lib/` (Flutter source), `test/` (unit/widget/integration)
- All US1 changes confined to the Kitsu section: `lib/data/sources/kitsu/` and
  Kitsu-specific test files. No changes to Jikan, AniList, or shared Home
  layout code.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare the repository for feature work and confirm the baseline.

- [X] T001 Create the feature branch `004-kitsu-search-share` from `main` and
      confirm `specs/004-kitsu-search-share/` (plan.md, spec.md, research.md,
      data-model.md, quickstart.md, checklists/requirements.md) is present
- [X] T002 [P] Confirm baseline gates: `flutter analyze` reports zero issues and
      `flutter test` reports the full suite green (81 tests) before any change

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Verify the Kitsu section data flow against the plan so US1
implementation targets only real gaps.

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 Trace the Kitsu section end-to-end
      (`KitsuApi` -> `CatalogRepository.kitsu*` -> `HomeViewModel` kitsu
      section in `lib/ui/home/home_view_model.dart`) against `research.md`;
      record any conformance gap found as a follow-up US1 task

**Checkpoint**: Foundation verified - US1 and US2 implementation can begin.

---

## Phase 3: User Story 1 - Kitsu section works against the live API (Priority: P1) - MVP

**Goal**: The Kitsu carousel and both infinite scroll rows (Anime, Manga)
work against the documented Kitsu API. Root-cause fixes from research: add a
Kitsu-scoped `User-Agent` + JSON:API `Accept` header, and route `detail()` by
the returned resource type.

**Independent Test**: Launch the app - the Kitsu carousel renders up to 10
titles with posters; both rows page 10 titles at a time indefinitely without
duplicates and stop at the catalog end; anime AND manga titles open on detail
(no 404); a forced Kitsu failure shows a per-section retry without affecting
Jikan/AniList. Unit tests cover request headers and detail endpoint routing.

### Tests for User Story 1 (write FIRST, ensure they FAIL before implementation)

- [X] T004 [P] [US1] Add test asserting every Kitsu request sends a
      `User-Agent` header and `Accept: application/vnd.api+json` in
      `test/unit/sources/kitsu_api_test.dart` (RED)
- [X] T005 [P] [US1] Add test asserting `detail()` hits `/anime/{id}` when the
      response record `type` is `anime` and `/manga/{id}` otherwise in
      `test/unit/sources/kitsu_detail_test.dart` (RED)

### Implementation for User Story 1

- [X] T006 [US1] Add Kitsu-scoped request headers (`User-Agent` and `Accept:
      application/vnd.api+json`) to the requests made in
      `lib/data/sources/kitsu/kitsu_api.dart` without changing the shared
      `AppHttpClient` defaults used by Jikan/AniList
- [X] T007 [US1] Fix `detail(String id)` in
      `lib/data/sources/kitsu/kitsu_api.dart` to issue `/anime/{id}` when the
      parsed record `type` is `anime` and `/manga/{id}` otherwise
      (depends on T005, T006)
- [X] T008 [US1] Verify `KitsuTitleMapper` (in
      `lib/data/sources/kitsu/kitsu_title_mapper.dart`) continues to expose
      `kind`/poster correctly for both types; adjust only if detail routing
      requires the record type to be surfaced
- [X] T009 [US1] Verify infinite-scroll behavior for Kitsu rows (page of fewer
      than 10 titles stops `hasMore`; de-duplication by `(source, id)`; no
      overlapping page requests) via `test/unit/repositories/catalog_repository_test.dart`
      and `test/unit/view_models/home_view_model_test.dart`; add coverage only
      if a gap is found
- [X] T010 [US1] Run `dart format`, `flutter analyze`, `flutter test`; confirm
      all US1 tests pass and the full suite is green

**Checkpoint**: US1 fully functional and independently testable.

---

## Phase 4: User Story 2 - Share includes app branding and download link (Priority: P1)

**Goal**: Shared content for any title displays the app image, the app name
"AW - AnimeWhere", and a download link in addition to the title share URL.

**Independent Test**: Share a title from any source (Jikan, AniList, Kitsu).
The shared content shows the app image, the name "AW - AnimeWhere", and a
download link that resolves to a reachable page. Platforms without image
support still show the name and download link.

### Tests for User Story 2 (write FIRST, ensure they FAIL before implementation)

- [X] T011 [P] [US2] Add test asserting `ShareRepository.targetFor` returns a
      target carrying `appName == "AW - AnimeWhere"`, an app image URL, and a
      `downloadUrl` derived from the web host in
      `test/unit/repositories/share_repository_test.dart` (RED)
- [X] T012 [P] [US2] Add widget test asserting the share preview renders the
      app image, "AW - AnimeWhere", and a download link in
      `test/widget/share_preview_view_test.dart` (RED)

### Implementation for User Story 2

- [X] T013 [US2] Extend `ShareTarget` (in `lib/core/models/share_target.dart`)
      with `appName` (String), `appImageUrl` (String?), and `downloadUrl`
      (String) fields (depends on T011)
- [X] T014 [US2] Populate the branding fields in `ShareRepository.targetFor`
      in `lib/data/repositories/share_repository.dart`:
      `appName = "AW - AnimeWhere"`, app image URL from the app icon asset, and
      `downloadUrl` pointing to the web-host download/landing page
- [X] T015 [US2] Update `ShareService.shareTitle` in
      `lib/ui/share/share_service.dart` to include the app name and download
      link in the shared text and attach the app image where the platform
      share sheet supports images (depends on T014)
- [X] T016 [US2] Add the branding (app image, app name "AW - AnimeWhere",
      download link) to the web share preview in
      `lib/ui/web/share_preview/share_preview_view.dart` (depends on T012)
- [X] T017 [US2] Run `dart format`, `flutter analyze`, `flutter test`; confirm
      all US2 tests pass and the full suite is green

**Checkpoint**: US1 AND US2 both work independently.

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Documentation and end-to-end validation across both stories.

- [X] T018 [P] Update `README.md` with a reference to feature
      `specs/004-kitsu-search-share/`
- [X] T019 Run the `specs/004-kitsu-search-share/quickstart.md` validation
      steps; confirm the Kitsu section works live, sharing is branded for all
      three sources, and Jikan/AniList are unaffected

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - US1 and US2 can proceed in parallel (different files) or sequentially in
    priority order (both P1; US1 recommended first as the MVP)
- **Polish (Phase 5)**: Depends on US1 and US2 being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - no
  dependencies on US2
- **User Story 2 (P1)**: Can start after Foundational (Phase 2) - no
  dependencies on US1

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Core data-source/model fix before integration/UI wiring
- Story complete before moving to next priority

### Parallel Opportunities

- T002, T004/T005, T011/T012 are marked [P] and run in parallel
- US1 (Kitsu data source) and US2 (share flow) touch disjoint file sets and can
  be worked on in parallel by different developers

---

## Parallel Example: User Story 1

```bash
# Launch the two US1 test tasks together:
Task: "Add header test in test/unit/sources/kitsu_api_test.dart"
Task: "Add detail type-routing test in test/unit/sources/kitsu_detail_test.dart"
```

## Parallel Example: User Story 2

```bash
# Launch the two US2 test tasks together:
Task: "Add ShareRepository branding test in test/unit/repositories/share_repository_test.dart"
Task: "Add share-preview branding widget test in test/widget/share_preview_view_test.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational
3. Complete Phase 3: User Story 1 (Kitsu section works against the live API)
4. **STOP and VALIDATE**: Test US1 independently (live app check + unit tests)
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational - Foundation ready
2. Add User Story 1 - Test independently - Deploy/Demo (MVP!)
3. Add User Story 2 - Test independently - Deploy/Demo
4. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1 (Kitsu data source)
   - Developer B: User Story 2 (share branding)
3. Stories complete and integrate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- US1 constraint: NO changes to Jikan, AniList, or shared Home layout code
  (only Kitsu-section code + Kitsu-specific tests)
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break
  independence
