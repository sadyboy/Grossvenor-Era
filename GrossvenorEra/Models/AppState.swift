import SwiftUI
import Combine

enum Room: String, CaseIterable, Identifiable, Hashable {
    case estate, mystery, tea, heraldry, studio

    var id: String { rawValue }
    var numeral: String { romanNumeral((Room.allCases.firstIndex(of: self) ?? 0) + 1) }

    var hall: String {
        switch self {
        case .estate:   "The Estate Office"
        case .mystery:  "The Library"
        case .tea:      "The Tea Room"
        case .heraldry: "The Heralds' Hall"
        case .studio:   "The Studio"
        }
    }

    var pastime: String {
        switch self {
        case .estate:   "Build Grosvenor Square"
        case .mystery:  "Mayfair Mysteries"
        case .tea:      "Afternoon Tea Sort"
        case .heraldry: "Read the Shield"
        case .studio:   "Design Your Arms"
        }
    }

    var blurb: String {
        switch self {
        case .estate:   "Lay out a Georgian square, plot by plot."
        case .mystery:  "Weigh the testimony. Unmask the thief."
        case .tea:      "Pour each blend into a cup of its own."
        case .heraldry: "Sixty seconds of blazons against the clock."
        case .studio:   "Compose a coat of arms and a motto."
        }
    }

    var boardKey: BoardKey? {
        switch self {
        case .estate:   .estate
        case .mystery:  .mystery
        case .tea:      .tea
        case .heraldry: .heraldry
        case .studio:   nil
        }
    }

    var title: String { hall }
    var subtitle: String { blurb }

    var symbol: String {
        switch self {
        case .estate:   "building.columns"
        case .mystery:  "magnifyingglass"
        case .tea:      "cup.and.saucer.fill"
        case .heraldry: "shield.lefthalf.filled"
        case .studio:   "paintpalette"
        }
    }

    func bestText(_ value: Int) -> String {
        switch self {
        case .estate:   value > 0 ? "Finest estate: \(value)" : "No estate built yet"
        case .mystery:  value > 0 ? "Best case: \(value)"    : "No case closed yet"
        case .tea:      value > 0 ? "Highest sitting: \(value)" : "The kettle is on"
        case .heraldry: value > 0 ? "Best round: \(value)"   : "No round played yet"
        case .studio:   "Your arms await"
        }
    }
}

struct RankTier {
    let title: String
    let threshold: Int

    static let all: [RankTier] = [
        RankTier(title: "Guest of the House", threshold: 0),
        RankTier(title: "Associate",          threshold: 250),
        RankTier(title: "Member",             threshold: 800),
        RankTier(title: "Senior Member",      threshold: 2000),
        RankTier(title: "Fellow",             threshold: 4500),
        RankTier(title: "Patron",             threshold: 9000),
    ]
}

final class VaultStore: ObservableObject {
    @Published private(set) var bests: [String: Int]
    @Published private(set) var prestige: Int
    @Published private(set) var gamesPlayed: Int

    private let defaults = UserDefaults.standard

    init() {
        bests      = defaults.dictionary(forKey: "club.bests") as? [String: Int] ?? [:]
        prestige   = defaults.integer(forKey: "club.prestige")
        gamesPlayed = defaults.integer(forKey: "club.played")
    }

    func best(for room: Room) -> Int { bests[room.rawValue] ?? 0 }

    @discardableResult
    func record(room: Room, score: Int, prestigeGain: Int, boardValue: Int? = nil) -> Bool {
        let value = boardValue ?? score
        let isRecord = value > best(for: room)
        if isRecord { bests[room.rawValue] = value }
        prestige   += max(0, prestigeGain)
        gamesPlayed += 1
        persist()
        if let key = room.boardKey {
            LocalBoardsEngine.shared.submit(value, to: key)
        }
        LocalBoardsEngine.shared.submit(prestige, to: .prestige)
        ClubJournal.shared.record(room: room, score: score, isRecord: isRecord)
        return isRecord
    }

    func addPrestige(_ amount: Int) {
        prestige += max(0, amount)
        persist()
    }

    func resetAll() {
        bests = [:]
        prestige = 0
        gamesPlayed = 0
        persist()
        defaults.removeObject(forKey: "teaLevel")
        defaults.removeObject(forKey: "mysteryCase")
    }

    var rank: RankTier { RankTier.all.last { prestige >= $0.threshold } ?? RankTier.all[0] }
    var nextRank: RankTier? { RankTier.all.first { $0.threshold > prestige } }

    var progressToNext: Double {
        guard let next = nextRank else { return 1 }
        let span = Double(next.threshold - rank.threshold)
        return min(1, max(0, Double(prestige - rank.threshold) / span))
    }

    private func persist() {
        defaults.set(bests,       forKey: "club.bests")
        defaults.set(prestige,    forKey: "club.prestige")
        defaults.set(gamesPlayed, forKey: "club.played")
    }
}
