# Contracts: Infinite Catalog Feed

Index of interface contracts for the feature.

- [api-adapters.md](api-adapters.md) - external catalog APIs (Jikan, AniList,
  Kitsu) -> domain `Title` mapping, validation rules, and 10-item pagination
  contracts.
- [home-feed.md](home-feed.md) - UI contract for the three provider sections,
  carousel 10-item cap, and infinite recommendation rows.

These contracts are referenced by `quickstart.md` validation scenarios and by
the unit/widget/integration tests planned in `tasks.md`.

## Unchanged contracts (from feature 001)

- [share-preview.md](../../001-anime-manga-browser/contracts/share-preview.md) -
  share link URL contract and web preview page behavior.
- [navigation.md](navigation.md) - in-app route table (home, detail, share).
