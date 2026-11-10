import SwiftUI

struct EstateView: View {
    @EnvironmentObject private var store: VaultStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var game = SquareEngine()
    @State private var showRules = false
    @State private var result: RoundResult?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: SquareEngine.size)

    var body: some View {
        ZStack {
            ClubBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    HStack(spacing: 10) {
                        StatPill(label: "Estate Value", value: "\(game.score)")
                        StatPill(label: "Plots Left",   value: "\(game.emptyCount)")
                        StatPill(label: "Best",         value: "\(store.best(for: .estate))")
                    }
                    board
                    nextPanel
                }
                .padding(16).padding(.bottom, 20)
            }
            if let result {
                ResultCard(
                    title: "The Square Is Complete",
                    message: verdict(for: result.score),
                    scoreLabel: "Estate Value",
                    result: result,
                    boardKey: .estate,
                    primaryTitle: "Plan a New Square",
                    onPrimary: { withAnimation { self.result = nil }; game.reset() },
                    onExit: { dismiss() }
                )
                .transition(.opacity)
            }
        }
        .roomChrome(title: "Grosvenor Square", boardKey: .estate) { showRules = true }
        .sheet(isPresented: $showRules) {
            RulesSheet(
                title: "The Estate Office",
                intro: "The Duke has entrusted you with a new square. Twenty-five plots, one at a time — place each where it will add most to the estate.",
                rules: [
                    RuleItem(title: "Place every plot",
                             detail: "Tap an empty plot to place the next building. The faint number shows how the estate value would change."),
                    RuleItem(title: Plot.house.name,    detail: Plot.house.rule),
                    RuleItem(title: Plot.garden.name,   detail: Plot.garden.rule),
                    RuleItem(title: Plot.mews.name,     detail: Plot.mews.rule),
                    RuleItem(title: Plot.chapel.name,   detail: Plot.chapel.rule),
                    RuleItem(title: Plot.fountain.name, detail: Plot.fountain.rule),
                    RuleItem(title: Plot.inn.name,      detail: Plot.inn.rule),
                    RuleItem(title: "Two swaps",
                             detail: "Twice per square you may send the next plot back to the surveyor and draw another."),
                ]
            )
        }
        .showRulesOnFirstVisit("estate", isPresented: $showRules)
        .onChange(of: game.isOver) { if game.isOver { finish() } }
    }

    private var board: some View {
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(0..<(SquareEngine.size * SquareEngine.size), id: \.self) { index in
                EstateCell(
                    plot: game.grid[index],
                    points: game.points(at: index),
                    preview: game.grid[index] == nil && !game.isOver
                        ? game.delta(placing: game.current, at: index) : nil,
                    highlighted: game.lastPlaced == index
                )
                .aspectRatio(1, contentMode: .fit)
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                        if game.place(at: index) { Haptics.tap() }
                    }
                }
            }
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(LinearGradient(colors: [Palette.lawn, Color(hex: 0x1A3524)], startPoint: .top, endPoint: .bottom)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
            .strokeBorder(Palette.brass.opacity(0.6), lineWidth: 1.5))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .strokeBorder(Palette.brass.opacity(0.2), lineWidth: 0.75)
            .padding(4).allowsHitTesting(false))
    }

    private var nextPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Surveyor Proposes").eyebrow(onLight: true)
            HStack(alignment: .top, spacing: 14) {
                PlotArt(plot: game.current)
                    .frame(width: 76, height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Palette.brassDeep, lineWidth: 1.5))
                    .id(game.emptyCount)
                    .transition(.scale.combined(with: .opacity))
                VStack(alignment: .leading, spacing: 4) {
                    Text(game.current.name)
                        .font(.display(21)).foregroundStyle(Palette.inkText)
                    Text(game.current.rule)
                        .font(.text(13)).foregroundStyle(Palette.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            Divider().overlay(Palette.brassDeep.opacity(0.3))
            HStack(spacing: 8) {
                Text("Then").font(.display(13,.regular)).italic().foregroundStyle(Palette.mutedText)
                ForEach(Array(game.queue.dropFirst().enumerated()), id: \.offset) { _, plot in
                    PlotArt(plot: plot).frame(width: 34, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                }
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.35)) { game.swap() }
                    Haptics.select()
                } label: {
                    Label("Swap · \(game.swapsLeft)", systemImage: "arrow.triangle.2.circlepath")
                }
                .buttonStyle(ChipButtonStyle(onLight: true))
                .disabled(game.swapsLeft == 0 || game.isOver)
            }
        }
        .parchmentCard()
    }

    private func verdict(for score: Int) -> String {
        switch score {
        case ..<25:    return "A modest beginning. The Duke expects more of his surveyor."
        case 25..<45:  return "A respectable square. The gardens are much admired."
        case 45..<65:  return "A handsome estate — Mayfair society takes note."
        default:       return "Magnificent. Your square will be spoken of for a century."
        }
    }

    private func finish() {
        let score = game.score
        let isRecord = store.record(room: .estate, score: score, prestigeGain: max(0, score) * 3)
        Haptics.success()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            result = RoundResult(score: score, isRecord: isRecord,
                                 bestText: Room.estate.bestText(store.best(for: .estate)))
        }
    }
}

