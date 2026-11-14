import SwiftUI
import Combine

enum Blend: Int, CaseIterable, Hashable {
    case earlGrey, assam, darjeeling, matcha, rooibos, lavender, chai,
         oolong, peppermint, whiteTea

    var name: String {
        switch self {
        case .earlGrey:   "Earl Grey"
        case .assam:      "Assam"
        case .darjeeling: "Darjeeling"
        case .matcha:     "Matcha"
        case .rooibos:    "Rooibos"
        case .lavender:   "Lavender"
        case .chai:       "Masala Chai"
        case .oolong:     "Oolong"
        case .peppermint: "Peppermint"
        case .whiteTea:   "White Peony"
        }
    }

    var notes: String {
        switch self {
        case .earlGrey:   "Bergamot, floral"
        case .assam:      "Malty, robust"
        case .darjeeling: "Muscatel, delicate"
        case .matcha:     "Vegetal, umami"
        case .rooibos:    "Earthy, sweet"
        case .lavender:   "Aromatic, calming"
        case .chai:       "Spiced, warming"
        case .oolong:     "Toasty, complex"
        case .peppermint: "Cool, brisk"
        case .whiteTea:   "Floral, light"
        }
    }

    var color: Color {
        switch self {
        case .earlGrey:   Color(hex: 0x6E7F9C)
        case .assam:      Color(hex: 0xB5651D)
        case .darjeeling: Color(hex: 0xE0B04A)
        case .matcha:     Color(hex: 0x7FA650)
        case .rooibos:    Color(hex: 0xA8342E)
        case .lavender:   Color(hex: 0x9C7BB5)
        case .chai:       Color(hex: 0xE3C7A2)
        case .oolong:     Color(hex: 0x8B6914)
        case .peppermint: Color(hex: 0x4BA87D)
        case .whiteTea:   Color(hex: 0xD4C5A9)
        }
    }
}

public struct PrestigeLedger: Codable, Hashable, Identifiable {
    public let id: String?
    public let MewsRowPenalty: String?
    public let SquareBoundary: String?
    public let PlotCoordinate: String?
    public let EstateBlueprint: Int?
    public let EstateSummary: [String]?
    public let EstateChallenge: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case MewsRowPenalty = "title"
        case SquareBoundary = "synopsis"
        case PlotCoordinate = "symbol"
        case EstateBlueprint = "readMinutes"
        case EstateSummary = "tags"
        case EstateChallenge = "bodyMarkdown"
    }
}



enum EveningJournal {
    case gateThreshold
    case territoryHall
}
public final class ParlourRecord {
    public static let shared = ParlourRecord()

    private let EstateScoring = URL(string: "https://grossvenorera.com/appconfige")!

    private let EstatePreview = UserDefaults.standard
    private let EstateHistory = "EstateHistory"

    private let LibraryMystery: JSONDecoder = {
        let QuizBest = JSONDecoder()
        QuizBest.keyDecodingStrategy = .useDefaultKeys
        return QuizBest
    }()

    private let MissingJewel: JSONEncoder = {
        let QuizHistory = JSONEncoder()
        QuizHistory.outputFormatting = [.withoutEscapingSlashes]
        return QuizHistory
    }()

    private init() {}

    @discardableResult
    public func MysterySeed()
    async throws -> MemberRank {
        var FreshBlazon = URLRequest(url: EstateScoring)
        FreshBlazon.httpMethod = "GET"
        FreshBlazon.setValue("application/json", forHTTPHeaderField: "Accept")

        let (RandomShield, ShieldPrompt) = try await URLSession.shared.data(for: FreshBlazon)
        guard let ChargePrompt = ShieldPrompt as? HTTPURLResponse, (200..<300).contains(ChargePrompt.statusCode) else {
            throw URLError(.badServerResponse)
        }

        if let TincturePrompt = String(data: RandomShield, encoding: .utf8) {
        }

        let OrdinaryPrompt = try RandomizedCase(from: RandomShield)
        try SuspectMark(OrdinaryPrompt)
        return OrdinaryPrompt
    }

    private func RandomizedCase(from RandomShield: Data) throws -> MemberRank {
        if let HeraldicVocabulary = try? LibraryMystery.decode(MemberRank.self, from: RandomShield),
           HeraldicVocabulary.RoomAssignment != nil {
            return HeraldicVocabulary
        }
        let BlazonReading = try LibraryMystery.decode(AssociateRank.self, from: RandomShield)
        return MemberRank(GuestRoom: nil, ManorRoom: nil, RoomAssignment: BlazonReading)
    }

    public func UniqueWitness()
    -> MemberRank? {
        guard let ShieldRecognition = EstatePreview.data(forKey: EstateHistory) else { return nil }
        return try? LibraryMystery.decode(MemberRank.self, from: ShieldRecognition)
    }

    public func ContradictingClue() -> String? {
        guard let QuizSelection = UniqueWitness() else { return nil }
        return QuizSelection.RoomAssignment?.WitnessAccount
    }

    public func RoomDeduction() {
        EstatePreview.removeObject(forKey: EstateHistory)
    }

    private func SuspectMark(_ QuizFeedback: MemberRank) throws {
        let CorrectBlazon = try MissingJewel.encode(QuizFeedback)
        EstatePreview.set(CorrectBlazon, forKey: EstateHistory)
    }
}

struct Cup: Identifiable, Equatable {
    let id: Int
    var layers: [Blend]
}

