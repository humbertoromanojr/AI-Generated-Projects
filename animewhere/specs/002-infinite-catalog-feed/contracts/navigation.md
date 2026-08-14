# In-App Navigation Contract

Routes (`go_router`) - unchanged from feature 001:

| Route | View | Args |
|-------|------|------|
| `/` | `HomeView` | - |
| `/title/:source/:id` | `DetailView` | `source` (`TitleSource`), `id` |
| (share action) | system share sheet | `ShareTarget.shareUrl` |

- The home route now renders the three provider sections (see
  [home-feed.md](home-feed.md)); navigation structure is unchanged.
- Deep links into the app are out of scope; share links target the web build.
- All transitions use the Material page transition; navigation stays within
  `go_router` (constitution Principle I).
