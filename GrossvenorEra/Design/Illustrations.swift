import SwiftUI

struct LaurelWreath: View {
    var color: Color = Palette.brass

    var body: some View {
        Canvas { ctx, size in
            let c = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius     = min(size.width, size.height) * 0.44
            let leafLength = radius * 0.27
            let leafWidth  = radius * 0.11
            for side in [-1.0, 1.0] {
                var stem = Path()
                for k in 0...40 {
                    let t = Double(k) / 40
                    let theta = side < 0 ? (100 + 140 * t) : (80 - 140 * t)
                    let rad = theta * .pi / 180
                    let pt = CGPoint(x: c.x + radius * CGFloat(cos(rad)),
                                     y: c.y + radius * CGFloat(sin(rad)))
                    if k == 0 { stem.move(to: pt) } else { stem.addLine(to: pt) }
                }
                ctx.stroke(stem, with: .color(color),
                           style: StrokeStyle(lineWidth: max(1, radius * 0.025), lineCap: .round))
                for k in 0..<9 {
                    let t = Double(k) / 8
                    let theta = side < 0 ? (106 + 128 * t) : (74 - 128 * t)
                    let rad   = theta * .pi / 180
                    let base  = CGPoint(x: c.x + radius * CGFloat(cos(rad)),
                                        y: c.y + radius * CGFloat(sin(rad)))
                    let tangent = side < 0 ? rad + .pi/2 : rad - .pi/2
                    for outward in [-1.0, 1.0] {
                        var g = ctx
                        let offset = radius * 0.05 * CGFloat(outward)
                        g.translateBy(x: base.x + CGFloat(cos(rad)) * offset,
                                      y: base.y + CGFloat(sin(rad)) * offset)
                        let tilt  = outward * 0.5 * (side < 0 ? -1 : 1)
                        g.rotate(by: .radians(tangent + tilt))
                        let scale = CGFloat(0.75 + 0.25 * (1 - t))
                        let leaf  = Path(ellipseIn: CGRect(x: 0, y: -leafWidth*scale/2,
                                                            width: leafLength*scale, height: leafWidth*scale))
                        g.fill(leaf, with: .color(color))
                    }
                }
            }
            let tie = Path(ellipseIn: CGRect(x: c.x - radius*0.07, y: c.y + radius*0.93,
                                              width: radius*0.14, height: radius*0.1))
            ctx.fill(tie, with: .color(color))
        }
        .accessibilityHidden(true)
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

struct TownhouseSkyline: View {
    var seed: UInt64 = 7
    var litChance: Double = 0.35

    var body: some View {
        Canvas { ctx, size in
            var rng = SeededRandom(seed: seed)
            let H  = size.height
            let bay = max(10, H * 0.105)
            var x: CGFloat = -bay * 0.5
            while x < size.width {
                let bays  = Int.random(in: 3...4, using: &rng)
                let width = CGFloat(bays) * bay + bay * 0.5
                let height = H * CGFloat(Double.random(in: 0.68...0.9, using: &rng))
                let top  = H - height
                let tone = Bool.random(using: &rng) ? Color(hex: 0x0C0C1E) : Color(hex: 0x10101F)
                let chimneys = Int.random(in: 1...2, using: &rng)
                for c in 0..<chimneys {
                    let cx = x + width * (c == 0 ? 0.16 : 0.7)
                    ctx.fill(Path(CGRect(x: cx, y: top - bay*0.9, width: bay*0.6, height: bay*0.95)), with: .color(tone))
                    for pot in 0..<2 {
                        ctx.fill(Path(CGRect(x: cx + bay*0.08 + CGFloat(pot)*bay*0.26,
                                             y: top - bay*1.15, width: bay*0.16, height: bay*0.28)),
                                 with: .color(tone))
                    }
                }
                ctx.fill(Path(CGRect(x: x, y: top, width: width, height: height)), with: .color(tone))
                ctx.fill(Path(CGRect(x: x-1, y: top - bay*0.12, width: width+2, height: bay*0.12)),
                         with: .color(Palette.brass.opacity(0.16)))
                ctx.fill(Path(CGRect(x: x, y: top + bay*0.55, width: width, height: 1.2)),
                         with: .color(Palette.brass.opacity(0.12)))
                let floorH = (height - bay*0.6) / 4
                let doorBay = Int.random(in: 0..<bays, using: &rng)
                for f in 0..<4 {
                    let fy = top + bay*0.6 + CGFloat(f) * floorH
                    for b in 0..<bays {
                        let bx = x + bay*0.25 + CGFloat(b) * bay
                        if f == 3 && b == doorBay {
                            let dw = bay*0.52, dh = floorH*0.8
                            let dx = bx + (bay - dw)/2, dy = fy + floorH - dh
                            ctx.fill(Path(CGRect(x: dx, y: dy+dw/2, width: dw, height: dh-dw/2)),
                                     with: .color(Palette.oxblood))
                            var fan = Path()
                            fan.addArc(center: CGPoint(x: dx+dw/2, y: dy+dw/2), radius: dw/2,
                                       startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                            fan.closeSubpath()
                            ctx.fill(fan, with: .color(Palette.brassLight.opacity(0.85)))
                            continue
                        }
                        let ww = bay*0.46
                        let wh: CGFloat = f==0 ? floorH*0.42 : (f==1 ? floorH*0.72 : floorH*0.58)
                        let rect = CGRect(x: bx+(bay-ww)/2, y: fy+(floorH-wh)/2, width: ww, height: wh)
                        if Double.random(in: 0...1, using: &rng) < litChance {
                            ctx.fill(Path(roundedRect: rect.insetBy(dx: -ww*0.4, dy: -ww*0.4),
                                         cornerRadius: ww*0.4), with: .color(Palette.brassLight.opacity(0.07)))
                            ctx.fill(Path(rect), with: .color(Palette.brassLight.opacity(0.92)))
                        } else {
                            ctx.fill(Path(rect), with: .color(Color(hex: 0x16162A)))
                        }
                        var bars = Path()
                        bars.move(to: CGPoint(x: rect.midX, y: rect.minY))
                        bars.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
                        bars.move(to: CGPoint(x: rect.minX, y: rect.midY))
                        bars.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                        ctx.stroke(bars, with: .color(tone), lineWidth: 0.8)
                        if f == 1 {
                            ctx.fill(Path(CGRect(x: rect.minX-2, y: rect.maxY, width: ww+4, height: 1.6)),
                                     with: .color(Palette.brass.opacity(0.35)))
                        }
                    }
                }
                ctx.fill(Path(CGRect(x: x+width-0.8, y: top, width: 0.8, height: height)),
                         with: .color(Color.black.opacity(0.4)))
                x += width
            }
            var rail = Path(); var rx: CGFloat = 0
            while rx < size.width {
                rail.move(to: CGPoint(x: rx, y: H))
                rail.addLine(to: CGPoint(x: rx, y: H - bay*0.45))
                rx += bay * 0.18
            }
            rail.move(to: CGPoint(x: 0, y: H - bay*0.38))
            rail.addLine(to: CGPoint(x: size.width, y: H - bay*0.38))
            ctx.stroke(rail, with: .color(Color.black.opacity(0.55)), lineWidth: 1)
        }
        .accessibilityHidden(true)
    }
}

struct StarField: View {
    var seed: UInt64 = 3
    var showMoon = true

    var body: some View {
        Canvas { ctx, size in
            var rng = SeededRandom(seed: seed)
            for _ in 0..<70 {
                let x = CGFloat.random(in: 0...size.width,  using: &rng)
                let y = CGFloat.random(in: 0...(size.height * 0.7), using: &rng)
                let r = CGFloat.random(in: 0.5...1.6, using: &rng)
                let o = Double.random(in: 0.25...0.85, using: &rng)
                ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                         with: .color(Palette.cream.opacity(o)))
            }
            if showMoon {
                let m = CGRect(x: size.width*0.76, y: size.height*0.1, width: 34, height: 34)
                ctx.fill(Path(ellipseIn: m.insetBy(dx: -18, dy: -18)),
                         with: .color(Palette.brassLight.opacity(0.06)))
                var g = ctx
                g.clip(to: Path(ellipseIn: m.offsetBy(dx: 10, dy: -6)), options: .inverse)
                g.fill(Path(ellipseIn: m), with: .color(Palette.brassLight.opacity(0.9)))
            }
        }
        .accessibilityHidden(true)
    }
}

private struct UnitSpace {
    let s: CGFloat; let ox: CGFloat; let oy: CGFloat
    init(_ size: CGSize) {
        s = min(size.width, size.height)
        ox = (size.width - s) / 2; oy = (size.height - s) / 2
    }
    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: ox + x*s, y: oy + y*s) }
    func r(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) -> CGRect {
        CGRect(x: ox + x*s, y: oy + y*s, width: w*s, height: h*s)
    }
}

