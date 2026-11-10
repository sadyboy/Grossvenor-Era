import SwiftUI
import Combine

enum BoardKey: String, CaseIterable {
    case estate  = "board.estate"
    case mystery = "board.mystery"
    case tea     = "board.tea"
    case heraldry = "board.heraldry"
    case prestige = "board.prestige"

    var label: String {
        switch self {
        case .estate:  "Estate"
        case .mystery: "Mystery"
        case .tea:     "Tea Room"
        case .heraldry:"Heraldry"
        case .prestige:"Prestige"
        }
    }
}

final class LocalBoardsEngine: ObservableObject {
    static let shared = LocalBoardsEngine()
    private init() {}

    func submit(_ score: Int, to key: BoardKey) {
        let current = UserDefaults.standard.integer(forKey: key.rawValue)
        if score > current {
            UserDefaults.standard.set(score, forKey: key.rawValue)
        }
    }

    func topScore(for key: BoardKey) -> Int {
        UserDefaults.standard.integer(forKey: key.rawValue)
    }
}

struct LocalScoresView: View {
    var highlighted: BoardKey?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    ForEach(BoardKey.allCases.filter { $0 != .prestige }, id: \.self) { key in
                        let score = LocalBoardsEngine.shared.topScore(for: key)
                        HStack {
                            Text(key.label)
                                .font(.display(17, .semibold))
                                .foregroundStyle(highlighted == key ? Palette.oxblood : Palette.inkText)
                            Spacer()
                            if score > 0 {
                                Text("\(score)")
                                    .font(.display(20, .semibold))
                                    .foregroundStyle(Palette.oxblood)
                                    .monospacedDigit()
                            } else {
                                Text("—")
                                    .font(.display(17, .regular))
                                    .foregroundStyle(Palette.mutedText)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(highlighted == key
                                      ? Palette.parchment
                                      : Palette.parchment.opacity(0.6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(
                                    highlighted == key ? Palette.brassDeep : Palette.brassDeep.opacity(0.35),
                                    lineWidth: highlighted == key ? 1.5 : 1)
                        )
                    }
                }
                .padding(18)
            }
            .background(ClubBackground())
            .navigationTitle("House Records")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
