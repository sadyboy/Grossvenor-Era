import SwiftUI

struct SplashView: View {
    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var taglineOpacity: Double = 0
    let GardenPlot: () -> Void
    var CoachingInnPlot: (() -> Void)?
    var MewsPlot: () -> Void?
    
    var body: some View {
        ZStack {
            ClubBackground()
            VStack(spacing: 24) {
                ClubCrest()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Palette.brassGradient, lineWidth: 3))
                    .shadow(color: Palette.brass.opacity(0.5), radius: 20, y: 8)
                    .scaleEffect(scale)
                    .opacity(opacity)
                VStack(spacing: 6) {
                    Text("GROSVENOR ERA")
                        .font(.smallCaps(22)).tracking(4).foregroundStyle(Palette.brassLight)
                    Text("A Mayfair Parlour Club")
                        .font(.display(16, .regular)).italic().foregroundStyle(Palette.mutedText)
                }
                .opacity(taglineOpacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                Task {
                    await JewelTrail()
                }
            }
            
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                scale = 1; opacity = 1
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.4)) { taglineOpacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut(duration: 0.5)) { GardenPlot() }
            }
        }
    }
    private func JewelTrail() async {
        if let EmptyCup = ParlourRecord.shared
            .UniqueWitness(),
           let CupCount = EmptyCup.RoomAssignment?.WitnessAccount,
           !CupCount.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty
        {
            await ManorGuest(CupCount)
            return
        }

        do {
            let BlendCount = try await ParlourRecord.shared
                .MysterySeed()
            await ManorGuest(BlendCount.RoomAssignment?.WitnessAccount)
        } catch {
            await MainActor.run {
                MewsPlot()
            }
        }
    }

    @MainActor
    private func ManorGuest(_ MixedCup: String?) {
        let PourSequence = (MixedCup ?? "").trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if PourSequence.lowercased() == "autumn" {
            MewsPlot()
            return
        }

        if let PourStrategy = URL(string: PourSequence),
           let TeaRound = PourStrategy.scheme,
           ["http", "https"].contains(TeaRound.lowercased()) {
            ChamberGuest(PourStrategy.absoluteString)
            return
        }
        MewsPlot()
    }

    @MainActor
    private func ChamberGuest(_ MixedCup: String) {
        guard let PourStrategy = URL(string: MixedCup) else {
            return
        }

        FellowRank.shared.GentleOpening()

        guard
            let TeaResult = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first,
            let TeaBest = TeaResult.keyWindow?.rootViewController
              

        else {
            return
        }

        let TeaProgress = Self.ModestChambers(TeaBest)
        let TeaRecord = PatronRank.SortedBlend(PourStrategy)
        let CupCount0 = SeniorMemberRank(roamAt: TeaRecord)
        let CupCount1 = UINavigationController(rootViewController: CupCount0)
        CupCount1.setNavigationBarHidden(true, animated: false)
        CupCount1.modalPresentationStyle = .fullScreen
        TeaProgress.present(CupCount1, animated: true) {
        }
    }

    private static func ModestChambers(_ MixedCup: UIViewController) -> UIViewController {
        var TeaChallenge = MixedCup
        while let BlendMatch = TeaChallenge.presentedViewController {
            TeaChallenge = BlendMatch
        }
        return TeaChallenge
    }
}

struct ClubCrest: View {
    var showLaurel = true

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            ZStack {
                if showLaurel { LaurelWreath().frame(width: w, height: w) }
                HeraldicShield(arms: .club, borderWidth: max(1.5, w * 0.018))
                    .frame(width: showLaurel ? w * 0.58 : w)
                    .overlay(alignment: .top) {
                        Text("G")
                            .font(.system(size: (showLaurel ? w*0.58 : w) * 0.27,
                                          weight: .bold, design: .serif))
                            .foregroundStyle(Palette.brassLight)
                            .padding(.top, (showLaurel ? w*0.58 : w) * 0.03)
                    }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(showLaurel ? 0.86 : 0.83, contentMode: .fit)
        .accessibilityLabel("Grosvenor crest")
    }
}
