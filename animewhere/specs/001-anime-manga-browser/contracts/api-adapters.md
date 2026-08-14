# API Adapter Contracts

**Purpose**: For each source, define the exact requests made and the
mapping/validation rules applied when converting wire payloads into the unified
domain models in `data-model.md`. Tests must pin these contracts.

## Common rules (all sources)

- Every request MUST be validated against a typed wire model; malformed items
  are skipped (FR-008), never crash the screen.
- Failures map to typed errors: `NetworkError` (timeout/dns), `HttpError`
  (status), `RateLimitError` (429), `ParseError` (invalid payload).
- No authentication; secrets must never be embedded (constitution).

## Jikan (part 1) - https://api.jikan.moe/v4

| Purpose | Method/Path | Key fields |
|---------|-------------|------------|
| Carousel (top anime) | `GET /top/anime?limit=10` | `data[].mal_id`, `title`, `images.jpg.large_image_url`, `score`, `type`, `year` |
| Latest/Simulcast | `GET /seasons/now?limit=20` | `data[].mal_id`, `title`, `images`, `score`, `season`, `year` |
| Detail / share preview | `GET /anime/{id}` | `data.mal_id`, `title`, `synopsis`, `images`, `score`, `url`, `type`, `episodes` |

- Envelope: `{ "data": ... }`; 429 on exceeding 3 req/s or 60 req/min.
- Validation: `mal_id > 0`; non-empty `title`; non-empty
  `images.jpg.large_image_url`. `score` (0..10) mapped to 0..100.

## AniList (part 2) - https://graphql.anilist.co

| Purpose | Query (fields shared: `id`, `title { romaji english }`, `coverImage { large }`, `description`, `averageScore`, `format`, `seasonYear`) |
|---------|-------------|
| Trending anime | `Page(perPage: 10) { media(type: ANIME, sort: TRENDING_DESC) { ...fields } }` |
| Popular anime | `Page(perPage: 20) { media(type: ANIME, sort: POPULARITY_DESC) { ...fields } }` |
| Detail / share preview | `Media(id: $id) { ...fields }` |

- Transport: HTTP POST with JSON body `{ "query": ..., "variables": ... }`;
  rate limit 90 req/min.
- Validation: non-null `id`; non-empty `title.romaji` or `title.english`;
  non-empty `coverImage.large`. `averageScore` (0..100) -> `score` directly.

## Kitsu (part 3) - https://kitsu.io/api/edge

| Purpose | Method/Path | Key fields |
|---------|-------------|------------|
| Manga rows | `GET /edge/manga?sort=-popularityRank&page[limit]=10` | `data[].id`, `attributes.canonicalTitle`, `attributes.posterImage.original`, `attributes.averageRating`, `attributes.subtype` |
| Manga detail / preview | `GET /edge/manga/{id}` | `attributes.synopsis`, `canonicalTitle`, `posterImage`, `averageRating`, `subtype` |

- Envelope: JSON:API `{ "data": [...] }`; rate limit ~100/min.
- Validation: non-empty `id`; non-empty `canonicalTitle`; non-empty
  `posterImage.original`. `averageRating` (0..100) -> `score` directly.
