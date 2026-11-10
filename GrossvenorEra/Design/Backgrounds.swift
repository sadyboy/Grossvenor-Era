import SwiftUI

struct ClubBackground: View {
    var body: some View {
        ZStack {
            Color(hex: 0x080810)
            LinearGradient(colors: [Palette.green, Palette.ink], startPoint: .top, endPoint: .bottom)
            DamaskPattern().opacity(0.05)
            RadialGradient(colors: [Color.white.opacity(0.09), .clear], center: .top, startRadius: 0, endRadius: 450)
            RadialGradient(colors: [Palette.oxblood.opacity(0.14), .clear], center: .bottom, startRadius: 0, endRadius: 380)
        }
        .ignoresSafeArea()
    }
}

struct DamaskPattern: View {
    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 36
            var row = 0
            var y: CGFloat = 0
            while y < size.height + step {
                var x: CGFloat = row.isMultiple(of: 2) ? 0 : step / 2
                while x < size.width + step {
                    let r = CGRect(x: x - 5, y: y - 7, width: 10, height: 14)
                    ctx.fill(Diamond().path(in: r), with: .color(Palette.brass))
                    ctx.fill(Path(ellipseIn: CGRect(x: x + step/4 - 1.2, y: y - 1.2, width: 2.4, height: 2.4)),
                             with: .color(Palette.brass))
                    x += step
                }
                y += step / 2; row += 1
            }
        }
    }
}
