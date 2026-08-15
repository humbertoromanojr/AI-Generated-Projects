---

description: "Task list for Correct Share Link Format implementation"
---

# Tasks: Correct Share Link Format

**Input**: Design documents from `/specs/005-fix-share-links/`

**Prerequisites**: [plan.md](plan.md) (required), [spec.md](spec.md) (required
for user stories), [research.md](research.md), [data-model.md](data-model.md),
[contracts/](contracts/README.md), [quickstart.md](quickstart.md)

**Tests**: Tests ARE included. The AnimeWhere Constitution (Principle V —
Tested-by-Construction) requires unit/widget/integration tests to ship with
non-trivial logic, and this feature changes a repository contract and the share
flow.

**Organization**: Tasks are grouped by user story to enable independent
implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Path Conventions

- **Single Flutter project**: `lib/`, `test/` at repository root
- Existing layout (see plan.md): `lib/core/models/`, `lib/data/repositories/`,
  `lib/ui/share/`; new helper lives in `lib/data/share/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure

- [X] T001 Add `path_provider` to the `dependencies` block in pubspec.yaml and run `flutter pub get`
- [X] T002 [P] Create share config constant in lib/core/config/share_config.dart: `playStoreAppId` (currently `com.example.animewhere`) and a `playStoreDownloadUrl()` helper returning `https://play.google.com/store/apps/details?id=<playStoreAppId>` (research D3, contracts/share-content.md)

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core model change that BOTH user stories depend on

**CRITICAL**: No user story work can begin until this phase is complete

- [X] T003 Extend `ShareTarget` in lib/core/models/share_target.dart with required immutable fields `titleName` (String) and `imageUrl` (String), sourced from `Title.title` and `Title.imageUrl` (data-model.md); keep the const constructor and all existing fields

**Checkpoint**: Foundation ready - user story implementation can now begin

---

## Phase 3: User Story 1 - Correct provider-formatted share link (Priority: P1) - MVP

**Goal**: Sharing a title emits the provider's canonical web page URL
(MyAnimeList / anilist.co / kitsu.io, with anime and manga variants) and NEVER
the app's own `https://animewhere.app/title/<source>/<id>` URL (FR-001, FR-002,
FR-005).

**Independent Test**: Share a Jikan, an AniList, and a Kitsu title and confirm
each link matches contracts/share-link.md exactly and opens the correct title
page in a browser; grep shared content and confirm no `/title/` path appears.

### Tests for User Story 1

- [X] T004 [P] [US1] Add unit tests in test/unit/share/share_link_test.dart covering all 3 sources x 2 kinds against the exact URLs in contracts/share-link.md, plus an error case for an unknown source/kind
- [X] T005 [P] [US1] Rewrite test/unit/repositories/share_repository_test.dart: assert canonical `shareUrl` per source/kind, `downloadUrl` is the Play Store listing, and NO `shareUrl` ever contains `/title/`
- [X] T006 [US1] Update test/integration/browse_share_test.dart: expect `https://myanimelist.net/anime/21` for the Jikan title (not `https://animewhere.app/title/jikan/21`) and assert the mock API client receives no additional requests during sharing

### Implementation for User Story 1

- [X] T007 [US1] Create pure canonical share-link builder in lib/core/models/share_link.dart: a function mapping `(TitleSource source, TitleKind kind, String id)` to the canonical URL per contracts/share-link.md; throw `ArgumentError` for unknown source/kind (data-model.md Canonical Link Rule)
- [X] T008 [US1] Rework `ShareRepository.targetFor` in lib/data/repositories/share_repository.dart: build `shareUrl` via the canonical builder (T007), set `downloadUrl` to `playStoreDownloadUrl()` (T002), and populate `titleName`/`imageUrl` from the `Title` (depends on T002, T003, T007)

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - Share content shows image, title, and Play Store CTA (Priority: P1)

**Goal**: Shared content is laid out as title poster image -> title name ->
"Download the app from the Google Play Store -> AW - AnimeWhere" with the Play
Store link (FR-003, FR-006, FR-007). Image attachment is best-effort with a
text-only fallback that always carries the title, the correct link, and the
CTA (contracts/share-content.md).

