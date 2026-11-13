import SwiftUI

struct MysteryView: View {
    @EnvironmentObject private var store: VaultStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var game = MysteryGame()
    @State private var showRules = false
    @State private var result: RoundResult?

    private var c: MysteryCase { game.current }
    private var cellSize: CGFloat { c.size == 4 ? 52 : 42 }

    var body: some View {
        ZStack {
            ClubBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    caseHeader
                    deductionGrid
                        .modifier(ShakeEffect(animatableData: CGFloat(game.shake)))
                        .animation(.linear(duration: 0.4), value: game.shake)
                    if let message = game.message {
                        Text(message)
                            .font(.display(15, .regular)).italic()
                            .foregroundStyle(Palette.brassLight)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                    }
                    testimony
                    actions
                }
                .padding(16).padding(.bottom, 24)
            }
            if let result {
                ResultCard(
                    title: "Case Closed",
                    message: "It was \(c.suspects[c.culprit].name), in the \(c.rooms[c.crimeRoom].name). The \(c.title.replacingOccurrences(of: "The ", with: "").lowercased()) is safely returned.",
                    scoreLabel: "Detective's Score",
                    result: result,
                    boardKey: .mystery,
                    primaryTitle: "Open the Next Case",
                    onPrimary: { withAnimation { self.result = nil }; game.nextCase() },
                    onExit: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .roomChrome(title: "The Library", boardKey: .mystery, onDismiss: { dismiss() }) { showRules = true }
        .sheet(isPresented: $showRules) {
            RulesSheet(
                title: "Mayfair Mysteries",
                intro: "Something precious has gone missing. Every guest was in a different room — read the testimony and deduce who stood where.",
                rules: [
                    RuleItem(title: "Mark the grid",       detail: "Tap a square once to rule a guest out of a room (✕), twice to place them there (✓), a third time to clear it."),
                    RuleItem(title: "One guest, one room", detail: "Placing a guest automatically rules out the rest of their row and column."),
                    RuleItem(title: "Upstairs and down",   detail: "Each room is marked as upstairs or on the ground floor. Some testimony depends on it."),
                    RuleItem(title: "Strike the testimony",detail: "Tap a statement to strike it through once you have used it."),
                    RuleItem(title: "Make the accusation", detail: "When every guest is placed, accuse. Speed earns points; wrong accusations and the footman's hints cost them."),
                ]
            )
        }
        .showRulesOnFirstVisit("mystery", isPresented: $showRules)
        .onAppear { game.restartIfReset() }
    }

    private var caseHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Case No. \(romanNumeral(c.number))").eyebrow(onLight: true)
                Spacer()
                TimelineView(.periodic(from: .now, by: 1)) { ctx in
                    let seconds = game.solved
                        ? game.solveSeconds
                        : Int(ctx.date.timeIntervalSince(game.startDate))
                    Label(String(format: "%d:%02d", seconds/60, seconds%60), systemImage: "clock")
                        .font(.system(size: 13, weight: .semibold).monospacedDigit())
                        .foregroundStyle(Palette.mutedText)
                }
            }
            Text(c.title).font(.display(26)).foregroundStyle(Palette.inkText)
            Text(c.story).font(.text(14)).foregroundStyle(Palette.mutedText)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 14) {
                Label("\(game.wrongGuesses) wrong", systemImage: "xmark.seal")
                Label("\(game.hintsUsed) hints",    systemImage: "lightbulb")
                Spacer()
                Label(c.rooms[c.crimeRoom].name, systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(Palette.oxblood)
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Palette.mutedText)
        }
        .parchmentCard()
    }

    private var deductionGrid: some View {
        Grid(horizontalSpacing: 4, verticalSpacing: 4) {
            GridRow {
                Color.clear.frame(width: 1, height: 1)
                ForEach(0..<c.size, id: \.self) { r in
                    let room = c.rooms[r]
                    VStack(spacing: 3) {
                        Image(systemName: room.symbol)
                            .font(.system(size: 15))
                            .foregroundStyle(r == c.crimeRoom ? Palette.oxbloodLight : Palette.brassLight)
                        Text(room.short)
                            .font(.system(size: 9, weight: .semibold))
                            .lineLimit(1).minimumScaleFactor(0.7)
                            .foregroundStyle(Palette.cream)
                        Text(room.upstairs ? "UPSTAIRS" : "GROUND")
                            .font(.system(size: 7, weight: .bold)).tracking(0.5)
                            .foregroundStyle(Palette.brass.opacity(0.8))
                    }
                    .frame(width: cellSize)
                    .accessibilityElement(children: .combine)
                }
            }
            ForEach(0..<c.size, id: \.self) { s in
                GridRow {
                    Text(c.suspects[s].short)
                        .font(.display(14, .semibold)).foregroundStyle(Palette.cream)
                        .lineLimit(1).minimumScaleFactor(0.75)
                        .frame(width: 76, alignment: .leading)
                    ForEach(0..<c.size, id: \.self) { r in
                        MarkCell(mark: game.marks[s][r], solvedCorrect: game.solved && c.solution[s] == r)
                            .frame(width: cellSize, height: cellSize)
                            .onTapGesture {
                                withAnimation(.easeOut(duration: 0.15)) { game.cycle(s, r) }
                                Haptics.select()
                            }
                            .accessibilityLabel("\(c.suspects[s].name) in the \(c.rooms[r].name)")
                            .accessibilityValue(markDescription(game.marks[s][r]))
                    }
                }
            }
        }
        .padding(14).frame(maxWidth: .infinity)
        .lacquerPanel(padding: 0)
    }

    private var testimony: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Testimony").eyebrow(onLight: true)
            ForEach(Array(c.clues.enumerated()), id: \.offset) { index, clue in
                let isStruck = game.struck.contains(index)
                Button {
                    withAnimation(.easeOut(duration: 0.2)) { game.toggleClue(index) }
                } label: {
                    HStack(alignment: .top, spacing: 10) {
                        Text(romanNumeral(index + 1) + ".")
                            .font(.display(14, .semibold)).foregroundStyle(Palette.brassDeep)
                            .frame(width: 34, alignment: .trailing)
                        Text(clue.text(c.suspects, c.rooms))
                            .font(.display(15, .regular))
                            .foregroundStyle(isStruck ? Palette.mutedText.opacity(0.6) : Palette.inkText)
                            .strikethrough(isStruck, color: Palette.oxblood)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 0)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .parchmentCard()
    }

    private var actions: some View {
        HStack(spacing: 12) {
            Button { withAnimation { game.hint() }; Haptics.tap() } label: {
                Label("Footman", systemImage: "lightbulb")
            }
            .buttonStyle(ChipButtonStyle())
            .disabled(game.solved)

            Button("Make the Accusation") {
                if game.accuse() { finish() } else { Haptics.error() }
            }
            .buttonStyle(BrassButtonStyle())
            .disabled(!game.readyToAccuse || game.solved)
        }
    }

    private func markDescription(_ mark: Mark) -> String {
        switch mark {
        case .empty: return "Unmarked"
        case .cross: return "Ruled out"
        case .check: return "Placed"
        }
    }

    private func finish() {
        let score = game.score
        let isRecord = store.record(room: .mystery, score: score, prestigeGain: score / 4)
        Haptics.success()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            result = RoundResult(score: score, isRecord: isRecord,
                                 bestText: Room.mystery.bestText(store.best(for: .mystery)))
        }
    }
}

private struct MarkCell: View {
    let mark: Mark
    let solvedCorrect: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(mark == .check
                      ? AnyShapeStyle(Palette.brassGradient)
                      : AnyShapeStyle(Palette.parchment.opacity(mark == .cross ? 0.55 : 0.9)))
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .strokeBorder(solvedCorrect ? Palette.oxbloodLight : Palette.brassDeep.opacity(0.45),
                              lineWidth: solvedCorrect ? 2 : 1)
            switch mark {
            case .empty: EmptyView()
            case .cross:
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Palette.mutedText.opacity(0.8))
            case .check:
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(Palette.ink)
            }
        }
        .contentShape(Rectangle())
    }
}
