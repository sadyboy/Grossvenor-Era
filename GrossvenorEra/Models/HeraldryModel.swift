import SwiftUI

enum Tincture: String, CaseIterable, Codable, Identifiable {
    case or, argent, gules, azure, vert, sable, purpure

    var id: String   { rawValue }
    var name: String { rawValue.capitalized }
    var isMetal: Bool { self == .or || self == .argent }

    var color: Color {
        switch self {
        case .or:      Color(hex: 0xD4A72C)
        case .argent:  Color(hex: 0xEDEBE3)
        case .gules:   Color(hex: 0xB3242B)
        case .azure:   Color(hex: 0x2457A6)
        case .vert:    Color(hex: 0x2E7D4A)
        case .sable:   Color(hex: 0x1C1C1C)
        case .purpure: Color(hex: 0x6B3A7D)
        }
    }

    var plain: String {
        switch self {
        case .or:      "Gold"
        case .argent:  "Silver"
        case .gules:   "Red"
        case .azure:   "Blue"
        case .vert:    "Green"
        case .sable:   "Black"
        case .purpure: "Purple"
        }
    }
}

enum Division: String, CaseIterable, Codable, Identifiable {
    case plain, perPale, perFess, perBend, quarterly

    var id: String { rawValue }

    var name: String {
        switch self {
        case .plain:    "Plain"
        case .perPale:  "Per Pale"
        case .perFess:  "Per Fess"
        case .perBend:  "Per Bend"
        case .quarterly:"Quarterly"
        }
    }

    var blazonName: String {
        switch self {
        case .plain:    ""
        case .perPale:  "Per pale"
        case .perFess:  "Per fess"
        case .perBend:  "Per bend"
        case .quarterly:"Quarterly"
        }
    }

    var explanation: String {
        switch self {
        case .plain:    "A field of a single tincture."
        case .perPale:  "Divided down the middle."
        case .perFess:  "Divided across the middle."
        case .perBend:  "Divided diagonally from the upper left."
        case .quarterly:"Divided into four quarters."
        }
    }
}

enum Ordinary: String, CaseIterable, Codable, Identifiable {
    case absent, pale, fess, bend, chevron, cross, saltire, chief

    var id: String   { rawValue }
    var name: String { self == .absent ? "None" : rawValue.capitalized }

    var explanation: String {
        switch self {
        case .absent:  "No ordinary."
        case .pale:    "A broad vertical band."
        case .fess:    "A broad horizontal band."
        case .bend:    "A diagonal band from the upper left."
        case .chevron: "An inverted V, like a gable."
        case .cross:   "A pale and a fess together."
        case .saltire: "A diagonal cross, like an X."
        case .chief:   "The top third of the shield."
        }
    }
}

enum Charge: String, CaseIterable, Codable, Identifiable {
    case absent, mullet, roundel, lozenge, crescent

    var id: String   { rawValue }
    var name: String { self == .absent ? "None" : rawValue.capitalized }
}

struct Arms: Codable, Equatable {
    var division:          Division  = .plain
    var field:             Tincture  = .azure
    var field2:            Tincture  = .or
    var ordinary:          Ordinary  = .absent
    var ordinaryTincture:  Tincture  = .or
    var charge:            Charge    = .absent
    var chargeTincture:    Tincture  = .argent

    var blazon: String {
        var text = division == .plain
            ? field.name
            : "\(division.blazonName) \(field.name) and \(field2.name)"
        if ordinary != .absent {
            text += ", a \(ordinary.rawValue) \(ordinaryTincture.name)"
        }
        if charge != .absent {
            text += ordinary == .absent
                ? ", a \(charge.rawValue) \(chargeTincture.name)"
                : ", overall a \(charge.rawValue) \(chargeTincture.name)"
        }
        return text
    }

    var followsRuleOfTincture: Bool {
        if division == .plain && ordinary != .absent && field.isMetal == ordinaryTincture.isMetal { return false }
        if division != .plain && field.isMetal == field2.isMetal { return false }
        if charge != .absent && division == .plain && ordinary == .absent && field.isMetal == chargeTincture.isMetal { return false }
        return true
    }

    static let club   = Arms(field: .vert, ordinary: .chevron, ordinaryTincture: .or)
    static let sample = Arms(field: .azure, ordinary: .bend, ordinaryTincture: .or)
}

enum HeraldryGenerator {
    static let metals:  [Tincture] = [.or, .argent]
    static let colours: [Tincture] = [.gules, .azure, .vert, .sable, .purpure]

