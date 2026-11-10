import SwiftUI

struct HeraldicShield: View {
    let arms: Arms
    var borderWidth: CGFloat = 2.5

    var body: some View {
        Canvas { ctx, size in
            ctx.clip(to: ShieldShape().path(in: CGRect(origin: .zero, size: size)))
            ArmsPainter.paint(arms, in: ctx, size: size)
        }
        .aspectRatio(5.0 / 6.0, contentMode: .fit)
        .overlay(ShieldShape().stroke(Palette.brass, lineWidth: borderWidth))
        .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
        .accessibilityLabel(arms.blazon)
    }
}
