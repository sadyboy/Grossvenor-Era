import SwiftUI

struct JournalView: View {
    @StateObject private var journal = ClubJournal.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                ClubBackground()
                if journal.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Ornament().padding(.horizontal, 24).padding(.top, 8)
                            ForEach(Array(journal.entries.enumerated()), id: \.element.id) { idx, entry in
                                JournalCard(entry: entry, index: idx)
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 32)
                        }
                    }
                }
            }
            .navigationTitle("The Club Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }.foregroundStyle(Palette.brassLight)
            }}
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48)).foregroundStyle(Palette.brass.opacity(0.5))
            Text("No entries yet")
                .font(.display(20, .semibold)).foregroundStyle(Palette.cream.opacity(0.7))
            Text("Your accomplishments will be\nrecorded here as they occur.")
                .font(.text(14)).foregroundStyle(Palette.mutedText)
                .multilineTextAlignment(.center)
        }
    }
}

private struct JournalCard: View {
    let entry: JournalEntry
    let index: Int

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Timeline line + dot
            VStack(spacing: 0) {
                if index > 0 {
                    Rectangle().fill(Palette.brass.opacity(0.3)).frame(width: 1).frame(height: 16)
                }
                Circle().fill(entry.isRecord ? AnyShapeStyle(Palette.brassGradient) : AnyShapeStyle(Palette.brass.opacity(0.5)))
                    .frame(width: 10, height: 10)
                    .overlay(Circle().strokeBorder(Palette.brassDeep.opacity(0.5), lineWidth: 1))
                Rectangle().fill(Palette.brass.opacity(0.3)).frame(width: 1).frame(maxHeight: .infinity)
            }
            .frame(width: 10)
            .padding(.top, 18)

            // Card
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    Text(entry.roomTitle.uppercased())
                        .font(.system(size: 9, weight: .semibold)).tracking(1.4)
                        .foregroundStyle(Palette.brass)
                    Spacer()
                    if entry.isRecord {
                        Text("RECORD")
                            .font(.system(size: 8, weight: .bold)).tracking(1)
                            .foregroundStyle(Palette.ink)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(Palette.brassGradient))
                    }
                }
                Text(entry.narrative)
                    .font(.system(size: 14, design: .serif)).italic()
                    .foregroundStyle(Palette.inkText)
                    .fixedSize(horizontal: false, vertical: true)
                HStack {
                    if entry.score > 0 {
                        Text("\(entry.score) merit")
                            .font(.display(13, .semibold)).foregroundStyle(Palette.brassDeep)
                    }
                    Spacer()
                    Text(entry.dateString)
                        .font(.text(11)).foregroundStyle(Palette.mutedText)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Palette.parchment.opacity(0.9)))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(entry.isRecord ? Palette.brassDeep : Palette.brass.opacity(0.3), lineWidth: 1))
            .padding(.vertical, 6)
        }
    }
}
