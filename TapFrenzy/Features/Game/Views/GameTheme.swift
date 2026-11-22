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
    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        })
    }

    static let background = adaptive(
        light: UIColor(red: 0.965, green: 0.976, blue: 0.965, alpha: 1),
        dark: UIColor(red: 0.055, green: 0.075, blue: 0.09, alpha: 1))
    static let surface = adaptive(light: .white,
                                  dark: UIColor(red: 0.11, green: 0.14, blue: 0.16, alpha: 1))
    static let text = Color(uiColor: .label)
    static let secondaryText = Color(uiColor: .secondaryLabel)
    static let track = adaptive(light: UIColor(red: 0.82, green: 0.87, blue: 0.84, alpha: 1),
                                dark: UIColor(red: 0.25, green: 0.31, blue: 0.30, alpha: 1))
    static let accent = adaptive(light: UIColor(red: 0.04, green: 0.42, blue: 0.28, alpha: 1),
                                 dark: UIColor(red: 0.46, green: 0.92, blue: 0.70, alpha: 1))
    static let buttonFill = adaptive(light: UIColor(red: 0.04, green: 0.42, blue: 0.28, alpha: 1),
                                     dark: UIColor(red: 0.52, green: 0.96, blue: 0.75, alpha: 1))
    static let buttonText = adaptive(light: .white,
                                     dark: UIColor(red: 0.05, green: 0.12, blue: 0.10, alpha: 1))
    static let warning = adaptive(light: UIColor(red: 0.55, green: 0.32, blue: 0.01, alpha: 1),
                                  dark: UIColor(red: 1.00, green: 0.76, blue: 0.38, alpha: 1))
    static let critical = adaptive(light: UIColor(red: 0.74, green: 0.14, blue: 0.19, alpha: 1),
                                   dark: UIColor(red: 1.00, green: 0.52, blue: 0.55, alpha: 1))
}
