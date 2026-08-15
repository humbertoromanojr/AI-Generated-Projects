# Data Model: Correct Share Link Format

**Date**: 2026-08-15
**Source**: `spec.md` (FR-001..FR-007, Key Entities) + `research.md` decisions
D1-D4.

## Overview

No new domain entities and no persistence. The change redefines the
`ShareTarget` payload produced when sharing a `Title`:

- `shareUrl` becomes the provider's **canonical web page** for the title
  (research D1), never the app's own `/title/<source>/<id>` URL (FR-002).
- `downloadUrl` becomes the **Google Play Store** listing (research D3).
- New display fields (`titleName`, `imageUrl`) carry the title's name and
  poster so the share content can be laid out as image → title → download CTA
  (FR-003).

The `Title` model is unchanged — it already carries everything needed:
`source`, `id`, `kind`, `title`, `imageUrl`.

## Entities

### Title (unchanged)

- Fields: `id`, `source` (`TitleSource`), `kind` (`TitleKind.anime|manga`),
  `title`, `imageUrl`, `description?`, `score?`, `seasonYear?`, `format?`,
  `providerUrl?`.
- The canonical link (below) is a pure function of `source`, `kind`, `id`.

### ShareTarget (changed)

- Fields:
  - `source`: `TitleSource` (unchanged, keeps the share typed)
  - `id`: provider id string (unchanged, e.g. `mal_id`, AniList id, Kitsu id)
  - `shareUrl`: **provider canonical page** — see Canonical Link Rule
  - `titleName`: `Title.title` (displayed after the image)
  - `imageUrl`: `Title.imageUrl` (poster attached to the share, when possible)
  - `appName`: `'AW - AnimeWhere'` (unchanged branding)
  - `appImageUrl`: app icon/branding image URL (unchanged, retained)
  - `downloadUrl`: **Google Play Store listing**
    (`https://play.google.com/store/apps/details?id=<applicationId>`)
- Rules: immutable; derived from the in-memory `Title` at share time; never
  persisted; `shareUrl` MUST match `contracts/share-link.md`, `downloadUrl`
  MUST match `contracts/share-content.md`.

### Shared Content (produced output)

- Ordered payload: title poster image (attachment) → title name → "Download
  the app from the Google Play Store → AW - AnimeWhere" + download link.
- Text template and fallback rules: see `contracts/share-content.md`.

## Canonical Link Rule (FR-001, FR-005)

| Source   | Anime segment | Manga segment |
|----------|---------------|---------------|
| Jikan    | `myanimelist.net/anime/{id}`   | `myanimelist.net/manga/{id}`   |
| AniList  | `anilist.co/anime/{id}`        | `anilist.co/manga/{id}`        |
| Kitsu    | `kitsu.io/anime/{id}`          | `kitsu.io/manga/{id}`          |

- Base scheme: `https://` in all cases.
- `kind` selects the segment; a manga title MUST use the manga variant
  (FR-005).
- Any input outside the three sources / two kinds is an error, not a silent
  fallback (Principle IV).

## Validation Rules

1. Every `shareUrl` is built through the canonical-link mapping and asserted by
   unit tests for all 3 sources × 2 kinds (contracts/share-link.md).
2. No share payload may contain `https://animewhere.app/title/...` (FR-002);
   verified by the share unit tests and the integration test.
3. `downloadUrl` always points at the Play Store listing constant (FR-003).
4. Image attachment is best-effort: `null`/failure yields text-only content
   that still carries title, link, and CTA (FR-006, FR-007).
5. Sharing performs zero provider network requests (research D4); verified by
   the integration test's mock client expecting no extra calls.

## State Transitions

Stateless: `idle → shared | failed`. `shareTitle` reads the in-memory `Title`,
builds the `ShareTarget` synchronously, then attaches the poster (async,
best-effort) before invoking the platform share sheet. Failure to attach the
image or reach the Play Store page never blocks the share — the text is always
delivered.
