# Quickstart: Correct Share Link Format

Validation guide for the feature. Prerequisites, run commands, and expected
outcomes mapped to the spec's success criteria. No implementation code lives
here; see `tasks.md` for that.

## Prerequisites

- Dart 3.12.x + Flutter stable installed (`flutter --version`).
- A device/emulator (Android or iOS) to exercise the share sheet; web shares
  via the Web Share API.

## Setup

```bash
flutter pub get
dart format .
flutter analyze          # 0 errors, 0 warnings
flutter test             # full suite green
```

## Run the app

```bash
flutter run -d <device>
```

## Validation scenarios

### 1. Correct link per source (User Story 1; FR-001, FR-005; SC-001)

1. Open a Jikan-sourced title (carousel/row/detail) and share it.
   - **Expected**: the shared link is `https://myanimelist.net/anime/{mal_id}`.
2. Share an AniList title → link is `https://anilist.co/anime/{id}`.
3. Share a Kitsu title → link is `https://kitsu.io/anime/{id}`.
4. **Never** does the shared content contain `https://animewhere.app/title/...`
   (FR-002; SC-002).
5. Open each shared link in a browser → it resolves to the correct title page
   on the provider site.

### 2. Share content layout (User Story 2; FR-003; SC-003)

1. Share any title.
2. **Expected order**: the title's poster image appears first, the title name
   second, then "Download the app from the Google Play Store -> AW -
   AnimeWhere" with the Play Store link
   (`https://play.google.com/store/apps/details?id=...`).
3. On platforms without file support, the text alone still carries the title,
   the correct link, and the download CTA.

### 3. Degradation (FR-006, FR-007; SC-005)

1. A title with no poster still shares valid text content (title, link, CTA).
2. Sharing performs **no** provider network requests — verify by watching the
   network log: a single share adds zero requests to the API hosts.

### 4. Automated regression

```bash
flutter test test/unit/repositories/share_repository_test.dart   # canonical URLs
flutter test test/unit/share/                                    # text + attachment
flutter test test/integration/browse_share_test.dart             # e2e share link
```

- The integration test asserts the shared URL matches
  [contracts/share-link.md](contracts/share-link.md) and that the mock API
  client sees no extra requests during sharing.

## References

- Data model: [data-model.md](data-model.md)
- Share link + content contracts: [contracts/](contracts/README.md)
- Research decisions: [research.md](research.md)
