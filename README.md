# CourtTap

CourtTap is a minimal watch-first scoring prototype for padel and tennis-style scoring.

Current MVP scope:

- Tap the upper half to score Team A.
- Tap the lower half to score Team B.
- Use undo to correct points within the current game.
- At a fresh `0-0` game boundary, undo can only restore the just-finished game point.
- Advantage scoring is supported: `40-40`, `Adv`, then `Game!`.
- The server indicator switches after each completed game.

The current repository keeps the scoring engine separate from the SwiftUI watch view so the rules can be tested independently from the UI.

## Structure

- `Sources/CourtTapCore`: scoring rules and match state.
- `Sources/CourtTapWatchUI`: SwiftUI watch-style UI prototype.
- `Tests/CourtTapCoreTests`: core scoring tests.

## Next Step

Open this package in Xcode on macOS, create a watchOS App target, and include `CourtTapWatchUI` plus `CourtTapCore`. The SwiftUI entry point is `CourtTapWatchApp`.
