---
name: AnimeWhere
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#262626'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#201f1f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353534'
  on-surface: '#e5e2e1'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#8c909f'
  outline-variant: '#414754'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e69'
  primary-container: '#4c8eff'
  on-primary-container: '#00285d'
  inverse-primary: '#005ac2'
  secondary: '#c6c6c7'
  on-secondary: '#2f3131'
  secondary-container: '#454747'
  on-secondary-container: '#b4b5b5'
  tertiary: '#d5baff'
  on-tertiary: '#42008a'
  tertiary-container: '#a974ff'
  on-tertiary-container: '#3a0079'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a41'
  on-primary-fixed-variant: '#004494'
  secondary-fixed: '#e2e2e2'
  secondary-fixed-dim: '#c6c6c7'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#454747'
  tertiary-fixed: '#ecdcff'
  tertiary-fixed-dim: '#d5baff'
  on-tertiary-fixed: '#270057'
  on-tertiary-fixed-variant: '#5f00c0'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353534'
  surface-deep: '#161616'
  glass-tint: rgba(255, 255, 255, 0.05)
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
  stack-xs: 0.25rem
  stack-sm: 0.5rem
  stack-md: 1rem
  stack-lg: 2.5rem
---

## Brand & Style

This design system is built for the **AnimeWhere** platform, targeting a demographic that demands speed, immersion, and a "premium streaming" feel. The brand personality is "Vivid Midnight"—a cinematic experience where the interface recedes to let the vibrant, diverse art of anime take center stage. 

The style utilizes **Minimalism** with **Glassmorphism** accents to create a sophisticated, tech-forward aesthetic. It moves away from the cluttered layouts of traditional anime databases toward a refined, high-end gallery experience. The interface is optimized for long-duration viewing, prioritizing eye comfort and visual hierarchy through a deep, structured dark mode.

## Colors

The palette is anchored in a true-black foundation to maximize the "pop" of anime posters and video content.

- **Primary (#3A86FF):** A lighter, more vibrant electric blue. It is used for active states, progress bars, and critical call-to-actions, ensuring high visibility against dark backgrounds.
- **Secondary (#FFFFFF):** Pure white, used sparingly for primary text and high-impact iconography to maintain a clean look.
- **Tertiary (#8338EC):** A vivid violet used for special badges (e.g., "Premium" or "Simulcast") to add a touch of dynamic energy.
- **Neutral (#0D0D0D):** The core background color. It provides a deeper contrast than standard grays, enhancing the cinematic feel.
- **Text Strategy:** To prevent "halation" (the glowing effect of white on black), body text is set to 85% opacity, while headlines remain at 100% for maximum impact.

## Typography

This design system utilizes **Inter** exclusively to maintain a systematic, utilitarian, and modern feel that does not compete with the expressive typography often found in anime logos.

The type hierarchy relies on heavy weights for headlines to anchor the layout, while labels use increased letter spacing and uppercase styling to feel like refined metadata. On mobile, font sizes scale down slightly to ensure posters and imagery remain the primary focus of the viewport.

## Layout & Spacing

The layout follows a **Fluid Grid** model with an emphasis on negative space to achieve a "breezy" minimalist feel despite high content density.

- **Grid:** A 12-column grid is standard for desktop. For anime listings, use a responsive grid that prioritizes a 2:3 aspect ratio for posters.
- **Rhythm:** An 8px linear scale governs all spacing.
- **Mobile Reflow:** On mobile, content transitions to a 2-column card layout to maintain legible poster art while maximizing vertical scroll efficiency.
- **Safe Zones:** Always maintain a minimum of 16px horizontal padding on mobile to prevent content from touching the device edges.

## Elevation & Depth

Depth is conveyed through **Tonal Layering** and **Glassmorphism** rather than traditional drop shadows, which can feel muddy on deep black backgrounds.

- **Level 0 (Base):** Neutral Black (#0D0D0D) for the main canvas.
- **Level 1 (Surface):** "Surface-Deep" (#161616) for cards or container sections to create a subtle lift.
- **Level 2 (Interactive):** "Surface-Bright" (#262626) for hover states or active selection.
- **Glassmorphism:** Global navigation and floating video controls use a 20px backdrop blur with a 5% white tint. This creates a sense of spatial awareness as colorful posters move behind the interface elements.

## Shapes

The design system uses a **Rounded** language to feel approachable and modern, softening the dense grid layouts common in media apps.

- **Posters & Cards:** Use `rounded-lg` (1rem) to create a premium, "object-like" feel for anime titles.
- **Buttons & Inputs:** Use the standard `rounded` (0.5rem) for a balanced, professional look.
- **Tags & Indicators:** Must be fully pill-shaped to differentiate metadata from interactive buttons.

## Components

- **Buttons:** Primary buttons use the vibrant Primary Blue with white text. Secondary buttons are "Ghost" style: transparent with a 1px border of white at 20% opacity.
- **Anime Cards:** Borderless by default. Upon hover, the card should scale slightly (1.04x) and display a glassmorphic overlay containing "Add to List" or "Play" actions.
- **Navigation:** Top-fixed on desktop, bottom-tabbed on mobile. Icons should use a consistent 2px stroke width to match the Inter typeface's weight.
- **Progress Bars:** Use the Primary Blue for the active track. The inactive track should be a dark grey (#333) with 50% opacity.
- **Inputs:** Search bars should be integrated into the background using "Surface-Deep," with the border color shifting to Primary Blue on focus.
- **Chips:** Small, pill-shaped containers using "Surface-Bright" for genres, providing a subtle contrast against the base background.