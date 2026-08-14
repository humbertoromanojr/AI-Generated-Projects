# In-App Navigation Contract

Routes (`go_router`):

| Route | View | Args |
|-------|------|------|
| `/` | `HomeView` | - |
| `/title/:source/:id` | `DetailView` | `source` (`TitleSource`), `id` |
| (share action) | system share sheet | `ShareTarget.shareUrl` |

- Deep links into the app are out of scope; share links target the web build
  (`contracts/share-preview.md`).
- All transitions use the Material page transition; navigation stays within
  `go_router` (constitution Principle I).
