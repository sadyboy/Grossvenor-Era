import SwiftUI

struct ParchmentCard: ViewModifier {
    var padding: CGFloat = 16
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.cream, Palette.parchment],
                                        startPoint: .top, endPoint: .bottom))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Palette.brassDeep.opacity(0.55), lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Palette.brass.opacity(0.35), lineWidth: 0.75)
                    .padding(4).allowsHitTesting(false)
            )
            .shadow(color: .black.opacity(0.5), radius: 16, y: 8)
            .shadow(color: Color.white.opacity(0.1), radius: 24, y: 0)
    }
}

struct LacquerPanel: ViewModifier {
    var padding: CGFloat = 14
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.greenMid, Palette.green],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Palette.brass.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 14, y: 6)
            .shadow(color: Palette.brass.opacity(0.18), radius: 18, y: 0)
    }
}

extension View {
    func parchmentCard(padding: CGFloat = 16) -> some View { modifier(ParchmentCard(padding: padding)) }
    func lacquerPanel(padding: CGFloat = 14) -> some View  { modifier(LacquerPanel(padding: padding))  }
}
