# API Adapter Contracts

**Purpose**: For each source, define the exact requests made and the
mapping/validation rules applied when converting wire payloads into the unified
domain models in `data-model.md`. Tests must pin these contracts. This revision
adds pagination (10-item pages) and the new per-provider feeds required by the
three-section infinite home.

## Common rules (all sources)

- Every request MUST be validated against a typed wire model; malformed items
  are skipped (FR-008), never crash the screen.
- Failures map to typed errors: `NetworkError` (timeout/dns), `HttpError`
  (status), `RateLimitError` (429), `ParseError` (invalid payload).
- Page size is 10 for every feed. A page whose result list has fewer than 10
  items is the final page (`hasMore = false`).
- No authentication; secrets must never be embedded (constitution).

## Jikan (jikan section) - https://api.jikan.moe/v4

| Purpose | Method/Path | Key fields |
|---------|-------------|------------|
| Carousel (top anime, 10) | `GET /top/anime?limit=10&page=1` | `data[].mal_id`, `title`, `images.jpg.large_image_url`, `score`, `type`, `year` |
| Row: seasonal | `GET /seasons/now?limit=10&page={page}` | same as above |
| Row: upcoming | `GET /seasons/upcoming?limit=10&page={page}` | same as above |
| Detail / share preview | `GET /anime/{id}` | `data.mal_id`, `title`, `synopsis`, `images`, `score`, `url`, `type`, `episodes` |

- Envelope: `{ "data": ... }`; 429 on exceeding 3 req/s or 60 req/min.
- Validation: `mal_id > 0`; non-empty `title`; non-empty
  `images.jpg.large_image_url`. `score` (0..10) mapped to 0..100.
- Paging: `page` is 1-based; `limit` fixed at 10.

## AniList (anilist section) - https://graphql.anilist.co

| Purpose | Query (fields shared: `id`, `title { romaji english }`, `coverImage { large }`, `description`, `averageScore`, `format`, `seasonYear`) |
|---------|-------------|
| Carousel (trending, 10) | `Page(page:1, perPage:10) { media(type: ANIME, sort: TRENDING_DESC) { ...fields } }` |
| Row: popular | `Page(page:{page}, perPage:10) { media(type: ANIME, sort: POPULARITY_DESC) { ...fields } }` |
| Row: top rated | `Page(page:{page}, perPage:10) { media(type: ANIME, sort: SCORE_DESC) { ...fields } }` |
| Detail / share preview | `Media(id: $id) { ...fields }` |

- Transport: HTTP POST with JSON body `{ "query": ..., "variables": ... }`;
  rate limit 90 req/min.
- Validation: non-null `id`; non-empty `title.romaji` or `title.english`;
  non-empty `coverImage.large`. `averageScore` (0..100) -> `score` directly.
- Paging: `page` is 1-based; `perPage` fixed at 10.

## Kitsu (kitsu section) - https://kitsu.io/api/edge

| Purpose | Method/Path | Key fields |
|---------|-------------|------------|
| Carousel (manga, 10) | `GET /edge/manga?sort=-popularityRank&page[limit]=10&page[offset]=0` | `data[].id`, `data[].type`, `attributes.canonicalTitle`, `attributes.posterImage.original`, `attributes.averageRating`, `attributes.subtype` |
| Row: manga | `GET /edge/manga?sort=-popularityRank&page[limit]=10&page[offset]={offset}` | same as above |
| Row: anime | `GET /edge/anime?sort=-popularityRank&page[limit]=10&page[offset]={offset}` | same as above |
| Detail / preview | `GET /edge/{anime\|manga}/{id}` | `attributes.synopsis`, `canonicalTitle`, `posterImage`, `averageRating`, `subtype` |

- Envelope: JSON:API `{ "data": [...] }`; rate limit ~100/min.
- Validation: non-empty `id`; non-empty `canonicalTitle`; non-empty
  `posterImage.original`. `averageRating` (0..100) -> `score` directly.
- `Title.kind` derived from the item-level `type` field (`anime` -> anime,
  otherwise manga).
- Paging: `page[offset] = page * 10` (0-based offset, 10 per page).
