import SwiftUI
import UIKit

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum GameTheme {
    static let background = Color(uiColor: .systemBackground)
    static let surface = Color(uiColor: .secondarySystemBackground)
    static let raisedSurface = Color(uiColor: .tertiarySystemBackground)
    static let text = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let track = Color(uiColor: .systemGray4)
    static let accent = Color(uiColor: .systemGreen)
    static let buttonFill = Color(uiColor: .systemGreen)
    static let buttonText = Color.black
    static let warning = Color(uiColor: .systemOrange)
    static let critical = Color(uiColor: .systemRed)
}

struct AppearanceMenu: View {
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue

    var body: some View {
        let current = AppearanceMode(rawValue: appearanceMode) ?? .system
        Menu {
            ForEach(AppearanceMode.allCases) { mode in
                Button {
                    appearanceMode = mode.rawValue
                } label: {
                    if mode == current { Label(mode.title, systemImage: "checkmark") }
                    else { Text(mode.title) }
                }
            }
        } label: {
            Image(systemName: "circle.lefthalf.filled")
                .font(.title3)
                .foregroundStyle(GameTheme.text)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel("Appearance, \(current.title) selected")
        .accessibilityHint("Choose System, Light, or Dark")
    }
}
