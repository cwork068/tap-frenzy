# Tap Frenzy

Tap Frenzy is a SwiftUI game for iPhone on iOS 17 or later. Its home screen offers two modes: the original 10-second Tap Frenzy round and a 60-second Light It Up card challenge. Each mode keeps its own best score on the device.

## Architecture

```text
TapFrenzy/
├── App/
│   ├── TapFrenzyApp.swift
│   └── HomeView.swift
├── Features/
│   ├── TapFrenzy/
│   │   ├── Model/GameRound.swift
│   │   └── Views/ (GameView, RoundTimerView, TapControl)
│   └── LightItUp/
│       ├── Model/LightItUpRound.swift
│       └── Views/LightItUpView.swift
└── Shared/GameTheme.swift
Tests/
├── TapFrenzy/GameRoundChecks.swift
└── LightItUp/LightItUpChecks.swift
```

The code is organized by mode. Both round models take `ContinuousClock` instants so deadline checks can run without waiting. Tap Frenzy preserves its original `highScore` key and `gamesPlayed` count. Light It Up uses `lightItUpHighScore` and `lightItUpRounds`, with three lives and four levels at 15-second intervals. Its card counts are 3, 4, 6, and 9; lit windows shorten from 1.2 to 0.9 to 0.7 to 0.5 seconds. Appearance remains stored under `appearanceMode`. Shared colours and the appearance control live in `Shared/`.

## Visual theme

The game offers separate System, Light, and Dark appearance buttons on the home screen and in both modes. Backgrounds, surfaces, text, and status colours use Apple's dynamic iOS system colours, including the system Dark appearance. The numeric countdown stays inside the TAP button while the ring moves from green to amber to red. The top bar shows Tap Frenzy's best score; its bottom stats panel shows completed rounds and the last score. The last score appears after the first completed round on an upgraded install.

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

- On the home screen, open each mode and confirm the back button returns to the mode list.
- In Tap Frenzy, confirm the first tap starts the timer and scores one point. Tap rapidly and watch the score increase.
- Let the timer expire. Check the final score, best score, and completed round count. Tap **Play Again** to return to idle, then **TAP** to start the next round.
- Beat your previous best, then complete a lower-scoring round. Force-quit and reopen the app. Check that the best score, round count, and last score persist.
- Switch between System, Light, and Dark during a round. Confirm the score and countdown continue, and that the selection persists after a relaunch.
- Background the app past the deadline, return, and check that the result appears without awarding a late tap.
- Rotate during a round and test a compact iPhone. Check that the score, timer, and button remain usable.
- Enable Reduce Motion and check that the score and button can be used without their animations.
- In Light It Up, tap any card to start. Catch a lit card to score; miss or tap the wrong card to lose a life. Check the grid and shorter windows at levels 2 through 4, and verify its separate best score after relaunch.
- Switch System, Light, and Dark with their separate buttons on the home screen and during each mode. Confirm the selected appearance changes immediately without resetting a round.
