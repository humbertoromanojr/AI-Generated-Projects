# Share Link Contract

## Purpose

Define the exact URL embedded in shared content (FR-001, FR-005). The shared
link is the **provider's canonical web page** for the title, never the app's
own `https://animewhere.app/title/<source>/<id>` URL (FR-002).

## Format

```
https://{provider-host}/{kind}/{id}
```

- `provider-host` by source:

  | Source  | Host                       |
  |---------|----------------------------|
  | jikan   | `myanimelist.net`          |
  | anilist | `anilist.co`               |
  | kitsu   | `kitsu.io`                 |

- `kind`: `anime` | `manga` — from `Title.kind` (FR-005).
- `id`: the provider id from `Title.id` (`mal_id` for Jikan, AniList id,
  Kitsu id).

## Examples

| Source  | Kind   | id  | URL                                        |
|---------|--------|-----|--------------------------------------------|
| jikan   | anime  | 21  | `https://myanimelist.net/anime/21`          |
| jikan   | manga  | 2   | `https://myanimelist.net/manga/2`           |
| anilist | anime  | 21  | `https://anilist.co/anime/21`               |
| anilist | manga  | 5   | `https://anilist.co/manga/5`                |
| kitsu   | anime  | 42  | `https://kitsu.io/anime/42`                 |
| kitsu   | manga  | 5   | `https://kitsu.io/manga/5`                  |

## Rules

1. The link is a pure function of `(source, kind, id)`; it MUST NOT depend on
   the provider's `url` field or on network state.
2. A manga title MUST use the manga variant (FR-005).
3. A source/kind outside the table is an error, not a silent fallback
   (Constitution Principle IV).
4. Shared content MUST NOT contain `https://animewhere.app/title/...` (FR-002).
5. Opening the link in any browser resolves to the title's page on the
   provider site (SC-001).

## Verification

- Unit tests cover all 3 sources × 2 kinds against the exact URLs above.
- The browse→detail→share integration test asserts the shared link matches
  this table and contains no `/title/` path.
