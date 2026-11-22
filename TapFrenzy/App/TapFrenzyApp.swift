import SwiftUI

@main
struct TapFrenzyApp: App {
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
                .preferredColorScheme(AppearanceMode(rawValue: appearanceMode)?.colorScheme)
        }
    }
}