    static func randomArms() -> Arms {
        var a = Arms()
        if Double.random(in: 0...1) < 0.6 {
            let fieldIsMetal = Double.random(in: 0...1) < 0.35
            a.field           = (fieldIsMetal ? metals : colours).randomElement() ?? .azure
            a.ordinary        = Ordinary.allCases.filter { $0 != .absent }.randomElement() ?? .bend
            a.ordinaryTincture = (fieldIsMetal ? colours : metals).randomElement() ?? .or
        } else {
            a.division = Division.allCases.filter { $0 != .plain }.randomElement() ?? .perPale
            let metal  = metals.randomElement()  ?? .or
            let colour = colours.randomElement() ?? .gules
            if Bool.random() { a.field = metal;  a.field2 = colour }
            else              { a.field = colour; a.field2 = metal  }
        }
        return a
    }

    static func randomStudioArms() -> Arms {
        var a = randomArms()
        if Bool.random() {
            a.charge = Charge.allCases.filter { $0 != .absent }.randomElement() ?? .mullet
            let ground = a.ordinary == .absent
                ? a.field
                : (a.ordinary == .chevron || a.ordinary == .chief ? a.field : a.ordinaryTincture)
            a.chargeTincture = (ground.isMetal ? colours : metals).randomElement() ?? .argent
        }
        return a
    }

    static func question() -> (arms: Arms, options: [String]) {
        let a = randomArms()
        var options: Set<String> = [a.blazon]
        var tries = 0
        while options.count < 4 && tries < 80 { options.insert(variant(of: a).blazon); tries += 1 }
        while options.count < 4 { options.insert(randomArms().blazon) }
        return (a, Array(options).shuffled())
    }

    private static func variant(of a: Arms) -> Arms {
        var v = a
        if a.division == .plain {
            switch Int.random(in: 0..<3) {
            case 0:
                v.ordinary = Ordinary.allCases.filter { $0 != .absent && $0 != a.ordinary }.randomElement() ?? .pale
            case 1:
                v.ordinaryTincture = (a.ordinaryTincture.isMetal ? metals : colours)
                    .filter { $0 != a.ordinaryTincture }.randomElement() ?? a.ordinaryTincture
            default:
                v.field = (a.field.isMetal ? metals : colours)
                    .filter { $0 != a.field }.randomElement() ?? a.field
            }
        } else {
            switch Int.random(in: 0..<3) {
            case 0:
                v.division = Division.allCases.filter { $0 != .plain && $0 != a.division }.randomElement() ?? .perFess
            case 1:
                let first = v.field; v.field = v.field2; v.field2 = first
            default:
                if a.field.isMetal {
                    v.field2 = colours.filter { $0 != a.field2 }.randomElement() ?? a.field2
                } else {
                    v.field = colours.filter { $0 != a.field }.randomElement() ?? a.field
                }
            }
        }
        return v
    }
}

