import SwiftUI

@MainActor
struct HomeView: View {
    @AppStorage("highScore") private var tapBest = 0
    @AppStorage("lightItUpHighScore") private var lightBest = 0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose your game")
                            .font(.largeTitle.weight(.bold))
                            .accessibilityAddTraits(.isHeader)
                        Text("Two quick challenges. One more round.")
                            .font(.subheadline)
                            .foregroundStyle(GameTheme.secondaryText)
                    }
                    Spacer(minLength: 8)
                    AppearanceMenu()
                }
                .padding(.top, 12)

                modeCard(title: "Tap Frenzy", subtitle: "Tap as fast as you can in 10 seconds",
                         icon: "bolt.fill", tint: GameTheme.accent, best: tapBest) {
                    GameView()
                }
                modeCard(title: "Light It Up", subtitle: "Catch the lit card before it fades",
                         icon: "square.grid.2x2.fill", tint: Color(uiColor: .systemBlue),
                         best: lightBest) {
                    LightItUpView()
                }

                Text("Scores are saved on this iPhone.")
                    .font(.footnote)
                    .foregroundStyle(GameTheme.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
            }
            .frame(maxWidth: 560)
            .padding(20)
            .frame(maxWidth: .infinity)
        }
        .background(GameTheme.background.ignoresSafeArea())
        .navigationTitle("Tap Frenzy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func modeCard<Destination: View>(
        title: String, subtitle: String, icon: String, tint: Color, best: Int,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 52, height: 52)
                    .background(GameTheme.raisedSurface, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(GameTheme.text)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(GameTheme.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Best: \(best)")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(GameTheme.text)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(GameTheme.secondaryText)
                    .accessibilityHidden(true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(GameTheme.surface, in: RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title). \(subtitle). Best score \(best)")
    }
}
