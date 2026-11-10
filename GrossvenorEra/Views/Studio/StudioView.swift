import SwiftUI
import Combine

final class StudioModel: ObservableObject {
    @Published private(set) var current: Arms = HeraldryGenerator.randomStudioArms()
    @Published private(set) var history: [Arms] = []
    @Published          var name: String = "Grosvenor"

    var isCurrentSaved: Bool { history.last == current }

    func randomize() { current = HeraldryGenerator.randomStudioArms() }

    func save() {
        guard !isCurrentSaved else { return }
        history.append(current)
        if history.count > 24 { history.removeFirst() }
    }

    func select(_ arms: Arms) { current = arms }

    func setField(_ t: Tincture)             { current.field             = t }
    func setField2(_ t: Tincture)            { current.field2            = t }
    func setOrdinaryTincture(_ t: Tincture)  { current.ordinaryTincture  = t }
    func setChargeTincture(_ t: Tincture)    { current.chargeTincture    = t }
}

struct StudioView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var gen = StudioModel()

    private let armsCols = [GridItem(.adaptive(minimum: 68, maximum: 90), spacing: 12)]

    var body: some View {
        ZStack {
            ClubBackground()
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    SectionHeading(title: "Design Studio")
                    poster
                    blazonCard
                    if !gen.history.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Register").eyebrow(onLight: true)
                            LazyVGrid(columns: armsCols, spacing: 12) {
                                ForEach(Array(gen.history.reversed().enumerated()), id: \.offset) { _, arms in
                                    ThumbChip(arms: arms) { gen.select(arms) }
                                }
                            }
                        }
                        .parchmentCard()
                    }
                    tinctureWorkbench
                }
                .padding(16).padding(.bottom, 32)
            }
        }
        .roomChrome(title: "The Design Studio") { }
    }

    private var poster: some View {
        VStack(spacing: 16) {
            CoatOfArmsPoster(arms: gen.current, name: gen.name)
                .frame(maxWidth: 300)
                .shadow(color: .black.opacity(0.4), radius: 12, y: 6)
            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { gen.randomize() }
                    Haptics.select()
                } label: { Label("Randomise", systemImage: "shuffle") }
                .buttonStyle(BrassButtonStyle())

                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { gen.save() }
                    Haptics.tap()
                } label: { Image(systemName: "square.and.arrow.down") }
                .buttonStyle(BrassButtonStyle())
                .disabled(gen.isCurrentSaved)
            }
        }
        .padding(.top, 4)
    }

    private var blazonCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Blazon").eyebrow(onLight: true)
            Text(gen.current.blazon)
                .font(.display(17, .regular)).italic().multilineTextAlignment(.leading)
                .foregroundStyle(Palette.inkText).fixedSize(horizontal: false, vertical: true)
            Divider().overlay(Palette.brassDeep.opacity(0.3))
            VStack(alignment: .leading, spacing: 4) {
                tinctureEntry("Field",    gen.current.field.name)
                if gen.current.division != .plain {
                    tinctureEntry("Division", gen.current.division.name + " — " + gen.current.field2.name)
                }
                if gen.current.ordinary != .absent {
                    tinctureEntry("Ordinary", gen.current.ordinary.name + " — " + gen.current.ordinaryTincture.name)
                }
                if gen.current.charge != .absent {
                    tinctureEntry("Charge", gen.current.charge.name + " — " + gen.current.chargeTincture.name)
                }
            }
        }
        .parchmentCard()
    }

    private func tinctureEntry(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.display(12, .semibold)).foregroundStyle(Palette.mutedText).frame(width: 72, alignment: .leading)
            Text(value).font(.display(14, .regular)).foregroundStyle(Palette.inkText)
        }
    }

    private var tinctureWorkbench: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Adjust").eyebrow(onLight: true)
            Group {
                TinctureRow(label: "Field", current: gen.current.field,
                            options: Tincture.allCases) { gen.setField($0) }
                if gen.current.division != .plain {
                    TinctureRow(label: "Division colour",
                                current: gen.current.field2,
                                options: Tincture.allCases) { gen.setField2($0) }
                }
                if gen.current.ordinary != .absent {
                    TinctureRow(label: "Ordinary colour",
                                current: gen.current.ordinaryTincture,
                                options: Tincture.allCases) { gen.setOrdinaryTincture($0) }
                }
                if gen.current.charge != .absent {
                    TinctureRow(label: "Charge colour",
                                current: gen.current.chargeTincture,
                                options: Tincture.allCases) { gen.setChargeTincture($0) }
                }
            }
        }
        .parchmentCard()
    }
}

struct CoatOfArmsPoster: View {
    let arms: Arms
    var name: String = ""

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                LaurelWreath().frame(width: 60, height: 54)
                Spacer()
                LaurelWreath().frame(width: 60, height: 54).scaleEffect(x: -1)
            }
            .padding(.horizontal, 20).padding(.top, 14)
            HeraldicShield(arms: arms).padding(.horizontal, 36)
            RibbonShape()
                .fill(Palette.oxblood)
                .frame(height: 48).padding(.horizontal, 24).padding(.top, -8)
                .overlay(
                    Text(name.isEmpty ? "Grosvenor" : name)
                        .font(.display(15, .semibold)).italic()
                        .foregroundStyle(Palette.cream)
                        .padding(.bottom, 8)
                )
            Text("GROSVENOR ERA").font(.smallCaps(11)).tracking(2.5)
                .foregroundStyle(Palette.brassDeep).padding(.top, 10).padding(.bottom, 16)
        }
        .background(
            LinearGradient(colors: [Palette.parchment, Palette.parchmentDark], startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(Palette.brassGradient, lineWidth: 2))
        .shadow(color: .black.opacity(0.4), radius: 10, y: 5)
    }
}

struct ThumbChip: View {
    let arms: Arms
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HeraldicShield(arms: arms, borderWidth: 1.5)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Palette.parchment.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Palette.brassDeep.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Select coat of arms: \(arms.blazon)")
    }
}

struct TinctureRow: View {
    let label: String
    let current: Tincture?
    let options: [Tincture]
    let onSelect: (Tincture) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.display(12, .semibold)).foregroundStyle(Palette.mutedText)
            HStack(spacing: 8) {
                ForEach(options, id: \.self) { t in
                    Button {
                        onSelect(t)
                        Haptics.select()
                    } label: {
                        Circle().fill(t.color).frame(width: 28, height: 28)
                            .overlay(Circle().strokeBorder(t == .argent ? Palette.brassDeep.opacity(0.4) : .clear, lineWidth: 1))
                            .overlay(Circle().strokeBorder(t == current ? Palette.brassLight : .clear, lineWidth: 2.5))
                            .shadow(color: t == current ? Palette.brass.opacity(0.6) : .clear, radius: 4)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(t.name + (t == current ? ", selected" : ""))
                }
            }
        }
    }
}
