import SwiftUI

extension Font {
    static func display(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .serif)
    }
    static func smallCaps(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .serif).smallCaps()
    }
    static func text(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

extension Text {
    func eyebrow(onLight: Bool = false) -> some View {
        self.font(.system(size: 11, weight: .bold))
            .tracking(2.2)
            .textCase(.uppercase)
            .foregroundStyle(onLight ? Palette.brassDeep : Palette.brass)
    }
}