struct TeacupArt: View {
    var teaColor: Color = Color(hex: 0x9A5A22)

    var body: some View {
        Canvas { ctx, size in
            let u = UnitSpace(size), s = u.s
            ctx.fill(Path(ellipseIn: u.r(0.08,0.72,0.84,0.16)), with: .color(Palette.cream))
            ctx.stroke(Path(ellipseIn: u.r(0.08,0.72,0.84,0.16)), with: .color(Palette.brass), lineWidth: s*0.012)
            ctx.fill(Path(ellipseIn: u.r(0.26,0.75,0.48,0.08)), with: .color(Palette.parchmentDark))
            ctx.stroke(Path(ellipseIn: u.r(0.66,0.45,0.2,0.19)), with: .color(Palette.cream), lineWidth: s*0.045)
            var cup = Path()
            cup.move(to: u.p(0.22,0.4)); cup.addLine(to: u.p(0.78,0.4))
            cup.addQuadCurve(to: u.p(0.6,0.8), control: u.p(0.78,0.72))
            cup.addLine(to: u.p(0.4,0.8))
            cup.addQuadCurve(to: u.p(0.22,0.4), control: u.p(0.22,0.72))
            ctx.fill(cup, with: .linearGradient(Gradient(colors: [Palette.cream, Palette.parchmentDark]),
                                                 startPoint: u.p(0.3,0.4), endPoint: u.p(0.75,0.8)))
            var band = Path()
            band.move(to: u.p(0.235,0.5))
            band.addQuadCurve(to: u.p(0.765,0.5), control: u.p(0.5,0.57))
            ctx.stroke(band, with: .color(Palette.brass), lineWidth: s*0.02)
            ctx.fill(Path(ellipseIn: u.r(0.22,0.36,0.56,0.08)), with: .color(Palette.cream))
            ctx.fill(Path(ellipseIn: u.r(0.25,0.374,0.5,0.055)), with: .color(teaColor))
            ctx.fill(Path(ellipseIn: u.r(0.46,0.6,0.08,0.08)), with: .color(Palette.oxblood))
            let xs: [CGFloat] = [0.38,0.5,0.62]
            for (i,x) in xs.enumerated() {
                let d: CGFloat = i.isMultiple(of: 2) ? 0.06 : -0.06
                var steam = Path()
                steam.move(to: u.p(x,0.32))
                steam.addQuadCurve(to: u.p(x,0.2), control: u.p(x+d,0.26))
                steam.addQuadCurve(to: u.p(x,0.08), control: u.p(x-d,0.14))
                ctx.stroke(steam, with: .color(Palette.brassLight.opacity(0.55)),
                           style: StrokeStyle(lineWidth: s*0.018, lineCap: .round))
            }
        }
        .accessibilityHidden(true)
    }
}

