# Contracts

Feature 005 — Correct Share Link Format. These contracts define the external
interfaces of the share flow.

| Contract | Scope |
|----------|-------|
| [share-link.md](share-link.md) | Canonical per-source share link mapping (FR-001, FR-005) |
| [share-content.md](share-content.md) | Shared content layout, text template, image rules, download link (FR-003) |

Related: feature 001's `contracts/share-preview.md` documents the app-hosted
`/title/:source/:id` route. That route **remains** for in-app navigation and
the web share-preview page, but is **never emitted** in shared content
(FR-002, spec Assumptions).
