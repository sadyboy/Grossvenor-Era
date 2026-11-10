import SwiftUI

struct OnboardingPage {
    let title: String
    let subtitle: String
    let illustration: AnyView
    let accent: Color
}

private let pages: [OnboardingPage] = [
    OnboardingPage(
        title: "Grosvenor Club",
        subtitle: "Five rooms. Five parlour games. One classic Mayfair address.",
        illustration: AnyView(TownhouseSkyline().padding(.horizontal, 20)),
        accent: Palette.brassDeep
    ),
    OnboardingPage(
        title: "The Estate Office",
        subtitle: "Place buildings on a five-by-five square. Gardens and mews raise their neighbours; chapels reward rarity. Plan wisely.",
        illustration: AnyView(EstatePlanArt().clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))),
        accent: Palette.greenMid
    ),
    OnboardingPage(
        title: "Mayfair Mysteries",
        subtitle: "Read the testimony and deduce who stood in which room. Mark the grid, strike the clues, then accuse.",
        illustration: AnyView(MagnifierArt()),
        accent: Palette.oxbloodLight
    ),
    OnboardingPage(
        title: "Afternoon Tea",
        subtitle: "Every blend must rest in its own cup. Pour carefully — only like meets like, or empties welcome all.",
        illustration: AnyView(TeacupArt()),
        accent: Palette.brassLight
    ),
    OnboardingPage(
        title: "Heraldry & Design",
        subtitle: "Study each coat of arms and name its blazon. Then visit the studio to design your own coat for the register.",
        illustration: AnyView(
            HStack(spacing: 8) {
                HeraldicShield(arms: Arms(field: .azure, ordinary: .cross, ordinaryTincture: .argent))
                HeraldicShield(arms: Arms(division: .perPale, field: .gules, field2: .or, charge: .mullet, chargeTincture: .argent))
                HeraldicShield(arms: Arms(field: .or, ordinary: .chevron, ordinaryTincture: .sable, charge: .roundel, chargeTincture: .gules))
            }.padding(.horizontal, 10)
        ),
        accent: Palette.parchmentDark
    ),
    OnboardingPage(
        title: "Records Kept Locally",
        subtitle: "All scores and prestige are saved on your device. No account needed. No subscription. Five rooms, always yours.",
        illustration: AnyView(TrophyArt()),
        accent: Palette.brassDeep
    ),
]

struct OnboardingView: View {
    @AppStorage("onboarding.done") private var done = false
    @State private var page = 0

    var body: some View {
        ZStack {
            ClubBackground()
            VStack(spacing: 0) {
                TabView(selection: $page) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, p in
                        OnboardingPageView(page: p).tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.45), value: page)

                VStack(spacing: 20) {
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { i in
                            Capsule()
                                .fill(i == page ? pages[page].accent : Palette.cream.opacity(0.3))
                                .frame(width: i == page ? 22 : 7, height: 7)
                                .animation(.spring(response: 0.3), value: page)
                        }
                    }
                    if page < pages.count - 1 {
                        Button("Continue") {
                            withAnimation { page += 1 }
                            Haptics.select()
                        }
                        .buttonStyle(BrassButtonStyle())
                    } else {
                        Button("Enter the Club") {
                            withAnimation(.easeInOut(duration: 0.4)) { done = true }
                            Haptics.success()
                        }
                        .buttonStyle(BrassButtonStyle())
                    }
                    if page < pages.count - 1 {
                        Button("Skip") {
                            withAnimation(.easeInOut(duration: 0.35)) { done = true }
                        }
                        .font(.display(14, .regular)).foregroundStyle(Palette.mutedText)
                    }
                }
                .padding(.horizontal, 32).padding(.vertical, 32)
            }
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 0)
            page.illustration
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 36)
                .shadow(color: .black.opacity(0.4), radius: 14, y: 6)
            VStack(spacing: 10) {
                Text(page.title)
                    .font(.display(28, .semibold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.inkText)
                Text(page.subtitle)
                    .font(.display(16, .regular)).italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Palette.mutedText)
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24)
    }
}
