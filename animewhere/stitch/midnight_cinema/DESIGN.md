---
name: Midnight Cinema
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#3a3939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c4c6cf'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8e9198'
  outline-variant: '#43474e'
  surface-tint: '#afc8f0'
  primary: '#afc8f0'
  on-primary: '#163152'
  primary-container: '#001f3f'
  on-primary-container: '#6f88ad'
  inverse-primary: '#476083'
  secondary: '#c6c6c7'
  on-secondary: '#2f3131'
  secondary-container: '#454747'
  on-secondary-container: '#b4b5b5'
  tertiary: '#a7c8ff'
  on-tertiary: '#003061'
  tertiary-container: '#001e41'
  on-tertiary-container: '#6487bf'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d4e3ff'
  primary-fixed-dim: '#afc8f0'
  on-primary-fixed: '#001c3a'
  on-primary-fixed-variant: '#2f486a'
  secondary-fixed: '#e2e2e2'
  secondary-fixed-dim: '#c6c6c7'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#454747'
  tertiary-fixed: '#d5e3ff'
  tertiary-fixed-dim: '#a7c8ff'
  on-tertiary-fixed: '#001b3c'
  on-tertiary-fixed-variant: '#1f477b'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
typography:
  display:
    fontFamily: Inter
    fontSize: 48px
    fontWeight: '800'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.05em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  container-max: 1280px
  gutter: 1.5rem
  margin-desktop: 2rem
  margin-mobile: 1rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 2rem
---

## Brand & Style

This design system is tailored for a teenage audience that values immersion and speed. The brand personality is "Obsidian Clarity"—a sleek, cinematic experience that recedes into the background to let vibrant anime artwork take center stage. 

The style combines **Minimalism** with subtle **Glassmorphism**. By using a deep, dark palette, we reduce visual noise and eye strain during long browsing sessions. The aesthetic is "Premium Otaku": moving away from the cluttered, loud designs of traditional anime sites toward a sophisticated, streaming-first interface that feels more like a high-end gallery than a forum.

## Colors

The palette is strictly high-contrast to ensure maximum legibility against dark backgrounds. 

- **Primary (#001F3F):** Used for deep backgrounds and subtle brand moments.
- **Secondary (#FFFFFF):** Reserved for primary text, icons, and high-impact action buttons.
- **Surface/Neutral (#0A0A0A):** The true black base for the main content area to make poster colors "pop."
- **Accents:** Use pure white or the secondary blue tier for interactive states. Do not introduce tertiary colors that compete with the anime artwork.

## Typography

This design system utilizes **Inter** exclusively to maintain a systematic, utilitarian, and modern feel. 

- **Weight Strategy:** Use Bold (700) or Extra Bold (800) for titles to create a strong hierarchy against the dark background.
- **Readability:** Body text should maintain a 0.8 opacity (Off-white) to reduce "halation" (the glowing effect of white text on black), while headings remain pure white.
- **Labels:** Small labels for genres or episode counts should use increased letter spacing and uppercase styling for a refined, metadata-heavy look.

## Layout & Spacing

The layout follows a **Fluid Grid** model with generous margins to enforce the minimalist aesthetic.

- **Grid:** Use a 12-column grid for desktop and a 2-column or 4-column grid for mobile anime cards.
- **Safe Zones:** Content must maintain a 16px (mobile) or 32px (desktop) horizontal safe area.
- **Rhythm:** Use a consistent 8px scale. Vertical spacing between content sections should be aggressive (e.g., 48px or 64px) to create the "clean" feeling requested.
- **Poster Ratios:** All anime posters must adhere to a 2:3 aspect ratio to maintain alignment across varying screen widths.

## Elevation & Depth

Depth is achieved through **Tonal Layering** and **Backdrop Blurs** rather than traditional shadows.

- **Background (Level 0):** Pure black (#000000) for the content canvas.
- **Surface (Level 1):** Deep Navy (#001F3F) for card backgrounds or section containers.
- **Glassmorphism:** Navigation bars and floating players use a `blur(20px)` effect with a 10% white tint. This allows the colors of the anime posters to bleed through subtly as the user scrolls.
- **Outlines:** Use thin, 1px borders with 10% white opacity for buttons and card edges to define shapes without adding visual weight.

## Shapes

The design system uses a very high degree of roundedness to feel approachable and modern.

- **Standard Elements:** Buttons and input fields use a `1rem` (16px) radius.
- **Content Cards:** Anime posters and manga covers should use `rounded-lg` (1rem) to `rounded-xl` (1.5rem) to soften the "boxed" feel of grid layouts.
- **Pills:** Status indicators (e.g., "New Episode", "Completed") must be fully pill-shaped.

## Components

- **Buttons:** Primary buttons are pure white with black text. Secondary buttons are transparent with a 1px white border. Hover states should involve a subtle scale-up (1.02x).
- **Anime Cards:** No visible borders. Title appears below the image in white. Hovering on desktop reveals a "Quick Add" button using a glassmorphic overlay.
- **Navigation:** A bottom bar on mobile and a top-fixed bar on desktop. Both use the glassmorphic blur effect with thin, linear icons (2px stroke width).
- **Chips/Badges:** Small, dark-blue backgrounds with white text. Used for genres (e.g., Shonen, Seinen).
- **Input Fields:** Search bars should be dark grey/black with a subtle white border, appearing almost integrated into the background until focused.
- **Progress Bars:** For "Continue Watching," use a thin white line on a semi-transparent grey track, located at the very bottom edge of the anime card.