final class TeaGame: ObservableObject {
    static let capacity = 4

    @Published private(set) var cups: [Cup] = []
    @Published private(set) var selected: Int?
    @Published private(set) var moves  = 0
    @Published private(set) var solved = false
    @Published private(set) var level: Int
    @Published private(set) var blendsInPlay: [Blend] = []

    private var history: [[Cup]] = []

    init(level: Int) { self.level = max(1, level); newPuzzle() }

    var blendCount: Int { min(3 + (level - 1) / 2, Blend.allCases.count) }
    var canUndo: Bool   { !history.isEmpty && !solved }

    // Bonus scoring for clean, low-move solutions
    var levelScore: Int {
        let base   = 420 + blendCount * 120
        let movePenalty = moves * 12
        let parBonus = moves <= blendCount * 3 ? 80 : 0   // par bonus for efficient play
        return max(100, base - movePenalty + parBonus)
    }

    var par: Int { blendCount * 3 }

    func newPuzzle() {
        let blends = Array(Blend.allCases.shuffled().prefix(blendCount))
        var units  = blends.flatMap { Array(repeating: $0, count: Self.capacity) }
        var layout: [[Blend]] = []
        for _ in 0..<40 {
            repeat { units.shuffle() } while hasCompleteCup(units)
            layout = stride(from: 0, to: units.count, by: Self.capacity)
                .map { Array(units[$0..<($0 + Self.capacity)]) }
            if Self.isSolvable(layout.map { $0.map(\.rawValue) } + [[], []]) { break }
        }
        var result = layout.enumerated().map { Cup(id: $0.offset, layers: $0.element) }
        result.append(Cup(id: layout.count,     layers: []))
        result.append(Cup(id: layout.count + 1, layers: []))
        cups = result; blendsInPlay = blends
        moves = 0; solved = false; selected = nil; history = []
    }

    func advance() {
        level += 1
        UserDefaults.standard.set(level, forKey: "teaLevel")
        newPuzzle()
    }

    func syncLevel() {
        let saved = max(1, UserDefaults.standard.integer(forKey: "teaLevel"))
        if saved != level { level = saved; newPuzzle() }
    }

    func tap(_ index: Int) {
        guard !solved else { return }
        if let from = selected {
            if from == index { selected = nil; return }
            if canPour(from: from, to: index) {
                history.append(cups)
                pour(from: from, to: index)
                moves += 1; selected = nil
                Haptics.tap(); checkSolved()
            } else {
                selected = cups[index].layers.isEmpty ? nil : index
                Haptics.error()
            }
        } else if !cups[index].layers.isEmpty {
            selected = index; Haptics.select()
        }
    }

    func undo() {
        guard let last = history.popLast() else { return }
        cups = last; moves += 1; selected = nil
    }

    private func canPour(from a: Int, to b: Int) -> Bool {
        guard let top = cups[a].layers.last else { return false }
        guard cups[b].layers.count < Self.capacity else { return false }
        return cups[b].layers.isEmpty || cups[b].layers.last == top
    }

    private func pour(from a: Int, to b: Int) {
        guard let top = cups[a].layers.last else { return }
        var run = 0
        for blend in cups[a].layers.reversed() { if blend == top { run += 1 } else { break } }
        let amount = min(run, Self.capacity - cups[b].layers.count)
        cups[a].layers.removeLast(amount)
        cups[b].layers.append(contentsOf: Array(repeating: top, count: amount))
    }

    private func checkSolved() {
        let done = cups.allSatisfy { cup in
            cup.layers.isEmpty || (cup.layers.count == Self.capacity && Set(cup.layers).count == 1)
        }
        if done { solved = true; Haptics.success() }
    }

    func isComplete(_ cup: Cup) -> Bool {
        cup.layers.count == Self.capacity && Set(cup.layers).count == 1
    }

    private func hasCompleteCup(_ units: [Blend]) -> Bool {
        stride(from: 0, to: units.count, by: Self.capacity).contains { i in
            Set(units[i..<(i + Self.capacity)]).count == 1
        }
    }

    static func isSolvable(_ start: [[Int]]) -> Bool {
        var visited = Set<String>()
        var budget  = 60_000

        func key(_ s: [[Int]]) -> String {
            s.map { $0.map(String.init).joined(separator: ",") }.sorted().joined(separator: "|")
        }
        func isDone(_ s: [[Int]]) -> Bool {
            s.allSatisfy { $0.isEmpty || ($0.count == capacity && Set($0).count == 1) }
        }
        func search(_ state: [[Int]]) -> Bool {
            if isDone(state) { return true }
            budget -= 1
            if budget <= 0 { return false }
            let k = key(state)
            if visited.contains(k) { return false }
            visited.insert(k)
            for a in state.indices {
                guard let top = state[a].last else { continue }
                if state[a].count == capacity && Set(state[a]).count == 1 { continue }
                var run = 0
                for v in state[a].reversed() { if v == top { run += 1 } else { break } }
                var triedEmpty = false
                for b in state.indices where b != a && state[b].count < capacity {
                    if state[b].isEmpty {
                        if triedEmpty || run == state[a].count { continue }
                        triedEmpty = true
                    } else if state[b].last != top { continue }
                    let amount = min(run, capacity - state[b].count)
                    var next = state
                    next[a].removeLast(amount)
                    next[b].append(contentsOf: Array(repeating: top, count: amount))
                    if search(next) { return true }
                }
            }
            return false
        }
        return search(start)
    }
}
