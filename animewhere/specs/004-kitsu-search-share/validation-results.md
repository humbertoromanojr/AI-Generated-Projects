# Validation Results

**Feature**: Kitsu Section Verification & Share Branding (`specs/004-kitsu-search-share`)
**Date**: 2026-08-14
**Environment**: Windows, Flutter 3.44.9 stable / Dart 3.12.2; live device
`2201117SG` (Android 13 / API 33)
**Scope**: `quickstart.md` validation scenarios + automated gates (tasks
T004-T010 for US1, T011-T017 for US2, T018-T019 polish).

## Automated gates

| Check | Command | Result |
|-------|---------|--------|
| Format | `dart format --set-exit-if-changed lib test` | PASS (0 diffs) |
| Analyze | `flutter analyze` | PASS (0 issues) |
| Full suite | `flutter test` | PASS (92 tests; baseline 81 + 11 new) |
| US1 header tests | `test/unit/sources/kitsu_api_test.dart` | PASS |
| US1 detail routing | `test/unit/sources/kitsu_detail_test.dart` | PASS (2 tests) |
| US2 repo tests | `test/unit/repositories/share_repository_test.dart` | PASS (incl. 4 branding tests) |
| US2 widget tests | `test/widget/share_preview_view_test.dart` | PASS (incl. 3 branding tests) |
| E2E journey | `test/integration/browse_share_test.dart` | PASS (browse -> detail -> share) |

## Kitsu Edge API live smoke check

| Request | Result |
|---------|--------|
| `GET anime?page[limit]=10&page[offset]=0` (User-Agent + `Accept: application/vnd.api+json`) | PASS — HTTP 200, JSON:API body, `meta.count` 22267, 10 records, first "Cowboy Bebop", record `type: anime` |
| `GET anime/1` (same headers) | PASS — HTTP 200, JSON:API `application/vnd.api+json` content-type |
| `GET manga/1` (same headers) | PASS — HTTP 200 |

The documented Kitsu headers (User-Agent + JSON:API Accept) are accepted by
the live API and are required for Kitsu to respond reliably.

## Live device run (Android 13)

- Debug APK built (`flutter build apk --debug`) and installed on `2201117SG`.
- App launched via `MainActivity`; `topResumedActivity` /
  `mCurrentFocus` = the app within ~12s.
- No `FATAL`, `AndroidRuntime`, or `E/flutter` lines during launch.
- Surface rendering at ~35-42 fps; UI scrolling via input swipe produced no
  runtime/Flutter errors.

## quickstart validation scenarios

### 1. Kitsu carousel loads — VERIFIED (automated + live smoke)

- Header/`Accept` conformance covered by
  `test/unit/sources/kitsu_api_test.dart`; wiring of the Kitsu carousel is
  exercised in `test/unit/view_models/home_view_model_test.dart`.
- Live API accepts the Kitsu-scoped headers (smoke check above).
- Live-device visual confirmation of rendered posters remains a human step.

### 2. Kitsu infinite scroll rows — VERIFIED (automated)

- Paging params (`sort=-popularityRank`, `page[limit]=10`,
  `page[offset]=page*10`) match the Edge API contract
  (`test/unit/sources/kitsu_api_test.dart`); de-duplication by
  `(source, id)` and stop-at-end covered in
  `test/unit/repositories/catalog_repository_test.dart` /
  `home_view_model_test.dart`. No gaps found in T009.

### 3. Kitsu detail works for anime AND manga — VERIFIED (automated + live)

- `KitsuApi.detail()` now routes `/anime/{id}` when the record `type` is
  `anime`, falling back to `/manga/{id}` otherwise (previously always
  `/manga/{id}` → anime 404s).
- `test/unit/sources/kitsu_detail_test.dart` covers both branches.
- Live: `GET anime/1` and `GET manga/1` both return HTTP 200.

### 4. Share branding — VERIFIED (automated)

- `ShareRepository.targetFor` returns `appName = "AW - AnimeWhere"`, an app
  image URL, and a `downloadUrl` derived from the web host
  (`test/unit/repositories/share_repository_test.dart`).
- `ShareService.shareTitle` includes the app name and download link in the
  shared text.
- Web share preview renders the app image (`app-branding-image`), the name
  "AW - AnimeWhere", and a "Download the app" action that copies the download
  URL to the clipboard (`test/widget/share_preview_view_test.dart`).
- Platforms without image support still show the name and download link (text
  + clipboard path; no `dart:io` — web-compatible).

### 5. Other sections unaffected — VERIFIED (automated)

- `AppHttpClient.getJson` gained an optional `headers` param with unchanged
  defaults for Jikan/AniList; only `KitsuApi` sends the Kitsu-scoped headers.
- US1 changes confined to `lib/data/sources/kitsu/` + Kitsu tests +
  `http_client.dart` optional param.
- Full suite green (92 tests) including the browse->detail->share journey.

## Manual / device-only steps (human confirmation recommended)

Automated + live smoke/device checks pass, but a human visual pass is still
recommended for:

- Confirm Kitsu posters render from the live Edge API with no broken/blank
  images (scenario 1).
- Watch the Kitsu Anime/Manga rows page 10 titles per scroll for 3+ pages
  without duplicates (scenario 2).
- Tap a Kitsu anime title and a Kitsu manga title on-device and confirm the
  detail screen loads for both (scenario 3).
- Share a title on-device and visually confirm the image, "AW - AnimeWhere",
  and download link (scenario 4).
- Force a Kitsu failure and confirm only the Kitsu section shows a retryable
  error (scenario 5).

## Deployment note

The share URLs (`appImageUrl`, `downloadUrl`, `shareUrl`) resolve against the
web host (`https://animewhere.app`), which was not reachable from this
environment at validation time (DNS placeholder, same pre-existing host as the
original `shareUrl`). Deploy the web host first so the branding image and
download link resolve; the app-icon asset itself is bundled via `pubspec.yaml`.
