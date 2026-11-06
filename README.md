# Clinkr

An iPhone app with a companion Apple Watch app, built with SwiftUI.

## Requirements

- Xcode 27 or later
- iOS 26.0+ / watchOS 26.0+

## Project layout

| Folder | Target | What it is |
|---|---|---|
| `Clinkr/` | Clinkr | The iPhone app |
| `Clinkr Watch App/` | Clinkr Watch App | The Apple Watch app (embedded in the iPhone app) |
| `Shared/` | Both | Code both apps use, like the data model and the design system |

## Running

1. Open `Clinkr.xcodeproj` in Xcode.
2. Pick a scheme in the toolbar:
   - **Clinkr** runs the iPhone app.
   - **Clinkr Watch App** runs the Watch app on a paired Watch simulator.
3. Pick a simulator or device and press ⌘R.

To run on your own devices, select each target, open **Signing & Capabilities**, and choose your team (your Apple ID).

## Testing

```bash
scripts/test.sh
```

This checks the code style with swift-format and `DESIGN.md`'s colors against `Shared/Palette.swift`, then runs the iPhone and Watch unit and UI tests on the newest simulators. In Xcode, press ⌘U to run the tests for the selected scheme. GitHub Actions runs the same script on every pull request and push to `main`.

## Workflow

How to work on the repo is in [CONTRIBUTING.md](CONTRIBUTING.md): branches, pull requests (each one needs a `/verify-pr` in Claude Code before merging, which reviews the code and checks the issue's acceptance criteria), code comments, versions and releases. Diagrams of how the iPhone and Watch apps fit together are in [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md), and the decisions behind the app and why they were made are in [docs/DECISIONS.md](docs/DECISIONS.md). How to read the apps' logs and crash reports is in [docs/DEBUGGING.md](docs/DEBUGGING.md). Who the app is for is in [PRODUCT.md](PRODUCT.md). Its look is in [DESIGN.md](DESIGN.md) and the [design system](https://claude.ai/artifact/MUR9q8zqsWysfgui8mdNsh).

## License

MIT. See [LICENSE](LICENSE).