private struct EstateCell: View {
    let plot: Plot?
    let points: Int
    let preview: Int?
    let highlighted: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            if let plot {
                PlotArt(plot: plot)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .transition(.scale(scale: 0.4).combined(with: .opacity))
                Text(points >= 0 ? "+\(points)" : "\(points)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5).padding(.vertical, 2)
                    .background(Capsule().fill(points >= 0 ? Palette.greenMid : Palette.oxblood))
                    .padding(3)
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.black.opacity(0.12))
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .foregroundStyle(Palette.cream.opacity(0.25))
                if let preview {
                    Text(preview >= 0 ? "+\(preview)" : "\(preview)")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                        .foregroundStyle(preview > 0 ? Palette.brassLight.opacity(0.75) : Palette.oxbloodLight.opacity(0.85))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
            .strokeBorder(Palette.brassLight, lineWidth: highlighted ? 2 : 0))
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(plot.map { "\($0.name), \(points) points" } ?? "Empty plot, \(preview ?? 0) if placed")
    }
}

struct PlotArt: View {
    let plot: Plot

    var body: some View {
        Canvas { ctx, size in
            let w = size.width, h = size.height
            func r(_ x: CGFloat, _ y: CGFloat, _ rw: CGFloat, _ rh: CGFloat) -> CGRect {
                CGRect(x: x*w, y: y*h, width: rw*w, height: rh*h)
            }
            func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x*w, y: y*h) }

