# Share Preview Contract

## URL format

```
<web-host>/title/<source>/<id>
```

- `web-host`: deployed base URL of the app's web build (e.g.,
  `https://animewhere.app`).
- `source`: one of `jikan`, `anilist`, `kitsu` (matches `TitleSource`).
- `id`: the provider id (Jikan `mal_id`, AniList `id`, Kitsu `id`).

Example: `https://animewhere.app/title/anilist/21`

## Behavior when a recipient opens the URL

1. The page loads and shows the title's 2:3 poster image.
2. The app name "AnimeWhere" appears directly below the image (FR-006).
3. The page fetches the title from the matching catalog API and renders
   loading, error, or content states per FR-007.
4. No login, no database: data is fetched live from the matching API.

## Social media preview metadata

- Base social-preview tags (title/description/image) are served statically for
  the root URL. Dynamic per-title Open Graph tags require server-side
  rendering and are explicitly out of scope for v1 (see `research.md` section
  6).

## Verification

- Opening the link in a browser renders image + app name (SC-003).
- SC-004: a share completes in 3 or fewer taps from any screen.
