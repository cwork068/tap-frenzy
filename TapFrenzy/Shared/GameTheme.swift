import SwiftUI
import UIKit

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var symbol: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }
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

struct AppearancePicker: View {
    @AppStorage("appearanceMode") private var appearanceMode = AppearanceMode.system.rawValue
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        let current = AppearanceMode(rawValue: appearanceMode) ?? .system
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(spacing: 4))
            : AnyLayout(HStackLayout(spacing: 4))
        layout {
            ForEach(AppearanceMode.allCases) { mode in
                Button {
                    appearanceMode = mode.rawValue
                } label: {
                    Label(mode.title, systemImage: mode.symbol)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .foregroundStyle(mode == current ? GameTheme.text : GameTheme.secondaryText)
                        .background(mode == current ? GameTheme.raisedSurface : .clear,
                                    in: RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(mode.title) appearance")
                .accessibilityValue(mode == current ? "Selected" : "")
            }
        }
        .padding(4)
        .background(GameTheme.surface, in: RoundedRectangle(cornerRadius: 18))
        .frame(maxWidth: 320)
    }
}
