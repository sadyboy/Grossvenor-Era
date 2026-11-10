import SwiftUI

struct RoundResult: Equatable {
    let score: Int
    let isRecord: Bool
    let bestText: String
}

struct ResultCard: View {
    let title: String
    let message: String
    let scoreLabel: String
    let result: RoundResult
    var boardKey: BoardKey?
    var primaryTitle: String = "Play Again"
    let onPrimary: () -> Void
    let onExit: () -> Void

    @State private var showScores = false
    @State private var appear    = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 14) {
                ZStack {
                    LaurelWreath(color: Palette.brassDeep).frame(width: 104, height: 104)
                    Image(systemName: result.isRecord ? "crown.fill" : "seal.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(result.isRecord ? Palette.oxblood : Palette.brassDeep)
                }
                Text(title)
                    .font(.display(28))
                    .foregroundStyle(Palette.inkText)
                    .multilineTextAlignment(.center)
                Text(message)
                    .font(.display(15, .regular)).italic()
                    .foregroundStyle(Palette.mutedText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                Ornament(color: Palette.brassDeep).frame(width: 160)
                VStack(spacing: 2) {
                    Text("\(result.score)")
                        .font(.display(52))
                        .foregroundStyle(Palette.oxblood)
                        .monospacedDigit()
                    Text(scoreLabel.uppercased())
                        .font(.system(size: 11, weight: .semibold))
                        .tracking(2)
                        .foregroundStyle(Palette.mutedText)
                }
                if result.isRecord {
                    Text("A New House Record")
                        .font(.smallCaps(14))
                        .foregroundStyle(Palette.cream)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(Capsule().fill(Palette.oxblood))
                } else {
                    Text(result.bestText)
                        .font(.text(13))
                        .foregroundStyle(Palette.mutedText)
                }
                VStack(spacing: 10) {
                    Button(primaryTitle, action: onPrimary)
                        .buttonStyle(BrassButtonStyle())
                    HStack(spacing: 10) {
                        if boardKey != nil {
                            Button { showScores = true } label: {
                                Label("Rankings", systemImage: "trophy")
                            }
                            .buttonStyle(InkOutlineButtonStyle())
                        }
                        Button("The Hall", action: onExit)
                            .buttonStyle(InkOutlineButtonStyle())
                    }
                }
                .padding(.top, 6)
            }
            .parchmentCard(padding: 24)
            .padding(24)
            .scaleEffect(appear ? 1 : 0.86)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) { appear = true }
        }
        .sheet(isPresented: $showScores) {
            LocalScoresView(highlighted: boardKey)
        }
    }
}
