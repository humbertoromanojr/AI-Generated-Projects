# Quickstart Guide: Home Carousel Auto-Slide & Kitsu API Integration

## Overview
This guide outlines how to verify the successful implementation of the automatic carousel sliding, Kitsu API integration, and the updated app branding/layout.

## Prerequisites
- Flutter SDK installed and configured.
- Access to the `/assets/icons` directory.
- A working internet connection for Kitsu API requests.

## Validation Steps

### 1. Verify Automatic Carousel Sliding
**Scenario**: The home screen carousels should advance automatically without user interaction.
- **Action**: Launch the app on an emulator or physical device and wait on the Home screen for 15 seconds.
- **Expected Outcome**: All three carousels (Jikan, AniList, Kitsu) transition between their primary images/titles at regular intervals.

### 2. Verify Kitsu API Integration
**Scenario**: The Kitsu section should correctly fetch and display data from the Kitsu Edge API.
- **Action**: Observe the Kitsu section on the Home screen during startup. Inspect network logs if necessary.
- **Expected Outcome**: Kitsu titles and posters are visible, matching the structure of Jintan and AniList sections. No "Error" or "Empty" states persist after initial loading.

### 3. Verify App Branding & Icon
**Scenario**: The installed app should show the "AW" name and use the correct icon from `/assets/icons`.
- **Action**: Install the application on a device and check the launcher icon and the app label in the device's app drawer/home screen.
- **Expected Outcome**: The icon matches the asset in `/assets/icons` and the display name is "AW".

### 4. Verify Layout Fidelity
**Scenario**: The layout must match the design references in the `/stitch` folder.
- **Action**: Compare the implemented spacing, typography, and component structure against the `/stitch` folder assets.
- **Expected Outcome**: All components (carousels, rows, headers) adhere to the design tokens defined in the project's design system.
