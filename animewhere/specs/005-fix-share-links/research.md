# Research: Correct Share Link Format

**Date**: 2026-08-15
**Feature**: [spec.md](spec.md) — correct the sharing link and share layout.

## Topics & Findings

### D1 — Canonical per-source share link

**Decision**: Build the share link deterministically from the title's
`source` + `kind` + `id`:

| Source   | Anime                                   | Manga                                   |
|----------|-----------------------------------------|-----------------------------------------|
| Jikan    | `https://myanimelist.net/anime/{id}`    | `https://myanimelist.net/manga/{id}`    |
| AniList  | `https://anilist.co/anime/{id}`         | `https://anilist.co/manga/{id}`         |
| Kitsu    | `https://kitsu.io/anime/{id}`           | `https://kitsu.io/manga/{id}`           |

`id` is the provider id already stored on `Title` (`mal_id` for Jikan, AniList
`id`, Kitsu `id`). `kind` (anime/manga) already exists on `Title` and selects
the path segment.

**Rationale**: Jikan is the MyAnimeList API, so a Jikan title's canonical page
is on `myanimelist.net`; AniList and Kitsu have their own web sites. The
`Title.kind` field already encodes anime vs. manga, so the mapping is a pure
function of fields the app already holds — deterministic, offline-safe, and
trivially unit-testable. Building locally also means sharing performs **zero
provider requests** (SC-005), which matters given Jikan's 3 req/s limit.

**Alternatives considered**:
- *Use the provider's `url` field returned by the API* (Jikan exposes
  `item.url`). Rejected: only Jikan exposes it; it is not normalized across the
  three sources, and the app already has all inputs needed to construct it.
- *Keep the app-hosted URL but rename the path* (e.g. `/anime/{id}`). Rejected:
  the user explicitly called the app-hosted format wrong; the corrected link
  must land on the provider's own title page.
- *Share the API endpoint (e.g. `api.jikan.moe/v4/anime/{id}`)*. Rejected: raw
  JSON is not a page a recipient can view; AniList has no equivalent single URL
  (GraphQL POST endpoint).

### D2 — Including the title image in the share

**Decision**: Attach the title's poster as a file to the share sheet via
`share_plus` `ShareParams(files:)`, using a new injectable
`ShareImageAttachment` helper that downloads `Title.imageUrl` to a temp file
(`path_provider` temporary directory) and returns an `XFile?`. Any failure
(network error, download timeout, platform without file support) returns `null`
and the share proceeds text-only.

**Rationale**: `share_plus` v13 supports `ShareParams(files: [XFile])` on
Android and iOS; on web it falls back gracefully when the Web Share API does
not support files. The user's specified layout leads with the image
("image of the anime or manga"), so attaching the poster is the faithful
implementation; a text-only fallback guarantees FR-006 (no-image titles) and
FR-007 (provider unreachable) never block sharing. The temp file needs no
persistent storage and is removed by the OS.

**Alternatives considered**:
- *Embed the image URL in the text and rely on link previews*. Rejected:
  preview scraping is inconsistent across messengers and does not guarantee the
  image renders.
- *Share the app icon instead of the poster*. Rejected: the user's layout
  explicitly names the anime/manga image; the app brand is conveyed by the
  "AW - AnimeWhere" text and the Google Play link in the CTA (004's app-image
  requirement is interpreted as the brand name/CTA in the share text).

### D3 — App download link destination

**Decision**: `downloadUrl` becomes the app's Google Play Store listing,
`https://play.google.com/store/apps/details?id=<applicationId>`, where
`<applicationId>` is a single configuration constant (sourced from the Android
`applicationId`, currently `com.example.animewhere`).

**Rationale**: The user explicitly said the CTA is "Download the app from the
Google Play Store". Play Store listing URLs are the standard, stable way to
point Android users at an app; the constant makes it a one-line change when the
real application id is set before release.

**Alternatives considered**:
- *Keep `https://animewhere.app/download`*. Rejected: contradicts the user's
  explicit Google Play Store destination.
- *Per-platform store URLs (Play + App Store + web)*. Deferred: out of scope;
  the user specified Play Store. Documented as a follow-up so iOS/web CTA text
  can point elsewhere later.

### D4 — Provider request limits during sharing

**Decision**: Sharing performs **no** provider requests. The image, name, and
id are read from the already-fetched in-memory `Title` (list or detail
payload); the canonical link is constructed locally (D1). The existing
`/title/:source/:id` route and its web `SharePreviewView` fetch-on-load remain
unchanged for in-app navigation and direct web visits, but are not part of the
share path.

**Rationale**: Guarantees FR-004 and SC-005 by construction (Jikan 3 req/s,
AniList 90 req/min are never touched by sharing), and removes any need for
rate-limit throttling in the share flow.

**Alternatives considered**: *Re-fetch the detail from the source at share
time to guarantee fresh data*. Rejected: unnecessary round-trips that risk the
rate limits; the in-memory title is authoritative for the poster and name.

## Open Questions

None — all clarifications resolved (spec Q1: provider canonical pages; plan
input: Google Play Store download).
