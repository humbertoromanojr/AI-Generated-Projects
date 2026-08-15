# Implementation Plan: Correct Share Link Format

**Branch**: `005-fix-share-links` | **Date**: 2026-08-15 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/005-fix-share-links/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command; its definition describes the execution workflow.

## Summary

Sharing a title currently emits the wrong link format
(`https://animewhere.app/title/<source>/<id>`, FR-002 violation) and a
text-only payload. This feature:

1. Replaces the share link with each provider's **canonical web page** for the
   title (MyAnimeList for Jikan, `anilist.co`, `kitsu.io`, with anime/manga
   variants) — built deterministically from `source` + `kind` + `id`
   (research.md decision D1).
2. Restructures shared content to the user's layout: **title image → title
   name → "Download the app from the Google Play Store → AW - AnimeWhere"**
   (contracts/share-content.md), with the Google Play Store listing as the
   download link (research.md decision D3).
3. Attaches the title poster image to the share where the platform supports
   files, with a text-only fallback (research.md decision D2).

No new screens or routes. The `/title/:source/:id` route stays for in-app
navigation and the web share-preview page, but is never emitted in shares.
Sharing reuses the already-fetched in-memory `Title` (image + name), so it
makes **zero new provider requests** and never trips rate limits (FR-004,
FR-007, SC-005).

## Technical Context

**Language/Version**: Dart 3.12.x / Flutter stable (`pubspec.yaml` SDK
constraint `^3.12.2`)

**Primary Dependencies**: provider (DI), go_router (routing), http (image
download for attachment), share_plus `^13.3.0` (share sheet, `ShareParams`),
cached_network_image (poster rendering, unchanged); **+ `path_provider`**
(proposed, for temp-file image attachment — see research.md D2)

**Storage**: N/A — no persistence; the share target is derived from the
in-memory `Title`, never stored (contracts/share-link.md)

**Testing**: `flutter_test` — unit (share repository, canonical-link builder,
image attachment, share text), widget (share button flows), integration
(browse → detail → share journey asserting the new link)

**Target Platform**: Android, iOS, Web (all scaffolded targets remain
buildable; web shares via the Web Share API with text fallback)

**Project Type**: Flutter app — MVVM UI + repository data layer (constitution
Principle I)

**Performance Goals**: share completes in ≤3 taps (SC-004); no additional
provider request during a share (SC-005)

**Constraints**: provider rate limits (Jikan 3 req/s, AniList 90 req/min) must
never be triggered by sharing; shared content MUST NOT contain
`https://animewhere.app/title/<source>/<id>`; `dart format` clean, `flutter
analyze` zero issues, full `flutter test` suite green

**Scale/Scope**: 3 sources × 2 kinds (anime/manga); lib changes confined to
`core/models/share_target.dart`, `data/repositories/share_repository.dart`,
`ui/share/share_service.dart`, and one new `data/share/` helper; ~4 existing
test files updated plus new unit tests

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Layered architecture (Principle I)**: PASS — change stays in the existing
  share flow (model → repository → service); no logic added to widgets.
- **Dependency injection, no globals**: PASS — repository/service already
  provided via `provider` in `core/di/providers.dart`; new image-attachment
  helper is injectable and faked in tests.
- **Immutable models**: PASS — `ShareTarget` remains immutable; no mutable
  state introduced.
- **Structured data I/O (Principle IV)**: PASS — share payload derives from the
  typed `Title` model; canonical URLs are validated at the repository boundary
  (unit-tested mapping, contracts/share-link.md).
- **Tested-by-construction (Principle V)**: PASS — updated + new unit/widget/
  integration tests ship with the change.
- **Design-system fidelity (Principle III)**: PASS — no visual change to
  screens; the share sheet payload is text + image attachment.
- **Quality gates**: REQUIRED — `dart format` (no diffs), `flutter analyze`
  (zero issues), `flutter test` (green) before merge.

No violations. Complexity Tracking not needed.

## Project Structure

### Documentation (this feature)

```text
specs/005-fix-share-links/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   ├── README.md
│   ├── share-link.md    # Canonical per-source link mapping
│   └── share-content.md # Shared content layout + text template + image rules
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
lib/
├── core/
│   └── models/
│       └── share_target.dart            # EXTEND: titleName, imageUrl; shareUrl semantics change
├── data/
│   ├── share/
│   │   └── share_image_attachment.dart  # NEW: best-effort poster download -> XFile
│   └── repositories/
│       └── share_repository.dart        # REWORK: canonical link + Play Store downloadUrl + title fields
└── ui/
    └── share/
        └── share_service.dart           # REWORK: compose text, attach image, fallback

test/
├── unit/
│   ├── share/
│   │   ├── share_image_attachment_test.dart  # NEW
│   │   └── share_service_test.dart           # NEW (shareText content + fallback)
│   └── repositories/
│       └── share_repository_test.dart        # REWRITE: canonical URLs + downloadUrl
├── widget/
│   └── detail_view_test.dart                 # VERIFY: still passes with new payload
└── integration/
    └── browse_share_test.dart                # UPDATE: assert canonical link, not /title/...
```

**Structure Decision**: Single Flutter app; the change is confined to the
existing share flow (model → repository → service) with one new data-layer
helper for image attachment. No UI, navigation, or theme changes.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| _(none — no constitution violations)_ | — | — |
