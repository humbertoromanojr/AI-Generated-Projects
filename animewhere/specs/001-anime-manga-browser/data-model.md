# Data Model: Anime & Manga Browser

**Date**: 2026-08-14
**Source**: `spec.md` (entity list, FR-008 structured I/O) + `research.md`
decisions.

## Overview

Immutable domain models. All three source adapters map their wire payloads into
these unified types; the UI depends only on this model layer. There is no
persistence layer (no login, no database).

## Entities

### TitleSource (enum)

- Values: `jikan`, `anilist`, `kitsu`.
- Purpose: tags where a title came from so share links and detail fetches
  route to the matching API.

### Title (immutable)

- Fields:
  - `id`: source-qualified identifier string, e.g. `anilist:21` (required)
  - `source`: `TitleSource` (required)
  - `kind`: `anime` | `manga` (required)
  - `title`: canonical display title (required)
  - `imageUrl`: poster image URL, 2:3 aspect (required)
  - `description`: synopsis (optional - omit when absent)
  - `score`: numeric rating normalized to 0..100 (optional)
  - `seasonYear`: airing year (optional display metadata)
  - `format`: e.g. TV, Movie, Manga, Novel (optional display metadata)
  - `providerUrl`: canonical page on the source site (optional)
- Rules:
  - Immutable; `copyWith` for changes.
  - Never constructed with empty `id`/`title`/`imageUrl`; a mapper drops any
    entry that fails validation (FR-008) instead of failing the screen.
  - `score` is normalized to 0..100 at the mapper boundary (Jikan score x10,
    Kitsu averageRating, AniList averageScore).

### Collection

- Fields: `id` (`featured` | `trending` | `popular` | `latest` |
  `manga-popular`), `label`, `titles: List<Title>` (may be empty).
- Rules: a row renders loading/error/empty state from its fetch outcome, not
  from an empty `titles` list alone (FR-007, SC-005).

### ShareTarget

- Fields: `source: TitleSource`, `id` (provider id), `shareUrl: String`.
- Rules: `shareUrl` MUST match the contract in
  `contracts/share-preview.md` (`<web-host>/title/<source>/<id>`); it is
  derived from source + id, never stored.

### HomeCatalog

- Fields: `carousel: Collection`, `rows: List<Collection>` (trending, popular,
  latest, manga rows).
- Rules: assembled once by the home ViewModel from the three repositories; each
  part fails independently (a Jikan outage does not blank AniList/Kitsu rows).

## Validation rules (FR-008 / Constitution Principle IV)

1. Every wire payload is parsed by a per-source mapper that validates required
   fields (`id`, `title`, `imageUrl`) and coerces types.
2. Malformed entries are skipped and counted; a row yielding zero valid entries
   after skipping shows its empty state.
3. Missing optional fields are represented as `null`/absent in the model, never
   replaced with sentinel values.

## State transitions

Read-only catalog: per-fetch state is `loading -> data | error | empty`;
refresh keeps the previous data visible while refetching (FR-009). The share
flow is stateless (`idle -> shared | cancelled`).
