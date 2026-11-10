import SwiftUI

@main
struct GrossvenorEraApp: App {
    @StateObject private var store = VaultStore()

    init() {
        AppSkin.apply()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(Palette.brass)
        }
    }
}

struct RootView: View {
    @AppStorage("onboarding.done") private var onboardingDone = false
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashView(isShowing: $showSplash).transition(.opacity)
            } else if !onboardingDone {
                OnboardingView().transition(.opacity)
            } else {
                ClubHallView().transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.45), value: showSplash)
        .animation(.easeInOut(duration: 0.45), value: onboardingDone)
    }
}