enum ArmsPainter {
    static func paint(_ a: Arms, in ctx: GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let full = Path(CGRect(origin: .zero, size: size))
        ctx.fill(full, with: .color(a.field.color))

        let second = GraphicsContext.Shading.color(a.field2.color)
        switch a.division {
        case .plain: break
        case .perPale:
            ctx.fill(Path(CGRect(x: w/2, y: 0, width: w/2, height: h)), with: second)
        case .perFess:
            ctx.fill(Path(CGRect(x: 0, y: h*0.45, width: w, height: h*0.55)), with: second)
        case .perBend:
            var p = Path()
            p.move(to: .zero)
            p.addLine(to: CGPoint(x: w, y: h))
            p.addLine(to: CGPoint(x: 0, y: h))
            p.closeSubpath()
            ctx.fill(p, with: second)
        case .quarterly:
            ctx.fill(Path(CGRect(x: w/2, y: 0,       width: w/2, height: h*0.45)), with: second)
            ctx.fill(Path(CGRect(x: 0,   y: h*0.45,  width: w/2, height: h*0.55)), with: second)
        }

        let shade = GraphicsContext.Shading.color(a.ordinaryTincture.color)
        let t = w * 0.22
        switch a.ordinary {
        case .absent: break
        case .pale:
            ctx.fill(Path(CGRect(x: (w-t)/2, y: 0, width: t, height: h)), with: shade)
        case .fess:
            ctx.fill(Path(CGRect(x: 0, y: h*0.42-t/2, width: w, height: t)), with: shade)
        case .chief:
            ctx.fill(Path(CGRect(x: 0, y: 0, width: w, height: h*0.28)), with: shade)
        case .bend:
            ctx.fill(band(from: .zero, to: CGPoint(x: w, y: h), thickness: t), with: shade)
        case .saltire:
            ctx.fill(band(from: .zero,           to: CGPoint(x: w, y: h), thickness: t*0.8), with: shade)
            ctx.fill(band(from: CGPoint(x:w,y:0), to: CGPoint(x: 0, y: h), thickness: t*0.8), with: shade)
        case .cross:
            let ct = t * 0.85
            ctx.fill(Path(CGRect(x: (w-ct)/2, y: 0,          width: ct, height: h)), with: shade)
            ctx.fill(Path(CGRect(x: 0,        y: h*0.42-ct/2, width: w, height: ct)), with: shade)
        case .chevron:
            var p = Path()
            p.move(to: CGPoint(x: 0,   y: h*0.72))
            p.addLine(to: CGPoint(x: w/2, y: h*0.3))
            p.addLine(to: CGPoint(x: w,   y: h*0.72))
            p.addLine(to: CGPoint(x: w,   y: h*0.72+t))
            p.addLine(to: CGPoint(x: w/2, y: h*0.3+t))
            p.addLine(to: CGPoint(x: 0,   y: h*0.72+t))
            p.closeSubpath()
            ctx.fill(p, with: shade)
        }

        if a.charge != .absent {
            var center = CGPoint(x: w/2, y: h*0.44)
            var radius = w * 0.17
            switch a.ordinary {
            case .chief:   center.y = h * 0.6
            case .chevron: center.y = h * 0.8; radius = w * 0.11
            default: break
            }
            drawCharge(a.charge, color: a.chargeTincture.color, center: center, radius: radius, in: ctx)
        }

        ctx.fill(full, with: .linearGradient(
            Gradient(colors: [Color.white.opacity(0.22), Color.clear, Color.black.opacity(0.22)]),
            startPoint: .zero, endPoint: CGPoint(x: w, y: h)
        ))
    }

    static func drawCharge(_ charge: Charge, color: Color, center: CGPoint, radius r: CGFloat, in ctx: GraphicsContext) {
        let shade = GraphicsContext.Shading.color(color)
        switch charge {
        case .absent: break
        case .mullet:
            ctx.fill(star(center: center, radius: r), with: shade)
        case .roundel:
            ctx.fill(Path(ellipseIn: CGRect(x: center.x-r, y: center.y-r, width: 2*r, height: 2*r)), with: shade)
        case .lozenge:
            var p = Path()
            p.move(to: CGPoint(x: center.x,         y: center.y-r*1.25))
            p.addLine(to: CGPoint(x: center.x+r*0.8, y: center.y))
            p.addLine(to: CGPoint(x: center.x,       y: center.y+r*1.25))
            p.addLine(to: CGPoint(x: center.x-r*0.8, y: center.y))
            p.closeSubpath()
            ctx.fill(p, with: shade)
        case .crescent:
            var g = ctx
            g.clip(to: Path(ellipseIn: CGRect(x: center.x-r*0.82, y: center.y-r*1.3, width: r*1.64, height: r*1.64)), options: .inverse)
            g.fill(Path(ellipseIn: CGRect(x: center.x-r, y: center.y-r, width: 2*r, height: 2*r)), with: shade)
        }
    }

    static func band(from a: CGPoint, to b: CGPoint, thickness t: CGFloat) -> Path {
        let dx = b.x - a.x, dy = b.y - a.y
        let len = max(0.001, sqrt(dx*dx + dy*dy))
        let nx = -dy/len * t/2, ny = dx/len * t/2
        let ex =  dx/len * t,   ey = dy/len * t
        let s = CGPoint(x: a.x-ex, y: a.y-ey)
        let e = CGPoint(x: b.x+ex, y: b.y+ey)
        var p = Path()
        p.move(to:    CGPoint(x: s.x+nx, y: s.y+ny))
        p.addLine(to: CGPoint(x: e.x+nx, y: e.y+ny))
        p.addLine(to: CGPoint(x: e.x-nx, y: e.y-ny))
        p.addLine(to: CGPoint(x: s.x-nx, y: s.y-ny))
        p.closeSubpath()
        return p
    }

    static func star(center: CGPoint, radius r: CGFloat) -> Path {
        var p = Path()
        for i in 0..<10 {
            let angle = -CGFloat.pi/2 + CGFloat(i) * .pi/5
            let rr = i.isMultiple(of: 2) ? r : r * 0.42
            let pt = CGPoint(x: center.x + cos(angle)*rr, y: center.y + sin(angle)*rr)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}
