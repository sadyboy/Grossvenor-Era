import SwiftUI

struct StatPill: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.display(20, .semibold))
                .monospacedDigit()
                .foregroundStyle(Palette.cream)
                .contentTransition(.numericText())
            Text(label.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.2)
                .foregroundStyle(Palette.brass)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(Palette.ink.opacity(0.55)))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
            .strokeBorder(Palette.brass.opacity(0.35), lineWidth: 1))
        .shadow(color: Color.white.opacity(0.1), radius: 14, y: 0)
        .accessibilityElement(children: .combine)
    }
}

struct Ornament: View {
    var color: Color = Palette.brass

    var body: some View {
        HStack(spacing: 7) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, color], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
            Diamond().fill(color).frame(width: 6, height: 9)
            Circle().fill(color).frame(width: 4, height: 4)
            Diamond().fill(color).frame(width: 6, height: 9)
            Rectangle()
                .fill(LinearGradient(colors: [color, .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
        }
        .accessibilityHidden(true)
    }
}

struct SectionHeading: View {
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, Palette.brass.opacity(0.7)],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
            Text(title)
                .font(.display(20, .semibold))
                .foregroundStyle(Palette.cream)
                .fixedSize()
            Rectangle()
                .fill(LinearGradient(colors: [Palette.brass.opacity(0.7), .clear],
                                     startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
        }
    }
}

struct CircleIconButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Palette.brassLight)
                .frame(width: 42, height: 42)
                .background(Circle().fill(Palette.ink.opacity(0.65)))
                .overlay(Circle().strokeBorder(Palette.brass.opacity(0.6), lineWidth: 1))
        }
        .accessibilityLabel(label)
    }
}
