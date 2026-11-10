import SwiftUI

struct HeraldryQuizView: View {
    @EnvironmentObject private var store: VaultStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var quiz = BlazonQuiz()
    @State private var showRules = false
    @State private var result: RoundResult?

    var body: some View {
        ZStack {
            ClubBackground()
            switch quiz.phase {
            case .intro:  introPane
            case .playing: playPane
            case .over:    EmptyView()
            }
            if let result {
                ResultCard(
                    title: "Heraldry Examined",
                    message: "The Heralds of Arms record your performance in the Ordinary of Grosvenor.",
                    scoreLabel: "Score",
                    result: result,
                    boardKey: .heraldry,
                    primaryTitle: "New Examination",
                    onPrimary: { withAnimation { self.result = nil }; quiz.reset() },
                    onExit: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .roomChrome(title: "The Heralds' Chamber", boardKey: .heraldry) { showRules = true }
        .sheet(isPresented: $showRules) {
            RulesSheet(
                title: "Blazon & Shield",
                intro: "The College of Arms examines your knowledge of heraldry. Study the shield and choose the blazon — the formal description — that matches it.",
                rules: [
                    RuleItem(title: "Tinctures", detail: "Or (gold), Argent (silver), Gules (red), Azure (blue), Sable (black), Vert (green), Purpure (purple)."),
                    RuleItem(title: "Divisions",  detail: "Party per pale divides the shield vertically; per fess horizontally; per bend diagonally."),
                    RuleItem(title: "Ordinaries", detail: "Chief is the upper band; fess the middle; pale a vertical bar; bend a diagonal; chevron an inverted V; cross."),
                    RuleItem(title: "Charges",    detail: "Common charges: mullet (star), roundel (circle), lozenge (diamond), crescent."),
                    RuleItem(title: "Scoring",    detail: "60 seconds. Each correct answer earns 100 points plus a streak bonus. A wrong answer costs 3 seconds."),
                ]
            )
        }
        .onChange(of: quiz.phase) {
            if quiz.phase == .over { finish() }
        }
    }

    private var introPane: some View {
        VStack(spacing: 24) {
            LaurelWreath().frame(width: 100, height: 100)
            Text("The Heralds' Examination").font(.display(26, .semibold))
                .multilineTextAlignment(.center).foregroundStyle(Palette.inkText)
            Text("60 seconds. Study each coat of arms and choose the blazon that describes it.")
                .font(.display(16, .regular)).italic()
                .multilineTextAlignment(.center).foregroundStyle(Palette.mutedText)
                .padding(.horizontal, 20).fixedSize(horizontal: false, vertical: true)
            Button("Begin Examination") { quiz.start(); Haptics.select() }
                .buttonStyle(BrassButtonStyle())
        }
        .padding(32)
    }

    private var playPane: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    StatPill(label: "Score",   value: "\(quiz.score)")
                    StatPill(label: "Correct", value: "\(quiz.correct)")
                    StatPill(label: "Streak",  value: "\(quiz.streak)")
                }
                timeBar
                shieldCard
                blazonOptions
            }
            .padding(16).padding(.bottom, 32)
        }
    }

    private var timeBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("TIME").font(.smallCaps(10)).tracking(1.2).foregroundStyle(Palette.mutedText)
                Spacer()
                Text(String(format: "%.0f", quiz.timeLeft))
                    .font(.system(size: 13, weight: .bold).monospacedDigit())
                    .foregroundStyle(quiz.timeLeft < 15 ? Palette.oxbloodLight : Palette.brassLight)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1)).frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(quiz.timeLeft < 15 ? AnyShapeStyle(Palette.oxbloodLight) : AnyShapeStyle(Palette.brassGradient))
                        .frame(width: geo.size.width * min(1, CGFloat(quiz.timeLeft / BlazonQuiz.duration)), height: 6)
                        .animation(.linear(duration: 0.1), value: quiz.timeLeft)
                }
            }
            .frame(height: 6)
        }
        .padding(.horizontal, 4)
    }

    private var shieldCard: some View {
        VStack(spacing: 12) {
            Text("Name this coat of arms").eyebrow(onLight: true)
            HeraldicShield(arms: quiz.arms)
                .frame(maxWidth: 180)
                .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
                .id(quiz.round)
                .transition(.scale.combined(with: .opacity))
        }
        .padding(.vertical, 8)
    }

    private var blazonOptions: some View {
        VStack(spacing: 10) {
            Text("Choose the blazon").eyebrow(onLight: true)
            ForEach(quiz.options, id: \.self) { option in
                Button { quiz.answer(option); Haptics.tap() } label: {
                    Text(option)
                        .font(.display(15, .semibold)).italic()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16).padding(.vertical, 12)
                        .background(optionBackground(for: option))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(optionBorder(for: option), lineWidth: 1.5))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(quiz.picked != nil)
                .accessibilityLabel(option + (option == quiz.arms.blazon ? ", correct answer" : ""))
            }
        }
    }

    private func optionBackground(for option: String) -> AnyShapeStyle {
        guard let picked = quiz.picked else {
            return AnyShapeStyle(Palette.parchment.opacity(0.9))
        }
        if option == quiz.arms.blazon { return AnyShapeStyle(Palette.greenMid.opacity(0.25)) }
        if option == picked            { return AnyShapeStyle(Palette.oxblood.opacity(0.2)) }
        return AnyShapeStyle(Palette.parchment.opacity(0.4))
    }

    private func optionBorder(for option: String) -> Color {
        guard let picked = quiz.picked else { return Palette.brassDeep.opacity(0.4) }
        if option == quiz.arms.blazon { return Palette.greenMid }
        if option == picked           { return Palette.oxbloodLight }
        return Palette.brassDeep.opacity(0.2)
    }

    private func finish() {
        let score = quiz.score
        let isRecord = store.record(room: .heraldry, score: score, prestigeGain: score / 5)
        Haptics.success()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            result = RoundResult(score: score, isRecord: isRecord,
                                 bestText: Room.heraldry.bestText(store.best(for: .heraldry)))
        }
    }
}
