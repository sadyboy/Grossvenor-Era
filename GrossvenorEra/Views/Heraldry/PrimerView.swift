import SwiftUI

struct PrimerView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ClubBackground()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        intro
                        tinctures
                        divisions
                        ordinaries
                        charges
                    }
                    .padding(16).padding(.bottom, 32)
                }
            }
            .navigationTitle("Primer of Heraldry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }}
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeading(title: "What is a Blazon?")
            Text("A blazon is the formal textual description of a coat of arms, written according to the laws of heraldry. The first word names the field (background tincture); subsequent clauses describe each charge or division in order of importance.")
                .font(.text(15)).foregroundStyle(Palette.inkText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .parchmentCard()
    }

    private var tinctures: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Tinctures")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], alignment: .leading, spacing: 10) {
                ForEach(Tincture.allCases, id: \.self) { t in
                    HStack(spacing: 8) {
                        Circle().fill(t.color).frame(width: 28, height: 28)
                            .overlay(Circle().strokeBorder(t == .argent ? Palette.brassDeep.opacity(0.5) : .clear, lineWidth: 1))
                        Text(t.name).font(.display(14, .semibold)).foregroundStyle(Palette.inkText)
                    }
                }
            }
        }
        .parchmentCard()
    }

    private var divisions: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Divisions")
            ForEach(Division.allCases.filter { $0 != .plain }, id: \.self) { d in
                HStack(alignment: .top, spacing: 12) {
                    sampleShield(Arms(division: d, field: .or, field2: .gules))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(d.name).font(.display(14, .semibold)).foregroundStyle(Palette.inkText)
                        Text(d.explanation).font(.text(13)).foregroundStyle(Palette.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .parchmentCard()
    }

    private var ordinaries: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Ordinaries")
            ForEach(Ordinary.allCases.filter { $0 != .absent }, id: \.self) { o in
                HStack(alignment: .top, spacing: 12) {
                    sampleShield(Arms(field: .azure, ordinary: o, ordinaryTincture: .or))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(o.name).font(.display(14, .semibold)).foregroundStyle(Palette.inkText)
                        Text(o.explanation).font(.text(13)).foregroundStyle(Palette.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
        .parchmentCard()
    }

    private var charges: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeading(title: "Charges")
            Text("Charges are distinct devices placed upon the field. Common charges include the mullet (a star), roundel (a circle), lozenge (a diamond), and crescent. In a blazon they appear after the field and any ordinaries.")
                .font(.text(15)).foregroundStyle(Palette.inkText)
                .fixedSize(horizontal: false, vertical: true)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], alignment: .leading, spacing: 10) {
                ForEach(Charge.allCases.filter { $0 != .absent }, id: \.self) { c in
                    VStack(spacing: 4) {
                        sampleShield(Arms(field: .gules, charge: c, chargeTincture: .or))
                        Text(c.name).font(.display(10, .medium)).foregroundStyle(Palette.mutedText)
                            .lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
            }
        }
        .parchmentCard()
    }

    private func sampleShield(_ arms: Arms) -> some View {
        HeraldicShield(arms: arms, borderWidth: 1.5)
            .frame(width: 48, height: 48)
    }
}
