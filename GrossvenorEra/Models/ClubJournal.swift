import Foundation
import Combine

struct JournalEntry: Codable, Identifiable {
    let id: UUID
    let dateString: String
    let roomTitle: String
    let score: Int
    let isRecord: Bool
    let narrative: String
}

final class ClubJournal: ObservableObject {
    static let shared = ClubJournal()

    @Published private(set) var entries: [JournalEntry] = []

    private let key = "club.journal.v1"
    private static let maxEntries = 60

    private init() { load() }

    func record(room: Room, score: Int, isRecord: Bool) {
        let entry = JournalEntry(
            id: UUID(),
            dateString: Self.formatted(Date()),
            roomTitle: room.title,
            score: score,
            isRecord: isRecord,
            narrative: Self.narrative(for: room, score: score, isRecord: isRecord)
        )
        entries.insert(entry, at: 0)
        if entries.count > Self.maxEntries { entries.removeLast() }
        save()
    }

    var isEmpty: Bool { entries.isEmpty }

    private static func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }

    private static func narrative(for room: Room, score: Int, isRecord: Bool) -> String {
        let recordPhrase = isRecord ? " A new house record." : ""
        switch room {
        case .estate:
            let phrases = [
                "Twenty-five plots surveyed and valued at \(score).\(recordPhrase)",
                "A fresh Georgian square laid out. Estate value declared at \(score) by the surveyor.\(recordPhrase)",
                "The estate plan approved this afternoon — the valuation stood at \(score).\(recordPhrase)",
                "His survey of the new square was completed. Total value: \(score).\(recordPhrase)",
            ]
            return phrases[score % phrases.count]

        case .mystery:
            let phrases = [
                "A troubling affair at Grosvenor — dispatched with \(score) merit points recorded.\(recordPhrase)",
                "The case was closed this evening. \(score) merit for services rendered.\(recordPhrase)",
                "Another mystery resolved. The Club awarded \(score) points of merit.\(recordPhrase)",
                "The thief stood exposed before the household. Merit: \(score).\(recordPhrase)",
            ]
            return phrases[score % phrases.count]

        case .tea:
            let phrases = [
                "The afternoon's tea service sorted — \(score) merit tallied for the sitting.\(recordPhrase)",
                "Blends accounted for and separated. \(score) merit points of credit.\(recordPhrase)",
                "A satisfactory service. The tea-mistress noted a merit of \(score).\(recordPhrase)",
                "Every blend returned to its proper cup. \(score) merit on the card.\(recordPhrase)",
            ]
            return phrases[score % phrases.count]

        case .heraldry:
            let phrases = [
                "The blazon examination in the Heralds' Hall yielded \(score) merit.\(recordPhrase)",
                "Shields and devices identified under examination. Final mark: \(score).\(recordPhrase)",
                "The armorial trial concluded with \(score) points of merit.\(recordPhrase)",
                "Coats of arms recited in quick succession. Total merit: \(score).\(recordPhrase)",
            ]
            return phrases[score % phrases.count]

        case .studio:
            let phrases = [
                "New heraldic arms composed and entered into the studio record.",
                "A fresh coat of arms was designed and preserved for posterity.",
                "The studio produced a new device — duly registered this day.",
                "Arms of original invention committed to the studio archive.",
            ]
            return phrases[0]
        }
    }

    private func save() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) else { return }
        entries = decoded
    }
}
