# Feature Specification: Correct Share Link Format

**Feature Branch**: `005-fix-share-links`

**Created**: 2026-08-15

**Status**: Draft

**Input**: User description: "This sharing link is incorrect: https://animewhere.app/title/jikan/49233. The format is wrong.

1 - The correct format for Jikan: Useful endpoints: `/anime` — search by name; `/top/anime` — top rankings; `/seasons/now` — current season; `/anime/{id}/characters` — characters; `/anime/{id}/episodes` — episode list; `/genres/anime` — genres. Example of use: Search for top anime -> GET https://api.jikan.moe/v4/top/anime?limit=20, Search for a specific anime -> GET https://api.jikan.moe/v4/anime/1 // Cowboy Bebop, Anime of the season -> GET https://api.jikan.moe/v4/seasons/now. Rate limit: 3 requests/second.

2 - The right way to use AniList: GraphQL -> allows you to retrieve exactly the data you need in a single request. Rich data: tags, ratings, relationships between anime and manga. High-quality cover art and banners. Active community with custom lists. Query example: query { Page(page: 1, perPage: 20) { media(type: ANIME, sort: POPULARITY_DESC) { id, title { romaji english native }, coverImage { large }, averageScore, genres, episodes, description } } }. Rate limit: 90 requests/minute.

3 - The correct format for Kitsu: Social data: followers, community ratings, lists. Advanced filters: by category, status, season. Images optimized for different sizes. Example usage: Top anime -> GET https://kitsu.io/api/edge/anime?sort=popularityRank&page[limit]=20; Search by name -> GET https://kitsu.io/api/edge/anime?filter[text]=naruto; Details with categories -> GET https://kitsu.io/api/edge/anime/{id}?include=categories,episodes.

To fix it, follow steps: 1, 2, and 3 to display the image and the anime's name when sharing. Correct: Follow these steps when sharing: anime or manga image - Title - Download the app -> AW AnimeWhere."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Shared titles produce a correct, provider-formatted link (Priority: P1)

When a user shares a title from any source (Jikan, AniList, or Kitsu), the link embedded in the shared content follows the correct format for that source instead of the app's own `https://animewhere.app/title/<source>/<id>` URL. A recipient can follow the link and reach the title.

**Why this priority**: The user's request explicitly identifies the current share-link format as wrong; correcting it is the core of this feature.

**Independent Test**: Share a title from each of the three sources and confirm the emitted link uses the correct per-source format and resolves to the correct title when opened in a browser.

**Acceptance Scenarios**:

1. **Given** a Jikan anime title, **When** the user shares it, **Then** the shared link uses the correct Jikan format for a specific anime and opens the correct title.
2. **Given** a Jikan manga title, **When** the user shares it, **Then** the shared link uses the correct Jikan manga format and opens the correct title.
3. **Given** an AniList anime title, **When** the user shares it, **Then** the shared link uses the correct AniList format and opens the correct title.
4. **Given** a Kitsu anime title, **When** the user shares it, **Then** the shared link uses the correct Kitsu format and opens the correct title.
5. **Given** any title, **When** it is shared, **Then** the shared content never contains a link of the form `https://animewhere.app/title/<source>/<id>`.

---

### User Story 2 - Share content shows image, title, and app download branding (Priority: P1)

When a user shares a title, the shared content displays, in order: the title's image, the title name, then a "Download the app" call-to-action with the app name "AW - AnimeWhere" and a working download link. The image and name are obtained by following the correct format for the title's source (steps 1, 2, and 3 in the feature description).

**Why this priority**: The user states the correct sharing layout explicitly (image - Title - Download the app -> AW AnimeWhere); it is what makes shares useful and drives app installs.

**Independent Test**: Share a title from each source and confirm the content shows the image first, the title name second, and the app download call-to-action last.

**Acceptance Scenarios**:

