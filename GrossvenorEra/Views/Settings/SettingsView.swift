import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("settings.haptics")       private var hapticsOn    = true
    @AppStorage("settings.animations")   private var animationsOn = true
    @AppStorage("settings.autoAdvance")  private var autoAdvance  = false
    @AppStorage("settings.colourScheme") private var colourScheme = 0
    @State private var showResetAlert = false
    @EnvironmentObject private var store: VaultStore

    var body: some View {
        NavigationStack {
            ZStack {
                ClubBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        gameplaySection
                        appearanceSection
                        houseRecordsSection
                        aboutSection
                        resetSection
                    }
                    .padding(16).padding(.bottom, 32)
                }
            }
            .navigationTitle("House Rules")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }.foregroundStyle(Palette.brassLight)
            }}
            .alert("Reset All Records?", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) {
                    store.resetAll()
                    Haptics.error()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("All prestige and house records will be lost. This cannot be undone.")
            }
        }
    }

    private var gameplaySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Gameplay").eyebrow(onLight: true)
            settingsRow(title: "Haptic Feedback",
                        subtitle: "Vibrations on tap and game events",
                        symbol: "hand.tap") {
                Toggle("", isOn: $hapticsOn).labelsHidden()
                    .tint(Palette.brassLight)
            }
            Divider().overlay(Palette.brassDeep.opacity(0.2))
            settingsRow(title: "Animations",
                        subtitle: "Transition and celebration effects",
                        symbol: "sparkles") {
                Toggle("", isOn: $animationsOn).labelsHidden()
                    .tint(Palette.brassLight)
            }
            Divider().overlay(Palette.brassDeep.opacity(0.2))
            settingsRow(title: "Auto-Advance",
                        subtitle: "Move to next question without tapping",
                        symbol: "arrow.forward.circle") {
                Toggle("", isOn: $autoAdvance).labelsHidden()
                    .tint(Palette.brassLight)
            }
        }
        .parchmentCard()
    }

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Appearance").eyebrow(onLight: true)
            settingsRow(title: "Colour Scheme",
                        subtitle: "Override system light/dark preference",
                        symbol: "moon.circle") {
                Picker("", selection: $colourScheme) {
                    Text("Auto").tag(0)
                    Text("Light").tag(1)
                    Text("Dark").tag(2)
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .foregroundStyle(Palette.brassDeep)
            }
        }
        .parchmentCard()
    }

    private var houseRecordsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("House Records").eyebrow(onLight: true)
            VStack(alignment: .leading, spacing: 4) {
                Text("All scores and prestige are stored on this device using the system's secure local storage.")
                    .font(.text(14)).foregroundStyle(Palette.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
                Text("No account or internet connection is required to play or compete.")
                    .font(.text(14)).foregroundStyle(Palette.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            NavigationLink {
                ZStack { ClubBackground(); LocalScoresView() }
            } label: {
                Label("View House Records", systemImage: "trophy")
            }
            .buttonStyle(ChipButtonStyle(onLight: true))
        }
        .parchmentCard()
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("About").eyebrow(onLight: true)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Grosvenor Era")
                        .font(.display(17, .semibold)).foregroundStyle(Palette.inkText)
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                        .font(.text(13)).foregroundStyle(Palette.mutedText)
                }
                Spacer()
                ClubCrest().frame(width: 44, height: 44).clipShape(Circle())
                    .overlay(Circle().strokeBorder(Palette.brassGradient, lineWidth: 1.5))
            }
            Text("Five rooms. One club. No subscription. Play is local, private, and yours.")
                .font(.display(14, .regular)).italic().foregroundStyle(Palette.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .parchmentCard()
    }

    private var resetSection: some View {
        VStack(spacing: 10) {
            Button { showResetAlert = true } label: {
                Label("Reset All Progress", systemImage: "trash")
            }
            .buttonStyle(InkOutlineButtonStyle())
            Text("This will clear all house records and prestige.")
                .font(.text(12)).foregroundStyle(Palette.mutedText).multilineTextAlignment(.center)
        }
    }

    @ViewBuilder
    private func settingsRow<Accessory: View>(title: String, subtitle: String, symbol: String,
                                              @ViewBuilder accessory: @escaping () -> Accessory) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.system(size: 18)).foregroundStyle(Palette.brassDeep).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.display(15, .semibold)).foregroundStyle(Palette.inkText)
                Text(subtitle).font(.text(12)).foregroundStyle(Palette.mutedText).lineLimit(1)
            }
            Spacer()
            accessory()
        }
    }
}
