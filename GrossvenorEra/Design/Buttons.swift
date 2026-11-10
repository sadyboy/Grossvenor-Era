import SwiftUI

struct BrassButtonStyle: ButtonStyle {
    var prominent = true
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.smallCaps(17))
            .tracking(1.2)
            .foregroundStyle(prominent ? Palette.ink : Palette.brassLight)
            .padding(.vertical, 15)
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity)
            .background(Capsule().fill(prominent
                ? AnyShapeStyle(Palette.brassGradient)
                : AnyShapeStyle(Color.clear)))
            .overlay(Capsule().strokeBorder(Palette.brass.opacity(prominent ? 0 : 0.8), lineWidth: 1.2))
            .overlay(Capsule().strokeBorder(Color.white.opacity(prominent ? 0.35 : 0), lineWidth: 1).padding(2))
            .shadow(color: prominent ? Color.white.opacity(0.55) : .clear, radius: 20, y: 0)
            .shadow(color: prominent ? Color.white.opacity(0.2)  : .clear, radius: 6,  y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(isEnabled ? (configuration.isPressed ? 0.88 : 1) : 0.4)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct InkOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.smallCaps(15))
            .foregroundStyle(Palette.inkText)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Capsule().fill(Palette.parchmentDark.opacity(configuration.isPressed ? 0.6 : 0.3)))
            .overlay(Capsule().strokeBorder(Palette.brassDeep.opacity(0.7), lineWidth: 1))
    }
}

struct ChipButtonStyle: ButtonStyle {
    var onLight = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(onLight ? Palette.inkText : Palette.cream)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(Capsule().fill(onLight
                ? Palette.parchmentDark.opacity(0.45)
                : Palette.ink.opacity(0.6)))
            .overlay(Capsule().strokeBorder(
                onLight ? Palette.brassDeep.opacity(0.6) : Palette.brass.opacity(0.6),
                lineWidth: 1))
            .opacity(isEnabled ? (configuration.isPressed ? 0.7 : 1) : 0.4)
    }
}