**Independent Test**: Share a title and confirm the share sheet shows the
poster image first, the title second, and the Play Store CTA last; on a
platform without file support the text alone still contains title, canonical
link, app name, and a `play.google.com/store/apps/details` URL.

### Tests for User Story 2

- [X] T009 [P] [US2] Add unit tests for `ShareService.shareText` in test/unit/share/share_service_test.dart asserting the exact template order (title, link, CTA, Play Store URL) and that every payload contains the canonical link, `AW - AnimeWhere`, and a `play.google.com/store/apps/details` URL (contracts/share-content.md)
- [X] T010 [P] [US2] Add unit tests for the image attachment helper in test/unit/share/share_image_attachment_test.dart: returns an `XFile?` on successful download, and returns `null` on HTTP failure or missing image URL (FR-006, FR-007)

### Implementation for User Story 2

- [X] T011 [P] [US2] Create `ShareImageAttachment` in lib/data/share/share_image_attachment.dart: injectable helper that downloads `Title.imageUrl` to a temp file (http + `getTemporaryDirectory()` from path_provider) and returns `XFile?`; returns `null` on any failure (research D2, contracts/share-content.md)
- [X] T012 [US2] Rework `ShareService.shareTitle` in lib/ui/share/share_service.dart: compose `shareText` from the `ShareTarget` per contracts/share-content.md and pass the poster `XFile?` via `ShareParams(files:)` when available; sharing must never throw when the image cannot be attached (depends on T008, T011)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Quality gates and verification across both stories

- [X] T013 [P] Update test/widget/detail_view_test.dart (and any other share-touchpoint widget test) to remain green with the new `ShareTarget` payload
- [X] T014 Run `dart format` on all changed files under lib/ and test/ (no diffs)
- [X] T015 Run `flutter analyze` and fix until zero errors and zero warnings
- [X] T016 Run the full `flutter test` suite and fix until green
- [X] T017 Run the validation scenarios in quickstart.md (share from each source, verify canonical link + content order + no `/title/` URL)
- [X] T018 Update this feature's docs (plan.md/research.md/contracts) only if implementation diverged from the recorded decisions

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Story 1 (Phase 3)**: Depends on Foundational - the MVP
- **User Story 2 (Phase 4)**: Depends on Foundational AND US1 (US2 reuses the
  reworked `ShareTarget`/`ShareRepository` from T003/T008)
- **Polish (Phase 5)**: Depends on all user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational - no dependency on US2
- **User Story 2 (P1)**: Integrates with US1 (`shareUrl`, `downloadUrl`,
  `titleName`, `imageUrl` on the target) but is independently testable once US1
  is in place

### Within Each User Story

- Tests MUST be written and FAIL before implementation
- Implementation tasks build on the tested contracts
- Core implementation before integration
- Story complete before moving to the next priority

### Parallel Opportunities

- T001 and T002 (Phase 1) can run in parallel
- T004, T005, T006 (US1 tests) can run in parallel
- T009, T010, T011 (US2) can run in parallel
- US1 (T007, T008) can start as soon as Foundational (T003) completes; US2 can
  start as soon as T008 lands

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together:
Task: "Add unit tests in test/unit/share/share_link_test.dart (T004)"
Task: "Rewrite test/unit/repositories/share_repository_test.dart (T005)"
Task: "Update test/integration/browse_share_test.dart (T006)"

# Then implement:
Task: "Create canonical share-link builder in lib/core/models/share_link.dart (T007)"
Task: "Rework ShareRepository.targetFor in lib/data/repositories/share_repository.dart (T008)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001, T002)
2. Complete Phase 2: Foundational (T003) - blocks all stories
3. Complete Phase 3: User Story 1 (T004-T008)
4. **STOP and VALIDATE**: share links match contracts/share-link.md; run
   `flutter test` (T004-T006 green)
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational -> Foundation ready
2. Add User Story 1 -> Test independently -> Deploy/Demo (MVP)
3. Add User Story 2 -> Test independently -> Deploy/Demo
4. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together (T001-T003)
2. Once Foundational is done:
   - Developer A: User Story 1 (T004-T008)
   - Developer B: User Story 2 (T009-T012), starting after T008
3. Stories integrate and validate independently

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story should be independently completable and testable
- Verify tests fail before implementing
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague tasks, same file conflicts, cross-story dependencies that break independence
