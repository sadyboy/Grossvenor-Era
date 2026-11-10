import SwiftUI

struct ShieldShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let h = r.height
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY + h * 0.52))
        p.addQuadCurve(to: CGPoint(x: r.midX, y: r.maxY),
                       control: CGPoint(x: r.maxX, y: r.minY + h * 0.88))
        p.addQuadCurve(to: CGPoint(x: r.minX, y: r.minY + h * 0.52),
                       control: CGPoint(x: r.minX, y: r.minY + h * 0.88))
        p.closeSubpath()
        return p
    }
}

struct RibbonShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let tail = r.height * 0.9
        let fork = r.height * 0.32
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.minX + tail, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX - tail, y: r.minY),
                       control: CGPoint(x: r.midX, y: r.minY + r.height * 0.45))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX - fork, y: r.midY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.maxX - tail, y: r.maxY))
        p.addQuadCurve(to: CGPoint(x: r.minX + tail, y: r.maxY),
                       control: CGPoint(x: r.midX, y: r.maxY + r.height * 0.45))
        p.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX + fork, y: r.midY))
        p.closeSubpath()
        return p
    }
}

struct Diamond: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.midY))
        p.closeSubpath()
        return p
    }
}

struct ArchShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        let radius = r.width / 2
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.minY + radius))
        p.addArc(center: CGPoint(x: r.midX, y: r.minY + radius), radius: radius,
                 startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}

struct ArchWindow<Content: View>: View {
    var fill: Color = Palette.greenMid
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            ArchShape().fill(LinearGradient(colors: [fill, Palette.ink], startPoint: .top, endPoint: .bottom))
            content.padding(10)
        }
        .clipShape(ArchShape())
        .overlay(ArchShape().stroke(Palette.brass, lineWidth: 1.5))
        .overlay(ArchShape().stroke(Palette.brass.opacity(0.35), lineWidth: 0.75).padding(5))
    }
}
