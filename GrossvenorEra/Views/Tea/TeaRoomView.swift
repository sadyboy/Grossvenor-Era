import SwiftUI

struct TeaRoomView: View {
    @EnvironmentObject private var store: VaultStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var game = TeaGame(level: UserDefaults.standard.integer(forKey: "teaLevel"))
    @State private var showRules = false
    @State private var result: RoundResult?

    private let columns = [GridItem(.adaptive(minimum: 60, maximum: 76), spacing: 10)]

    var body: some View {
        ZStack {
            ClubBackground()
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    StatPill(label: "Sitting", value: romanNumeral(game.level))
                    StatPill(label: "Blends",  value: "\(game.blendCount)")
                    StatPill(label: "Pours",   value: "\(game.moves)")
                }
                Spacer(minLength: 0)
                LazyVGrid(columns: columns, spacing: 30) {
                    ForEach(Array(game.cups.enumerated()), id: \.element.id) { index, cup in
                        CupView(cup: cup, selected: game.selected == index, complete: game.isComplete(cup))
                            .frame(height: 128)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { game.tap(index) }
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel(accessibility(for: cup, index: index))
                            .accessibilityAddTraits(.isButton)
                    }
                }
                .padding(.horizontal, 6).padding(.vertical, 26)
                .background(tablecloth)
                Spacer(minLength: 0)
                legend
                HStack(spacing: 12) {
                    Button {
                        withAnimation(.spring(response: 0.3)) { game.undo() }
                    } label: { Label("Undo", systemImage: "arrow.uturn.backward") }
                    .buttonStyle(ChipButtonStyle()).disabled(!game.canUndo)

                    Button {
                        withAnimation(.easeInOut) { game.newPuzzle() }
                        Haptics.select()
                    } label: { Label("Fresh Pot", systemImage: "arrow.clockwise") }
                    .buttonStyle(ChipButtonStyle())
                    Spacer()
                }
            }
            .padding(16)
            if let result {
                ResultCard(
                    title: "Tea Is Served",
                    message: "Every blend rests in a cup of its own. The Duchess is delighted.",
                    scoreLabel: "Sitting Score",
                    result: result,
                    boardKey: .tea,
                    primaryTitle: "The Next Sitting",
                    onPrimary: { withAnimation { self.result = nil }; game.advance() },
                    onExit: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .roomChrome(title: "The Tea Room", boardKey: .tea, onDismiss: { dismiss() }) { showRules = true }
        .sheet(isPresented: $showRules) {
            RulesSheet(
                title: "Afternoon Tea",
                intro: "The footman has muddled the blends. Pour until every cup holds a single tea — four measures of it.",
                rules: [
                    RuleItem(title: "Choose a cup",        detail: "Tap a cup to lift it, then tap another to pour."),
                    RuleItem(title: "Like onto like",       detail: "Tea may only be poured onto the same blend, or into an empty cup."),
                    RuleItem(title: "Pour generously",      detail: "All matching measures on top are poured at once, as far as the cup allows."),
                    RuleItem(title: "Each sitting is harder",detail: "New blends join the table as you progress. Fewer pours earn a finer score."),
                    RuleItem(title: "Undo and fresh pots",  detail: "Undo costs one pour. A fresh pot deals a new table at the same sitting."),
                ]
            )
        }
        .showRulesOnFirstVisit("tea", isPresented: $showRules)
        .onAppear { game.syncLevel() }
        .onChange(of: game.solved) { if game.solved { finish() } }
    }

    private var tablecloth: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(LinearGradient(colors: [Palette.oxblood.opacity(0.55), Palette.oxblood.opacity(0.3)],
                                 startPoint: .top, endPoint: .bottom))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Palette.brass.opacity(0.5), lineWidth: 1))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Palette.cream.opacity(0.15),
                              style: StrokeStyle(lineWidth: 1, dash: [2, 4])).padding(5))
    }

    private var legend: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 8)], alignment: .leading, spacing: 8) {
            ForEach(game.blendsInPlay, id: \.self) { blend in
                HStack(spacing: 6) {
                    Circle().fill(blend.color).frame(width: 10, height: 10)
                    Text(blend.name)
                        .font(.display(12, .regular)).italic()
                        .foregroundStyle(Palette.cream.opacity(0.8)).lineLimit(1)
                }
            }
        }
    }

    private func accessibility(for cup: Cup, index: Int) -> String {
        if cup.layers.isEmpty { return "Cup \(index + 1), empty" }
        return "Cup \(index + 1), from the top: \(cup.layers.reversed().map(\.name).joined(separator: ", "))"
    }

    private func finish() {
        let score = game.levelScore
        let isRecord = store.record(room: .tea, score: score, prestigeGain: score / 4, boardValue: game.level)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.35)) {
            result = RoundResult(score: score, isRecord: isRecord,
                                 bestText: Room.tea.bestText(store.best(for: .tea)))
        }
    }
}

struct TeaGlassShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let inset = r.width * 0.1, curve = r.width * 0.22
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - inset, y: r.maxY - curve))
        p.addQuadCurve(to: CGPoint(x: r.maxX - inset - curve, y: r.maxY),
                       control: CGPoint(x: r.maxX - inset, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX + inset + curve, y: r.maxY))
        p.addQuadCurve(to: CGPoint(x: r.minX + inset, y: r.maxY - curve),
                       control: CGPoint(x: r.minX + inset, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

struct CupView: View {
    let cup: Cup
    let selected: Bool
    let complete: Bool

    var body: some View {
        GeometryReader { geo in
            let w = min(geo.size.width * 0.74, 56)
            let h = geo.size.height
            let layerHeight = h * 0.86 / CGFloat(TeaGame.capacity)
            ZStack {
                RoundedRectangle(cornerRadius: w * 0.16)
                    .stroke(Palette.cream.opacity(0.7), lineWidth: 4)
                    .frame(width: w*0.34, height: h*0.32)
                    .offset(x: w*0.56, y: -h*0.06)
                ZStack {
                    TeaGlassShape().fill(Color.white.opacity(0.06))
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        ForEach(Array(cup.layers.indices.reversed()), id: \.self) { i in
                            let blend = cup.layers[i]
                            Rectangle()
                                .fill(LinearGradient(colors: [blend.color.opacity(0.82), blend.color],
                                                     startPoint: .top, endPoint: .bottom))
                                .overlay(alignment: .top) {
                                    Rectangle().fill(Color.white.opacity(0.12)).frame(height: 1)
                                }
                                .frame(height: layerHeight)
                        }
                    }
                    .frame(width: w, height: h).clipShape(TeaGlassShape())
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.white.opacity(0.22))
                        .frame(width: 3, height: h*0.55)
                        .offset(x: -w*0.3, y: -h*0.08)
                    TeaGlassShape()
                        .stroke(complete ? Palette.brassLight : Palette.cream.opacity(0.75),
                                lineWidth: complete ? 2.5 : 1.6)
                    Capsule().fill(Palette.brassGradient)
                        .frame(width: w+6, height: 5).offset(y: -h/2)
                }
                .frame(width: w, height: h)
                if complete {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16)).foregroundStyle(Palette.brassLight)
                        .offset(y: h/2 + 12).transition(.scale)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .offset(y: selected ? -16 : 0)
            .shadow(color: selected ? Palette.brass.opacity(0.6) : .black.opacity(0.35),
                    radius: selected ? 12 : 5, y: selected ? 0 : 4)
        }
    }
}