1. **Given** any title, **When** the user shares it, **Then** the shared content displays the title's image first.
2. **Given** any title, **When** the user shares it, **Then** the title name appears after the image.
3. **Given** any title, **When** the user shares it, **Then** the shared content ends with "Download the app" and the app name "AW - AnimeWhere", including a link that leads to where the app can be obtained.
4. **Given** a title from each source, **When** the image and name are retrieved for sharing, **Then** the source's correct format is used (Jikan detail endpoint, AniList GraphQL media query, Kitsu detail with categories/episodes) without exceeding the source's request limits (Jikan 3 requests/second, AniList 90 requests/minute).

---

### Edge Cases

- A title has no poster image: the share must still carry the correct link, the title name, and the app download call-to-action.
- The source is temporarily unreachable while fetching the image/name: sharing still completes with the correct link and app branding; the image/name degrade gracefully instead of blocking the share.
- Manga vs. anime: the link must use the correct manga or anime variant of the source's format.
- Rapid repeated sharing: must not trip the source's request limits.
- A recipient without the app opens the link: it must resolve to the title in a regular browser.
- The download page is temporarily unreachable: recipients must still receive a valid link that works when online.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The share link for a title MUST use the correct format for the source the title came from. Jikan titles use the Jikan-specific format for a specific anime (`https://api.jikan.moe/v4/anime/{id}`) / manga, AniList titles use the AniList format for a specific media entry, and Kitsu titles use the Kitsu detail format (`https://kitsu.io/api/edge/anime/{id}?include=categories,episodes`). [NEEDS CLARIFICATION: The description lists each provider's API endpoint format but does not state which URL a shared link should point to. Confirm whether the shared link should be (A) the provider's canonical web page, (B) the provider's API endpoint exactly as written in the description, or (C) another destination.]
- **FR-002**: Shared content MUST NOT contain the app's own URL of the form `https://animewhere.app/title/<source>/<id>`.
- **FR-003**: Shared content MUST display, in order: the title's image, the title name, and a "Download the app" call-to-action with the app name "AW - AnimeWhere" and a link to where the app can be obtained.
- **FR-004**: The title's image and name MUST be retrieved using the correct format for the source (Jikan detail, AniList GraphQL, Kitsu detail with categories/episodes), without exceeding the source's request limits (Jikan 3 requests/second, AniList 90 requests/minute).
- **FR-005**: For manga titles, the share link MUST use the manga variant of the source's format.
- **FR-006**: A title without a poster image MUST still produce valid shared content containing the correct link, the title name, and the app download call-to-action.
- **FR-007**: Sharing MUST complete with the correct link and app branding even when the source is temporarily unreachable; the image/name degrade gracefully instead of blocking the share.

### Key Entities *(include if feature involves data)*

- **Share Target**: The artifact produced when sharing — source, title id, share link, app name ("AW - AnimeWhere"), app image, and app download link.
- **Title**: A title record from any source — id, source (Jikan/AniList/Kitsu), name, image, and type (anime or manga).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of shared titles emit a link in the correct per-source format that resolves to the correct title when opened.
- **SC-002**: 0 shared items ever contain the app's own `/title/<source>/<id>` URL.
- **SC-003**: 100% of share actions produce content ordered as image → title → "Download the app → AW - AnimeWhere".
- **SC-004**: A share completes in 3 or fewer taps from any screen.
- **SC-005**: Normal single-title sharing never triggers a source request-limit violation (one share = at most one fetch per source).

## Assumptions

- The correct per-source link formats follow the destination confirmed in Q1 (pending clarification); the description's API endpoint examples are the reference.
- The app's own `/title/:source/:id` route remains available for in-app navigation and the existing web share-preview page, but it is no longer emitted in shared content.
- The share layout is exactly: title image, title name, then "Download the app" with the app name "AW - AnimeWhere".
- Sharing embeds the title image where the platform's share mechanism supports it; where it does not, the text fallback still carries the correct link, the title name, and the app download call-to-action.
- The existing share flow built in features 001-004 remains the foundation; this feature corrects the link format and the share content structure.
