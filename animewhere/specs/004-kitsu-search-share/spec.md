# Feature Specification: Kitsu Section Verification & Share Branding

**Feature Branch**: `004-kitsu-search-share`

**Created**: 2026-08-14

**Status**: Draft

**Input**: User description: "Check the API documentation: https://kitsu.docs.apiary.io/ and make sure the carousel and scrolls in the kitsu section work; only make changes in the kitsu section - When sharing, the app's image and name must be displayed, along with a link to download the AW - AnimeWhere app"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Kitsu section works against the live API (Priority: P1)

A user opens the Home screen and the Kitsu section displays correctly: the carousel loads featured Kitsu titles with posters, and the two recommendation scroll rows (Anime, Manga) load titles ten at a time and keep loading as the user scrolls. The section behaves correctly against the Kitsu API documentation. Work is confined to the Kitsu section.

**Why this priority**: The primary ask is that the Kitsu section actually works per the API documentation. This is the largest risk area (live third-party API integration) and everything else builds on a functioning Kitsu section.

**Independent Test**: Can be fully tested by launching the app and verifying the Kitsu carousel renders titles with posters, both scroll rows load and page infinitely ten titles at a time, and the section recovers with a retry when the network fails — without changes to any other section.

**Acceptance Scenarios**:

1. **Given** the Home screen with a network connection, **When** the Kitsu section loads, **Then** the carousel shows up to 10 Kitsu titles with posters.
2. **Given** the Home screen, **When** the Kitsu section loads, **Then** its two recommendation rows (Anime, Manga) each show up to 10 titles with posters.
3. **Given** a Kitsu recommendation row, **When** the user scrolls to its end, **Then** the next 10 titles load automatically (infinite scrolling).
4. **Given** a Kitsu request that fails, **When** the failure occurs, **Then** the Kitsu section shows a retryable error state and the Jikan and AniList sections remain fully functional.
5. **Given** the feature is implemented, **When** the code is reviewed, **Then** only Kitsu-section code has changed for this story (no changes to Jikan, AniList, or shared Home layout code).

---

### User Story 2 - Share includes app branding and download link (Priority: P1)

When a user shares a title, the recipient sees the app's image and name ("AW - AnimeWhere") along with a link to download the app, in addition to the title itself.

**Why this priority**: This is an explicit "must" in the feature description and drives app growth. It is independent of the Kitsu work and can be delivered and validated separately.

**Independent Test**: Can be tested by sharing any title and confirming the shared content displays the app's image, the app name "AW - AnimeWhere", and a working download link.

**Acceptance Scenarios**:

1. **Given** any title, **When** the user shares it, **Then** the shared content displays the app's image (app icon/branding).
2. **Given** any title, **When** the user shares it, **Then** the shared content displays the app name "AW - AnimeWhere".
3. **Given** any title, **When** the user shares it, **Then** the shared content includes a link to download the app.
4. **Given** a shared download link, **When** a recipient opens it, **Then** it leads to a page where the app can be obtained.
5. **Given** a title from any source, **When** the user shares it, **Then** the branded share content is produced for Jikan, AniList, and Kitsu titles alike.

---

### Edge Cases

- Kitsu request fails while other sections still load (failure isolation).
- Kitsu returns a page with fewer than 10 titles (the "end of catalog" case must stop loading).
- Kitsu returns a title record without a poster image or with missing fields (must not break the row).
- Repeated rapid scrolling to a row's end (no duplicate titles, no overlapping requests).
- Sharing on platforms that do not support embedded images in the share sheet (text must still carry the app name and download link).
- Download link target temporarily unreachable (recipient must receive a valid link that works when online).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The Kitsu section carousel MUST load and display up to 10 titles with posters.
- **FR-002**: The Kitsu section MUST display two recommendation scroll rows (Anime and Manga), each loading up to 10 titles with posters.
- **FR-003**: Each Kitsu recommendation row MUST load additional titles automatically when the user scrolls to its end, ten at a time.
- **FR-004**: Kitsu data requests MUST conform to the Kitsu API documentation (correct endpoints, paging, and fields).
- **FR-005**: The Kitsu section MUST show a retryable error state when its data cannot be loaded, without breaking the Jikan or AniList sections.
- **FR-006**: The Kitsu section MUST stop requesting more titles once the provider returns a page with fewer than the requested ten titles.
- **FR-007**: Kitsu rows MUST NOT display duplicate titles and MUST NOT issue overlapping page requests while one is in flight.
- **FR-008**: Kitsu titles with missing poster images or missing optional fields MUST still render (degrading gracefully) without breaking the row.
- **FR-009**: All changes for the Kitsu story MUST be confined to the Kitsu section's code.
- **FR-010**: Sharing a title MUST display the app's image (app branding/icon).
- **FR-011**: Sharing a title MUST display the app name "AW - AnimeWhere".
- **FR-012**: Sharing a title MUST include a link to download the app.
- **FR-013**: The download link MUST lead to a page where users can obtain the app.
- **FR-014**: Branded sharing MUST work for every title regardless of source (Jikan, AniList, Kitsu).

### Key Entities *(include if feature involves data)*

- **Kitsu Catalog Page**: A page of Kitsu titles returned for the carousel or a recommendation row (10 titles per page, next-page cursor).
- **Kitsu Title**: A title record in a Kitsu page — id, type (anime/manga), name, poster image, score, description, format.
- **Shared Content**: The message/artifact delivered to recipients — contains the app image, the app name "AW - AnimeWhere", the title link, and the app download link.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of Kitsu section loads show a populated carousel and both populated recommendation rows when the API is reachable.
- **SC-002**: Each Kitsu recommendation row pages infinitely in increments of 10 — verified across 3+ consecutive page loads.
- **SC-003**: 0 titles ever repeat within a Kitsu row across its infinite scroll.
- **SC-004**: 100% of share actions produce content displaying the app image, the app name "AW - AnimeWhere", and a download link.
- **SC-005**: The download link resolves to a reachable download page in all cases where the recipient is online.
- **SC-006**: Jikan and AniList sections remain unchanged and fully functional after the Kitsu story lands.

## Assumptions

- "Only make changes in the kitsu section" applies to the Kitsu API story: changes are confined to Kitsu section code (`lib/data/sources/kitsu/` and the Kitsu section's wiring). The share-branding story (US2) is a separate, app-wide requirement and is exempt from that constraint.
- "The carousel and scrolls in the kitsu section work" means they load and page correctly against the documented Kitsu API; any mismatches found during verification are fixed within the Kitsu section.
- The download link points to a download/landing page on the app's existing web host; app-store listing URLs are configured on that page once the app is published.
- The displayed app name in shared content is "AW - AnimeWhere".
- Sharing embeds the app image where the platform's share sheet supports images; on platforms that do not, the text fallback still includes the app name and the download link.
- The existing Home, detail, and share flows (per features 001-003) remain the foundation; this feature verifies/fixes the Kitsu section and extends the share flow.