struct MagnifierArt: View {
    var body: some View {
        Canvas { ctx, size in
            let u = UnitSpace(size), s = u.s
            var paper = ctx
            let c = u.p(0.5,0.52)
            paper.translateBy(x: c.x, y: c.y); paper.rotate(by: .degrees(-8))
            paper.fill(Path(roundedRect: CGRect(x: -0.32*s, y: -0.38*s, width: 0.64*s, height: 0.76*s),
                            cornerRadius: s*0.02), with: .color(Palette.parchment))
            for i in 0..<7 {
                let w: CGFloat = i%3==2 ? 0.28 : 0.48
                paper.fill(Path(CGRect(x: -0.24*s, y: -0.28*s+CGFloat(i)*0.085*s, width: w*s, height: 0.014*s)),
                           with: .color(Palette.mutedText.opacity(0.45)))
            }
            paper.fill(Path(ellipseIn: CGRect(x: 0.14*s, y: 0.2*s, width: 0.1*s, height: 0.1*s)),
                       with: .color(Palette.oxblood.opacity(0.8)))
            var handle = ctx
            let h = u.p(0.6,0.6)
            handle.translateBy(x: h.x, y: h.y); handle.rotate(by: .degrees(45))
            handle.fill(Path(roundedRect: CGRect(x: 0, y: -0.045*s, width: 0.36*s, height: 0.09*s),
                             cornerRadius: 0.04*s), with: .color(Palette.oxblood))
            handle.fill(Path(CGRect(x: 0, y: -0.055*s, width: 0.07*s, height: 0.11*s)),
                        with: .color(Palette.brass))
            let lens = u.r(0.16,0.16,0.46,0.46)
            ctx.fill(Path(ellipseIn: lens), with: .color(Palette.greenLight.opacity(0.45)))
            ctx.stroke(Path(ellipseIn: lens), with: .color(Palette.brass), lineWidth: s*0.05)
            var glint = Path()
            glint.addArc(center: u.p(0.39,0.39), radius: 0.15*s,
                         startAngle: .degrees(200), endAngle: .degrees(250), clockwise: false)
            ctx.stroke(glint, with: .color(Color.white.opacity(0.65)),
                       style: StrokeStyle(lineWidth: s*0.025, lineCap: .round))
        }
        .accessibilityHidden(true)
    }
}

