# Tap Frenzy

Tap Frenzy is a SwiftUI game for iPhone on iOS 17 or later. The first tap starts a 10-second round and scores one point. Tap as fast as you can, then compare your result with your best score. The app saves the best score and completed round count across launches.

## Architecture

```text
TapFrenzy/
├── App/
│   └── TapFrenzyApp.swift
└── Features/
    └── Game/
        ├── Model/
        │   └── GameRound.swift
        └── Views/
            ├── GameView.swift
            ├── GameTheme.swift
            ├── RoundTimerView.swift
            └── TapControl.swift
Tests/
└── GameRoundChecks.swift
```

The code is organized by feature. `GameRound` is a Swift value type with idle, playing, and game-over states. It takes `ContinuousClock` instants as inputs, so the round checks exercise deadlines without waiting 10 seconds. A single deadline determines scoring and completion even if the app sleeps or a screen refresh is late. `GameView` owns the round through `@State` and persists the best score under its original `highScore` key, completed rounds under `gamesPlayed`, and the appearance choice under `appearanceMode`. Completion is handled once per round.

## Visual theme

The game offers System, Light, and Dark appearances. Adaptive colours keep the button, text, and countdown ring readable in each mode. The numeric countdown stays inside the TAP button while the ring moves from green to amber to red. The score uses stable digit widths, accepted taps give light haptic feedback, and animations respect Reduce Motion.

## Build from Windows

1. Open the repo folder in VS Code and push it to a private GitHub repository.
2. In a personal Codemagic account, add the GitHub repository, then choose **Start new build**.
3. Select the branch you pushed and the **Tap Frenzy iOS Build** workflow. The workflow uses a Mac mini M2 and builds for the iOS Simulator with signing disabled.
4. Check for `Round checks passed` in the scoring and timing step and `** BUILD SUCCEEDED **` in the compile log. Match the commit shown by Codemagic to your submission commit.

The repository includes `TapFrenzy.xcodeproj`, so a fresh clone opens in Xcode without installing XcodeGen. Codemagic can still generate the project from `project.yml` if the project file is absent. If you add or relocate source files, update their file references in Xcode and keep `project.yml` in sync for the Codemagic fallback.

## Run in a Windows browser

Download `TapFrenzy-Simulator.zip` from the latest successful Codemagic build's **Artifacts**. It contains the compiled ARM64 iOS Simulator bundle at `TapFrenzy.app/`. Upload the ZIP directly to [Appetize](https://appetize.io/upload) and launch an iPhone running iOS 17 or later. Use the checklist below for the gameplay checks available in your simulator session.

## Run and check in Xcode

Clone the repository on a Mac, open `TapFrenzy.xcodeproj`, select an iPhone simulator with iOS 17 or later, and press **⌘R**. No Homebrew installation is required. For a physical iPhone, select a signing team in the Xcode target settings first.

- Confirm the first tap starts the timer and scores one point. Tap rapidly and watch the score increase.
- Let the timer expire. Check the final score, best score, and completed round count. Tap **Play Again** to return to idle, then **TAP** to start the next round.
- Beat your previous best, then complete a lower-scoring round. Force-quit and reopen the app. Check that the best score and round count persist.
- Switch between System, Light, and Dark during a round. Confirm the score and countdown continue, and that the selection persists after a relaunch.
- Background the app past the deadline, return, and check that the result appears without awarding a late tap.
- Rotate during a round and test a compact iPhone. Check that the score, timer, and button remain usable.
- Enable Reduce Motion and check that the score and button can be used without their animations.
