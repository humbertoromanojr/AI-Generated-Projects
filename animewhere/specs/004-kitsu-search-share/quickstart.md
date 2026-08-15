# Quickstart Guide: Kitsu Section Verification & Share Branding

## Overview
This guide explains how to verify that (1) the Kitsu section works against the
live Kitsu API per the official documentation (carousel + infinite scroll
rows), and (2) sharing a title includes the app's branding and a download link.

## Prerequisites
- Flutter SDK installed and configured.
- A working internet connection (live Kitsu API and share-preview host).
- A device or emulator to launch the app (Android/iOS) for full verification.

## Validation Steps

### 1. Verify the Kitsu Carousel Loads
**Scenario**: The Kitsu section should display a populated carousel from the live API.
- **Action**: Launch the app and scroll to the "Kitsu" section.
- **Expected Outcome**: The carousel shows up to 10 Kitsu titles with poster
  images. No persistent error or empty state.

### 2. Verify Kitsu Infinite Scroll Rows
**Scenario**: Both Kitsu rows (Anime, Manga) should page infinitely, ten at a time.
- **Action**: Scroll to the end of the Anime row, then the Manga row. Repeat 3+ times.
- **Expected Outcome**: Each scroll to the end loads the next 10 titles
  automatically; no duplicate titles appear; loading stops when the catalog ends.

### 3. Verify Kitsu Detail Works for Anime and Manga
**Scenario**: Opening a Kitsu title from any row or the carousel must resolve.
- **Action**: Tap a Kitsu anime title and a Kitsu manga title, then go back.
- **Expected Outcome**: The detail screen loads for both (previously anime
  titles could 404 because detail always hit the manga endpoint).

### 4. Verify Share Branding
**Scenario**: Sharing any title must carry the app's image, name, and download link.
- **Action**: Open any title (Jikan, AniList, or Kitsu) and share it.
- **Expected Outcome**: The shared content displays the app's image, the app
  name "AW - AnimeWhere", and a link to download the app, in addition to the
  title link. Platforms without image support still show the app name and the
  download link.

### 5. Verify Other Sections Are Unaffected
**Scenario**: Kitsu fixes must not change Jikan or AniList behavior.
- **Action**: After exercising the Kitsu section, force a network failure and
  retry the Kitsu section.
- **Expected Outcome**: The Kitsu section shows a retryable error, while the
  Jikan and AniList sections remain fully functional.

### 6. Automated Checks
- `dart format` → no diffs.
- `flutter analyze` → zero issues.
- `flutter test` → full suite green (baseline 81 tests, plus new header,
  type-routing, and branding tests).
