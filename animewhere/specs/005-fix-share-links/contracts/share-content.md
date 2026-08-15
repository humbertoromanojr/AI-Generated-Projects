# Shared Content Contract

## Purpose

Define what a share delivers to the recipient and in what order (FR-003,
US2). Layout per the user: **image of the anime or manga → Title → Download
the app from the Google Play Store → AW - AnimeWhere**.

## Layout

1. **Image**: the title's poster (`Title.imageUrl`) attached to the share as a
   file where the platform share mechanism supports files.
2. **Title**: the title name (`Title.title`).
3. **Download CTA**: "Download the app from the Google Play Store → AW -
   AnimeWhere", with the app name `AW - AnimeWhere` and the Play Store
   download link.

## Text template (always present)

```
{titleName}
{shareUrl}

Download the app from the Google Play Store -> AW - AnimeWhere
{downloadUrl}
```

- `{titleName}`: `Title.title` (may be the only element present if the image
  cannot be attached).
- `{shareUrl}`: canonical link per [share-link.md](share-link.md).
- `{downloadUrl}`: `https://play.google.com/store/apps/details?id={applicationId}`,
  where `{applicationId}` is a single configuration constant (research D3;
  current Android application id `com.example.animewhere`).

## Image attachment rules (FR-006, FR-007)

1. The poster is downloaded to a temporary file and attached via
   `ShareParams(files:)`.
2. Attachment is best-effort: download failure, missing image, or an
   unsupported platform yields **text-only** content — the title, the correct
   link, and the download CTA are always delivered.
3. A title with no poster image still produces valid content (FR-006).

## Fallback behavior

- **No file support / download failed**: text template above is shared.
- **Source unreachable**: irrelevant to the share path — sharing performs no
  provider requests (research D4); the in-memory `Title` already carries the
  image and name (FR-007).
- **Download page unreachable**: recipients still receive the correct,
  stable Play Store URL that works when they are online.

## Verification

- Unit tests assert the exact text template and that every share payload
  contains the canonical link, the title name, `AW - AnimeWhere`, and a
  `play.google.com/store/apps/details` URL.
- Attachment tests assert `XFile?` is returned on success and `null` on any
  failure.
- Integration test asserts the shared URL is the canonical provider page and
  that the mock API client receives no additional requests during sharing.
