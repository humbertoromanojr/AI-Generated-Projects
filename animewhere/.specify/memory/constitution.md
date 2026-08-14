<!--
  Sync Impact Report
  - Version change: n/a (unratified template) → 1.0.0
  - Modified principles: none (all principles newly established)
  - Added sections: I. Layered Architecture; II. Official Flutter & Dart Best
    Practices; III. Design-System Fidelity; IV. Structured Data I/O;
    V. Tested-by-Construction; Technology Stack & Constraints;
    Development Workflow & Quality Gates; Governance
  - Removed sections: none
  - Deferred TODOs: none
-->

# AnimeWhere Constitution

## Core Principles

### I. Layered Architecture

The app MUST follow the Flutter team's recommended architecture
(https://docs.flutter.dev/app-architecture). The codebase MUST be separated
into a UI layer and a data layer:

- **UI layer** MUST use the MVVM pattern: widgets (Views) stay "dumb" and
  contain no business logic; every screen is backed by a ViewModel that owns
  its state and exposes it as `Listenable`s.
- **Data layer** MUST use the repository pattern: `Repository` and `Service`
  classes abstract all data access (APIs, persistence) behind stable
  contracts.
- **Dependency injection** MUST be used instead of globals; the `provider`
  package is the default mechanism.
- **Navigation** MUST use `go_router`.
- **Data flow MUST be unidirectional**: interactions flow from the UI layer
  to the data layer; updates flow back down. Widgets MUST NOT mutate models
  or repositories directly.
- **Models MUST be immutable**; changes require new instances. Code-generated
  models (`freezed` or `built_value`) are preferred where justified.

Rationale: Intentional layering keeps classes small with well-defined inputs
and outputs, which improves maintainability, testability, and reduces
cognitive load as the team and codebase grow.

### II. Official Flutter & Dart Best Practices

The project MUST use the latest stable versions of Dart and Flutter at the
time of a new dependency or SDK change, and MUST treat the official Flutter
documentation (https://flutter.dev/ and https://docs.flutter.dev/) as the
primary source of truth for API usage and conventions.

- Dependency upgrades to a newer stable SDK MUST NOT be blocked behind
  feature work; a maintenance task MUST be opened when a newer stable release
  is available.
- The `flutter_lints` recommended lint set MUST remain enabled and MUST pass
  (`flutter analyze` with zero errors and zero warnings).
- UI MUST be built with the current Material 3 design language via
  `ThemeData`/`ColorScheme`, using `Theme.of(context)` for all styling.
- New code MUST be formatted with `dart format` and follow the documented
  Dart style guide.
- Always follow the practical tips from Uncle Bob's _Clean Code_

Rationale: Staying current on stable releases keeps the project on supported
tooling, while official docs are the authoritative reference, avoiding
outdated or community-sourced patterns that drift from the SDK.

### III. Design-System Fidelity (NON-NEGOTIABLE)

`stitch/animewhere/DESIGN.md` is the canonical design system for AnimeWhere.
Every screen MUST reproduce the layout defined in the `/stitch` folder and
MUST map its tokens exactly to the Flutter theme:

- Color, typography, spacing, radius, and elevation tokens from the design
  system MUST be translated one-to-one into `ThemeData` and MUST NOT be
  re-derived or approximated.
- Poster art MUST use the 2:3 aspect ratio; layout MUST follow the documented
  responsive grid (12-column desktop, 2-column mobile reflow) and safe-zone
  rules.
- Depth MUST be expressed through tonal layering and glassmorphism as
  specified, not through shadows.
- A feature screen MUST NOT be merged if it visibly deviates from the
  corresponding `/stitch` mockup.
- The app will have three sections on the Home screen,
  and they should be separated on the Home screen with the following titles: jikan, anilist, and kitsu. Jikan: will feature a carousel, followed by two image scrolls following the recommendations; Anilist: will feature a carousel, followed by two image scrolls following the recommendations; Kitsu: will have the carousel, followed by two scrollable sections with images based on the recommendations

All carousels should load only 10 images at a time to avoid exceeding the request limit, and the scrollable sections will be infinite, displaying 10 images at a time

Rationale: The design system encodes a deliberate "Vivid Midnight" brand.
Visual consistency is a core product promise, so screen pixels must be
derived from the design source of truth, not from ad-hoc interpretation.

### IV. Structured Data I/O

All structured data handled by the app — API responses, configuration,
and any LLM/AI generated or consumed content — MUST use explicit, typed
schemas so that input and output are unambiguous and reliably parsable,
per https://docs.flutter.dev/ai/best-practices/structure-output.

- JSON payloads MUST be validated against a declared schema (model class or
  JSON Schema) at the boundary; malformed data MUST surface as typed errors,
  never as silent partial state.
- Every structured model MUST define how it serializes and deserializes, with
  defensive handling of missing or null fields.
- When the app integrates LLM/AI services, prompts MUST specify the expected
  output schema and responses MUST be validated against it before use.

Rationale: Explicit schemas convert runtime surprises into compile-time
contracts, keeping the data layer robust against upstream API or model
changes.

### V. Tested-by-Construction

Behavior MUST be verified by automated tests following the official Flutter
testing guide (https://docs.flutter.dev/testing/overview):

- **Unit tests** MUST cover all repositories, services, and ViewModel logic
  (including error paths).
- **Widget tests** MUST cover each screen's rendering and user interactions
  using the app's design tokens.
- **Integration tests** MUST cover end-to-end user journeys (e.g., browse,
  search, detail) across real service contracts.
- New non-trivial logic MUST ship with its tests in the same change.
- The full suite MUST pass before any merge.

Rationale: Layered architecture is only trustworthy if each layer's contract
is proven by tests; test coverage is what makes refactoring and feature
growth low-risk.

## Technology Stack & Constraints

- **Language & framework**: Dart + Flutter, latest stable channel. The Dart
  SDK constraint in `pubspec.yaml` MUST match the stable release in use
  (currently `^3.12.2`).
- **State management**: `ChangeNotifier`/`provider` with MVVM ViewModels, per
  the architecture principle.
- **Navigation**: `go_router` for all routing and deep links.
- **Models**: plain immutable Dart classes, upgraded to `freezed`/`built_value`
  when code generation is justified (larger model sets, JSON ser/des).
- **Linting**: `flutter_lints` (recommended set) with zero warnings.
- **Platforms**: all scaffolded targets (Android, iOS, Linux, macOS, web,
  Windows) MUST remain buildable; responsive behavior MUST follow the
  design system's breakpoint rules.
- **Secrets**: API keys and credentials MUST NOT be committed to the
  repository; they MUST be injected via configuration or platform channels.

## Development Workflow & Quality Gates

All work MUST follow the Spec Kit cycle defined in
`.specify/workflows/speckit/workflow.yml`: `specify` → `plan` (review gate) →
`tasks` → `implement`.

- Feature work MUST NOT start before a specification and plan have been
  approved at the review gates.
- Every change MUST pass, in order: `dart format` (no diffs), `flutter analyze`
  (zero issues), and `flutter test` (full suite green).
- Pull requests MUST verify compliance with this constitution as part of the
  review.
- Design-related changes MUST be checked against `stitch/animewhere/DESIGN.md`
  and the `/stitch` mockups before approval.
- follow the app’s DP layout according to the information in this folder: /stitch

## Governance

This constitution supersedes all other development practices, ad-hoc
conventions, and individual preferences. When this document conflicts with
any template, guide, or habit, this document wins.

- **Amendments**: Any proposed change MUST be submitted as a documented
  amendment stating the affected principle/section, the motivation, and the
  migration impact. Amendments take effect only after explicit approval and a
  version bump; this file's `Last Amended` date MUST be updated.
- **Versioning policy**: The `CONSTITUTION_VERSION` follows semantic
  versioning: MAJOR for removal or redefinition of a principle or of the
  governance rules; MINOR for a new principle/section or materially expanded
  guidance; PATCH for clarifications, wording, or typo fixes.
- **Compliance review**: All plan and code review gates MUST verify
  compliance with the Core Principles. Any deviation MUST be justified in the
  change description and, if systemic, MUST be proposed as an amendment.

**Version**: 1.0.0 | **Ratified**: 2026-08-14 | **Last Amended**: 2026-08-14
