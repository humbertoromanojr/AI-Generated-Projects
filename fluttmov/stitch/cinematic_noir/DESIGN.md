---
name: Cinematic Noir
colors:
  surface: '#131313'
  surface-dim: '#131313'
  surface-bright: '#393939'
  surface-container-lowest: '#0e0e0e'
  surface-container-low: '#1c1b1b'
  surface-container: '#20201f'
  surface-container-high: '#2a2a2a'
  surface-container-highest: '#353535'
  on-surface: '#e5e2e1'
  on-surface-variant: '#d3c5b0'
  inverse-surface: '#e5e2e1'
  inverse-on-surface: '#313030'
  outline: '#9b8f7c'
  outline-variant: '#4f4636'
  surface-tint: '#f4be4f'
  primary: '#ffce6c'
  on-primary: '#412d00'
  primary-container: '#e5b143'
  on-primary-container: '#604500'
  inverse-primary: '#7b5800'
  secondary: '#c7c6c6'
  on-secondary: '#2f3131'
  secondary-container: '#484949'
  on-secondary-container: '#b8b8b8'
  tertiary: '#bbd7ff'
  on-tertiary: '#00315b'
  tertiary-container: '#88bcff'
  on-tertiary-container: '#004b85'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#ffdea4'
  primary-fixed-dim: '#f4be4f'
  on-primary-fixed: '#261900'
  on-primary-fixed-variant: '#5d4200'
  secondary-fixed: '#e3e2e2'
  secondary-fixed-dim: '#c7c6c6'
  on-secondary-fixed: '#1a1c1c'
  on-secondary-fixed-variant: '#464747'
  tertiary-fixed: '#d3e4ff'
  tertiary-fixed-dim: '#a2c9ff'
  on-tertiary-fixed: '#001c38'
  on-tertiary-fixed-variant: '#004881'
  background: '#131313'
  on-background: '#e5e2e1'
  surface-variant: '#353535'
typography:
  headline-xl:
    fontFamily: Inter
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 48px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '700'
    lineHeight: 30px
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.05em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  margin-main: 20px
  gutter: 16px
  stack-sm: 8px
  stack-md: 24px
  stack-lg: 40px
---

## Brand & Style
The design system is centered on a "Cinematic Noir" aesthetic—a sophisticated, minimalist dark mode experience tailored for high-end movie discovery. The personality is premium, focused, and immersive, allowing film photography and poster art to take center stage against a void-like backdrop.

The style leans into **Minimalism** with a touch of **Glassmorphism** for navigational elements. It prioritizes high functionality and airy spacing to prevent the dark interface from feeling cramped. Emotional responses should range from focused calm to the excitement of a darkened theater lobby.

## Colors
The palette is strictly controlled to maintain a high-contrast, premium feel. 
- **Deep Black (#0D0D0D):** Used for the primary canvas to ensure OLED true-blacks and maximum immersion.
- **Burned Gold (#E5B143):** Reserved exclusively for primary actions, active states, and critical highlights (like ratings).
- **Dark Gray (#1A1A1A):** Used for surface containers, cards, and input backgrounds to create subtle separation from the base.
- **Typography:** Pure White (#FFFFFF) for high-priority information and Medium Gray (#A0A0A0) for metadata and de-emphasized labels.

## Typography
Inter is used across the entire system for its modern, neutral, and highly legible characteristics. 

Headlines utilize tight letter-spacing and heavy weights to create a bold, editorial look. Body text maintains generous line height for readability against dark backgrounds. Metadata and category labels use the `label-caps` style to provide architectural structure to the information hierarchy without competing with movie titles.

## Layout & Spacing
The design system utilizes a **Fluid Grid** with a consistent 20px outer margin for mobile devices. 

- **Vertical Rhythm:** Elements are stacked using a base-8 scale, with 24px (stack-md) being the default spacing between sections (e.g., between "Trending" and "New Releases").
- **Grid:** On mobile, movie posters should typically follow a 2-column or 3-column grid with 16px gutters. 
- **Adaptation:** On tablet and desktop, the 20px margin scales to a max-width container of 1200px, centering the content and increasing gutters to 24px.

## Elevation & Depth
Depth is communicated through **Tonal Layering** and **Subtle Glows** rather than traditional heavy shadows.

- **Level 0:** Background (#0D0D0D).
- **Level 1:** Surface (#1A1A1A) - Used for cards and secondary buttons.
- **Level 2:** Elevated Surface (#262626) - Used for modals or tooltips.
- **Special Elevation:** The primary Gold button utilizes a soft, 12px blur outer glow (0.2 opacity) using the primary color to simulate the luminosity of a cinema screen.
- **Navigation:** The bottom bar uses a background-blur (20px) with a 10% white tint to create a frosted glass effect over the scrolling content.

## Shapes
This design system employs a hierarchical rounding strategy to differentiate between UI containers and media content:

- **UI Elements (Cards, Buttons, Inputs):** 8px corner radius (`rounded-md`).
- **Media (Movie Posters, Backdrops, Avatars):** 16px corner radius (`rounded-lg`) to give content a softer, more inviting feel.
- **Interactive Small Elements:** Chips and badges use a full pill-shape.

## Components
- **Primary Button:** Burned Gold fill with White or Black text (depending on contrast needs). Includes a subtle gold shadow/glow. 8px radius.
- **Secondary Button:** Transparent background with a 1px Dark Gray border or #1A1A1A solid fill.
- **Movie Cards:** 8px radius for the container. Images inside have a 16px radius. Title text is placed directly below or overlaid with a bottom-to-top black gradient.
- **Icons:** Thin-stroke line icons (1.5px weight). Active icons in the bottom nav receive the Primary Gold color; inactive icons are Medium Gray.
- **Bottom Navigation:** Fixed position, blurred background (Glassmorphism). No labels, only icons, to maintain the minimalist aesthetic.
- **Input Fields:** #1A1A1A background, 8px radius, no border unless focused. Focused state uses a 1px Burned Gold border.
- **Chips/Genre Tags:** Pill-shaped, #1A1A1A background with White text, 12px font size.