            switch plot {

            case .house:
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0xEADFC6)))
                ctx.fill(Path(r(0.16, 0.24, 0.68, 0.7)), with: .color(Color(hex: 0xD6C29A)))
                var ped = Path()
                ped.move(to: p(0.1, 0.26)); ped.addLine(to: p(0.5, 0.08)); ped.addLine(to: p(0.9, 0.26))
                ped.closeSubpath()
                ctx.fill(ped, with: .color(Palette.parchmentDark))
                ctx.stroke(ped, with: .color(Palette.inkText.opacity(0.4)), lineWidth: 1)
                for row in 0..<2 { for col in 0..<3 {
                    ctx.fill(Path(r(0.23+CGFloat(col)*0.2, 0.33+CGFloat(row)*0.2, 0.12, 0.14)),
                             with: .color(Palette.green))
                }}
                ctx.fill(Path(r(0.42, 0.74, 0.16, 0.2)), with: .color(Palette.oxblood))
                var fan = Path()
                fan.addArc(center: p(0.5, 0.74), radius: 0.08*w, startAngle: .degrees(180),
                            endAngle: .degrees(0), clockwise: false)
                ctx.fill(fan, with: .color(Palette.brass))

            case .garden:
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0x3E6B4A)))
                ctx.fill(Path(r(0.44, 0, 0.12, 1)), with: .color(Palette.parchment.opacity(0.85)))
                let trees: [(CGFloat,CGFloat,CGFloat)] = [(0.08,0.1,0.3),(0.62,0.16,0.28),(0.1,0.58,0.28),(0.6,0.6,0.32)]
                for (tx,ty,ts) in trees {
                    ctx.fill(Path(ellipseIn: r(tx+0.02, ty+0.03, ts, ts)), with: .color(Color.black.opacity(0.2)))
                    ctx.fill(Path(ellipseIn: r(tx, ty, ts, ts)), with: .color(Color(hex: 0x2C5238)))
                    ctx.fill(Path(ellipseIn: r(tx+ts*0.2, ty+ts*0.15, ts*0.45, ts*0.45)),
                             with: .color(Color(hex: 0x5B8C5F)))
                }
                ctx.fill(Path(ellipseIn: r(0.4, 0.42, 0.2, 0.16)), with: .color(Palette.oxbloodLight.opacity(0.9)))

            case .mews:
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0x7A5A3A)))
                for i in 0..<5 {
                    ctx.fill(Path(r(0, CGFloat(i)*0.2, 1, 0.012)), with: .color(Color.black.opacity(0.18)))
                }
                let door = r(0.2, 0.3, 0.6, 0.6)
                ctx.fill(Path(door), with: .color(Color(hex: 0x5C3F25)))
                var brace = Path()
                brace.move(to: CGPoint(x: door.minX, y: door.minY))
                brace.addLine(to: CGPoint(x: door.maxX, y: door.maxY))
                brace.move(to: CGPoint(x: door.maxX, y: door.minY))
                brace.addLine(to: CGPoint(x: door.minX, y: door.maxY))
                brace.addRect(door)
                brace.move(to: CGPoint(x: door.minX, y: door.midY))
                brace.addLine(to: CGPoint(x: door.maxX, y: door.midY))
                ctx.stroke(brace, with: .color(Palette.cream.opacity(0.85)), lineWidth: max(1.2, w*0.035))
                var shoe = Path()
                shoe.addArc(center: p(0.5, 0.18), radius: 0.09*w,
                             startAngle: .degrees(20), endAngle: .degrees(160), clockwise: true)
                ctx.stroke(shoe, with: .color(Palette.brassLight),
                           style: StrokeStyle(lineWidth: max(1.5, w*0.04), lineCap: .round))

            case .chapel:
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0xA9B2B4)))
                ctx.fill(Path(r(0.26, 0.4, 0.48, 0.55)), with: .color(Color(hex: 0xDCE0DC)))
                var spire = Path()
                spire.move(to: p(0.38, 0.4)); spire.addLine(to: p(0.5, 0.1))
                spire.addLine(to: p(0.62, 0.4)); spire.closeSubpath()
                ctx.fill(spire, with: .color(Color(hex: 0x5D6B6E)))
                var cross = Path()
                cross.move(to: p(0.5, 0.02)); cross.addLine(to: p(0.5, 0.12))
                cross.move(to: p(0.46, 0.05)); cross.addLine(to: p(0.54, 0.05))
                ctx.stroke(cross, with: .color(Palette.brassDeep), lineWidth: max(1, w*0.025))
                var window = Path()
                window.move(to: p(0.42, 0.88)); window.addLine(to: p(0.42, 0.6))
                window.addArc(center: p(0.5, 0.6), radius: 0.08*w,
                               startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                window.addLine(to: p(0.58, 0.88)); window.closeSubpath()
                ctx.fill(window, with: .color(Palette.brass))

            case .fountain:
                // Stone-flagged surround
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0x8E9EA0)))
                // Stone ring
                ctx.fill(Path(ellipseIn: r(0.08, 0.08, 0.84, 0.84)), with: .color(Color(hex: 0xB0BCBE)))
                // Water basin
                ctx.fill(Path(ellipseIn: r(0.18, 0.18, 0.64, 0.64)), with: .color(Color(hex: 0x4A7FA5)))
                ctx.fill(Path(ellipseIn: r(0.23, 0.23, 0.54, 0.54)), with: .color(Color(hex: 0x5B9BC5)))
                // Lily pads
                ctx.fill(Path(ellipseIn: r(0.28, 0.52, 0.18, 0.12)), with: .color(Color(hex: 0x3B7A4E)))
                ctx.fill(Path(ellipseIn: r(0.52, 0.34, 0.16, 0.12)), with: .color(Color(hex: 0x3B7A4E)))
                // Central pedestal
                ctx.fill(Path(ellipseIn: r(0.42, 0.42, 0.16, 0.16)), with: .color(Color(hex: 0xC8CBCC)))
                // Water jet arcs
                var jet1 = Path()
                jet1.move(to: p(0.5, 0.42))
                jet1.addQuadCurve(to: p(0.5, 0.26), control: p(0.6, 0.3))
                ctx.stroke(jet1, with: .color(Color.white.opacity(0.7)),
                           style: StrokeStyle(lineWidth: max(1, w*0.025), lineCap: .round))
                var jet2 = Path()
                jet2.move(to: p(0.5, 0.42))
                jet2.addQuadCurve(to: p(0.5, 0.26), control: p(0.4, 0.3))
                ctx.stroke(jet2, with: .color(Color.white.opacity(0.7)),
                           style: StrokeStyle(lineWidth: max(1, w*0.025), lineCap: .round))

            case .inn:
                // Cream facade
                ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(Color(hex: 0xD8C8A0)))
                // Dark timber frame
                for beam in [r(0, 0, 1, 0.012), r(0, 0.33, 1, 0.012), r(0, 0.66, 1, 0.012),
                             r(0, 0, 0.012, 1), r(0.33, 0, 0.012, 1), r(0.66, 0, 0.012, 1)] {
                    ctx.fill(Path(beam), with: .color(Color(hex: 0x4A3620)))
                }
                // Door (centre bottom)
                ctx.fill(Path(r(0.38, 0.65, 0.24, 0.35)), with: .color(Color(hex: 0x3B2810)))
                var dArc = Path()
                dArc.addArc(center: p(0.5, 0.65), radius: 0.12*w,
                             startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                ctx.fill(dArc, with: .color(Color(hex: 0x3B2810)))
                // Windows
                ctx.fill(Path(r(0.07, 0.38, 0.22, 0.2)), with: .color(Color(hex: 0x9FC3D4)))
                ctx.fill(Path(r(0.71, 0.38, 0.22, 0.2)), with: .color(Color(hex: 0x9FC3D4)))
                // Hanging sign
                var chain = Path()
                chain.move(to: p(0.38, 0.14)); chain.addLine(to: p(0.38, 0.22))
                chain.move(to: p(0.62, 0.14)); chain.addLine(to: p(0.62, 0.22))
                ctx.stroke(chain, with: .color(Color(hex: 0x4A3620)), lineWidth: max(1, w*0.02))
                ctx.fill(Path(r(0.3, 0.22, 0.4, 0.14)), with: .color(Palette.oxblood))
                ctx.stroke(Path(r(0.3, 0.22, 0.4, 0.14)),
                           with: .color(Palette.brassDeep), lineWidth: max(1, w*0.02))
                // Sign lettering (decorative horizontal lines)
                for ly in [0.265, 0.3] {
                    ctx.fill(Path(r(0.35, ly, 0.3, 0.018)), with: .color(Palette.brassLight.opacity(0.85)))
                }
            }
        }
        .accessibilityLabel(plot.name)
    }
}