struct EstatePlanArt: View {
    var body: some View {
        Canvas { ctx, size in
            let u = UnitSpace(size), s = u.s
            ctx.fill(Path(roundedRect: u.r(0.06,0.06,0.88,0.88), cornerRadius: s*0.05),
                     with: .color(Palette.parchment))
            let block = Palette.greenMid
            for i in 0..<5 {
                let x = 0.12 + CGFloat(i) * 0.155
                ctx.fill(Path(roundedRect: u.r(x,0.12,0.13,0.13), cornerRadius: s*0.012), with: .color(block))
                ctx.fill(Path(roundedRect: u.r(x,0.75,0.13,0.13), cornerRadius: s*0.012), with: .color(block))
            }
            for j in 0..<2 {
                let y = 0.33 + CGFloat(j) * 0.2
                ctx.fill(Path(roundedRect: u.r(0.12,y,0.13,0.14), cornerRadius: s*0.012),
                         with: .color(Palette.oxblood.opacity(0.85)))
                ctx.fill(Path(roundedRect: u.r(0.75,y,0.13,0.14), cornerRadius: s*0.012),
                         with: .color(Palette.oxblood.opacity(0.85)))
            }
            ctx.fill(Path(roundedRect: u.r(0.31,0.31,0.38,0.38), cornerRadius: s*0.03),
                     with: .color(Color(hex: 0x4E7D52)))
            ctx.fill(Path(u.r(0.48,0.31,0.04,0.38)), with: .color(Palette.cream.opacity(0.85)))
            ctx.fill(Path(u.r(0.31,0.48,0.38,0.04)), with: .color(Palette.cream.opacity(0.85)))
            ctx.fill(Path(ellipseIn: u.r(0.43,0.43,0.14,0.14)), with: .color(Palette.cream))
            ctx.fill(Path(ellipseIn: u.r(0.46,0.46,0.08,0.08)), with: .color(Color(hex: 0x5C8DB0)))
            let trees: [(CGFloat,CGFloat)] = [(0.35,0.35),(0.59,0.35),(0.35,0.59),(0.59,0.59)]
            for (tx,ty) in trees {
                ctx.fill(Path(ellipseIn: u.r(tx,ty,0.07,0.07)), with: .color(Color(hex: 0x2C5238)))
            }
            ctx.stroke(Path(roundedRect: u.r(0.06,0.06,0.88,0.88), cornerRadius: s*0.05),
                       with: .color(Palette.brass), lineWidth: s*0.015)
        }
        .accessibilityHidden(true)
    }
}

struct TrophyArt: View {
    var body: some View {
        GeometryReader { geo in
            let side = min(geo.size.width, geo.size.height)
            ZStack {
                LaurelWreath()
                Image(systemName: "trophy.fill")
                    .resizable().scaledToFit()
                    .foregroundStyle(Palette.brassGradient)
                    .frame(width: side*0.36, height: side*0.36)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .accessibilityHidden(true)
    }
}
