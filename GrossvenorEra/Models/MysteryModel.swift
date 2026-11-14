import Combine
import Foundation

struct Suspect {
    let name: String
    let short: String
    let profession: String
}

struct Chamber {
    let name: String
    let short: String
    let symbol: String
    let upstairs: Bool
}
public struct ClubStanding: Codable, Hashable, Identifiable {
    public let id: String
    public let BuildingType: String
    public let BuildingNeighbour: String
    public let ChapelGardenBonus: Int
    public let InnCompanyBonus: [String]

    private enum CodingKeys: String, CodingKey {
        case id
        case BuildingType = "MetalTincture"
        case BuildingNeighbour = "title"
        case ChapelGardenBonus = "stepSeconds"
        case InnCompanyBonus = "steps"
    }
}
enum Clue {
    case isIn(Int, Int)
    case notIn(Int, Int)
    case onFloor(Int, Bool)
    case eitherOr(Int, Int, Int)
    case neither(Int, Int, Int)
    case sameFloor(Int, Int, Bool)
    case exactlyOne(Int, Int, Int, Int)   // s1, s2, s3, room — exactly one of three was in the room

    var isDirect: Bool {
        if case .isIn = self { return true }
        return false
    }

    func holds(_ a: [Int], _ rooms: [Chamber]) -> Bool {
        switch self {
        case let .isIn(s, r):               return a[s] == r
        case let .notIn(s, r):              return a[s] != r
        case let .onFloor(s, up):           return rooms[a[s]].upstairs == up
        case let .eitherOr(s1, s2, r):     return (a[s1] == r) != (a[s2] == r)
        case let .neither(s1, s2, r):       return a[s1] != r && a[s2] != r
        case let .sameFloor(s1, s2, same):  return (rooms[a[s1]].upstairs == rooms[a[s2]].upstairs) == same
        case let .exactlyOne(s1, s2, s3, r):
            let count = (a[s1] == r ? 1 : 0) + (a[s2] == r ? 1 : 0) + (a[s3] == r ? 1 : 0)
            return count == 1
        }
    }

    func text(_ s: [Suspect], _ r: [Chamber]) -> String {
        switch self {
        case let .isIn(a, room):
            let variants = [
                "\(s[a].name) was seen entering the \(r[room].name).",
                "A reliable witness places \(s[a].name) in the \(r[room].name).",
                "\(s[a].name) spent the evening in the \(r[room].name).",
                "The housekeeper confirms \(s[a].name) was in the \(r[room].name).",
            ]
            return variants[(a + room) % variants.count]

        case let .notIn(a, room):
            let variants = [
                "\(s[a].name) never set foot in the \(r[room].name).",
                "\(s[a].name) was nowhere near the \(r[room].name).",
                "Several witnesses confirm \(s[a].name) avoided the \(r[room].name) all evening.",
                "The footman is certain: \(s[a].name) did not enter the \(r[room].name).",
            ]
            return variants[(a + room) % variants.count]

        case let .onFloor(a, up):
            if up {
                let variants = [
                    "\(s[a].name) spent the whole evening upstairs.",
                    "A maid saw \(s[a].name) on the upper landing throughout.",
                    "\(s[a].name) never once came down to the ground floor.",
                ]
                return variants[a % variants.count]
            } else {
                let variants = [
                    "\(s[a].name) never once climbed the stairs.",
                    "\(s[a].name) remained below stairs the entire evening.",
                    "The butler confirms \(s[a].name) was on the ground floor all night.",
                ]
                return variants[a % variants.count]
            }

        case let .eitherOr(a, b, room):
            let variants = [
                "Either \(s[a].name) or \(s[b].name) was in the \(r[room].name) — but not both.",
                "One of \(s[a].name) or \(s[b].name) occupied the \(r[room].name). It was not both.",
                "The porter admits to seeing either \(s[a].name) or \(s[b].name) in the \(r[room].name).",
            ]
            return variants[(a + b + room) % variants.count]

        case let .neither(a, b, room):
            let variants = [
                "Neither \(s[a].name) nor \(s[b].name) went into the \(r[room].name).",
                "The \(r[room].name) was not visited by either \(s[a].name) or \(s[b].name).",
                "Both \(s[a].name) and \(s[b].name) were elsewhere — not in the \(r[room].name).",
            ]
            return variants[(a + b + room) % variants.count]

        case let .sameFloor(a, b, same):
            if same {
                let variants = [
                    "\(s[a].name) and \(s[b].name) were on the same floor.",
                    "A footman saw both \(s[a].name) and \(s[b].name) on the same level.",
                    "\(s[a].name) could hear \(s[b].name) from across the corridor.",
                ]
                return variants[(a + b) % variants.count]
            } else {
                let variants = [
                    "\(s[a].name) and \(s[b].name) were on different floors.",
                    "\(s[a].name) was heard calling to \(s[b].name) from one floor above.",
                    "The two, \(s[a].name) and \(s[b].name), never shared the same floor.",
                ]
                return variants[(a + b) % variants.count]
            }

        case let .exactlyOne(a, b, c, room):
            let variants = [
                "Of \(s[a].short), \(s[b].short), and \(s[c].short) — only one spent time in the \(r[room].name).",
                "Among the three — \(s[a].name), \(s[b].name), \(s[c].name) — precisely one was found in the \(r[room].name).",
                "One and only one of \(s[a].short), \(s[b].short), or \(s[c].short) visited the \(r[room].name).",
            ]
            return variants[(a + b + c + room) % variants.count]
        }
    }
}

struct MysteryCase {
    let number: Int
    let title: String
    let story: String
    let suspects: [Suspect]
    let rooms: [Chamber]
    let solution: [Int]
    let clues: [Clue]
    let crimeRoom: Int

    var size: Int    { suspects.count }
    var culprit: Int { solution.firstIndex(of: crimeRoom) ?? 0 }
}

enum CaseGenerator {
    static let suspects: [Suspect] = [
        Suspect(name: "Colonel Hartley",      short: "Hartley",   profession: "Retired Officer"),
        Suspect(name: "Miss Penrose",          short: "Penrose",   profession: "Governess"),
        Suspect(name: "Lord Whitcombe",        short: "Whitcombe", profession: "Peer of the Realm"),
        Suspect(name: "Mrs. Calloway",         short: "Calloway",  profession: "Society Widow"),
        Suspect(name: "Mr. Fenwick",           short: "Fenwick",   profession: "Solicitor"),
        Suspect(name: "Dr. Ravel",             short: "Ravel",     profession: "Physician"),
        Suspect(name: "Countess Orlova",       short: "Orlova",    profession: "Foreign Dignitary"),
        Suspect(name: "Reverend Ashby",        short: "Ashby",     profession: "Country Clergyman"),
        Suspect(name: "Lady Fairfax",          short: "Fairfax",   profession: "Aristocrat"),
        Suspect(name: "Mr. Marcus Webb",       short: "Webb",      profession: "Young Heir"),
        Suspect(name: "Inspector Cairns",      short: "Cairns",    profession: "Metropolitan Police"),
        Suspect(name: "Madame Voss",           short: "Voss",      profession: "Music Teacher"),
    ]

    static let rooms: [Chamber] = [
        Chamber(name: "Library",       short: "Library",   symbol: "books.vertical.fill",    upstairs: false),
        Chamber(name: "Study",         short: "Study",     symbol: "lamp.desk.fill",          upstairs: true),
        Chamber(name: "Drawing Room",  short: "Drawing",   symbol: "sofa.fill",               upstairs: true),
        Chamber(name: "Dining Room",   short: "Dining",    symbol: "fork.knife",              upstairs: false),
        Chamber(name: "Conservatory",  short: "Conserv.",  symbol: "leaf.fill",               upstairs: false),
        Chamber(name: "Billiard Room", short: "Billiard",  symbol: "circle.circle.fill",      upstairs: false),
        Chamber(name: "Music Room",    short: "Music",     symbol: "pianokeys",               upstairs: true),
        Chamber(name: "Gallery",       short: "Gallery",   symbol: "photo.artframe",          upstairs: true),
        Chamber(name: "Smoking Room",  short: "Smoking",   symbol: "smoke.fill",              upstairs: false),
        Chamber(name: "Morning Room",  short: "Morning",   symbol: "sun.and.horizon.fill",    upstairs: false),
        Chamber(name: "Gun Room",      short: "Gun Room",  symbol: "target",                  upstairs: false),
    ]

    static let items: [String] = [
        "Emerald Brooch",
        "Duchess's Pearls",
        "Silver Snuffbox",
        "Jewelled Egg",
        "Admiral's Pocket Watch",
        "Ruby Tiepin",
        "Sapphire Ring",
        "Gilt Carriage Clock",
        "Rare First Edition",
        "Diamond Hairpin",
        "Chinese Lacquer Box",
        "Silver Letter Opener",
        "Venetian Glass Paperweight",
        "Persian Miniature",
        "Ambassador's Seal",
        "Monogrammed Cigar Case",
        "Heirloom Signet Ring",
        "Crimson Almanac",
    ]

    static let storyTemplates: [(String, Int, [Chamber]) -> String] = [
        { item, crimeRoom, chosen in
            "Shortly after ten, the \(item.lowercased()) vanished from the \(chosen[crimeRoom].name). Each guest was in a different room. Place every one of them — whoever stood in the \(chosen[crimeRoom].name) is your thief."
        },
        { item, crimeRoom, chosen in
            "The evening was ruined when the \(item.lowercased()) was found missing from the \(chosen[crimeRoom].name). Your task: deduce where every guest was. The thief is the one found in the \(chosen[crimeRoom].name)."
        },
        { item, crimeRoom, chosen in
            "A scandal at the Grosvenor! The \(item.lowercased()) was taken from the \(chosen[crimeRoom].name) between nine and midnight. No two guests shared a room. Find the thief."
        },
        { item, crimeRoom, chosen in
            "Inspector Fairfax has asked for your assistance. The \(item.lowercased()) was taken from the \(chosen[crimeRoom].name). Each guest occupied a separate room. Establish the placements to identify the culprit."
        },
        { item, crimeRoom, chosen in
            "The \(item.lowercased()) has disappeared from the \(chosen[crimeRoom].name). The household is in an uproar. Place each guest to determine which of them is the thief."
        },
    ]

    static func permutations(_ n: Int) -> [[Int]] {
        var result: [[Int]] = []
        func permute(_ cur: [Int], _ rem: [Int]) {
            if rem.isEmpty { result.append(cur); return }
            for (i, v) in rem.enumerated() {
                var rest = rem; rest.remove(at: i)
                permute(cur + [v], rest)
            }
        }
        permute([], Array(0..<n))
        return result
    }

    static func make(number: Int) -> MysteryCase {
        let n = number <= 3 ? 4 : 5
        let people = Array(suspects.shuffled().prefix(n))
        var chosen: [Chamber] = []
        repeat {
            chosen = Array(rooms.shuffled().prefix(n))
        } while !(chosen.contains { $0.upstairs } && chosen.contains { !$0.upstairs })

        let solution = Array(0..<n).shuffled()
        let all = permutations(n)

        var pool: [Clue] = []
        for s in 0..<n {
            for r in 0..<n {
                pool.append(solution[s] == r ? .isIn(s, r) : .notIn(s, r))
            }
            pool.append(.onFloor(s, chosen[solution[s]].upstairs))
        }
        for s1 in 0..<n {
            for s2 in (s1+1)..<n {
                pool.append(.sameFloor(s1, s2, chosen[solution[s1]].upstairs == chosen[solution[s2]].upstairs))
                for r in 0..<n {
                    let a = solution[s1] == r, b = solution[s2] == r
                    if a != b  { pool.append(.eitherOr(s1, s2, r)) }
                    else if !a { pool.append(.neither(s1, s2, r))  }
                }
            }
        }
        // Three-way constraints: exactly one of three suspects was in a room
        for s1 in 0..<n {
            for s2 in (s1+1)..<n {
                for s3 in (s2+1)..<n {
                    for r in 0..<n {
                        let count = (solution[s1] == r ? 1 : 0) + (solution[s2] == r ? 1 : 0) + (solution[s3] == r ? 1 : 0)
                        if count == 1 { pool.append(.exactlyOne(s1, s2, s3, r)) }
                    }
                }
            }
        }

        let ordered = pool.filter { !$0.isDirect }.shuffled() + pool.filter { $0.isDirect }.shuffled()
        var remaining = all, clues: [Clue] = []
        for clue in ordered {
            let filtered = remaining.filter { clue.holds($0, chosen) }
            if filtered.count < remaining.count { clues.append(clue); remaining = filtered }
            if remaining.count == 1 { break }
        }
        var i = 0
        while i < clues.count {
            var trial = clues; trial.remove(at: i)
            let matches = all.filter { p in trial.allSatisfy { $0.holds(p, chosen) } }.count
            if matches == 1 { clues = trial } else { i += 1 }
        }

        let crimeRoom  = Int.random(in: 0..<n)
        let item       = items[(number - 1) % items.count]
        let templateIdx = (number - 1) % storyTemplates.count
        let story      = storyTemplates[templateIdx](item, crimeRoom, chosen)

        return MysteryCase(number: number, title: "The \(item)",
                           story: story, suspects: people, rooms: chosen,
                           solution: solution, clues: clues.shuffled(), crimeRoom: crimeRoom)
    }
}

enum Mark: Equatable { case empty, cross, check }

final class MysteryGame: ObservableObject {
    @Published private(set) var current: MysteryCase
    @Published var marks: [[Mark]]
    @Published var struck: Set<Int> = []
    @Published private(set) var wrongGuesses = 0
    @Published private(set) var hintsUsed    = 0
    @Published private(set) var message: String?
    @Published private(set) var solved = false
    @Published private(set) var shake  = 0

    private(set) var startDate    = Date()
    private(set) var solveSeconds = 0

    init() {
        let number = max(1, UserDefaults.standard.integer(forKey: "mysteryCase"))
        let c = CaseGenerator.make(number: number)
        current = c
        marks   = MysteryGame.blank(c.size)
    }

    private static func blank(_ n: Int) -> [[Mark]] {
        Array(repeating: Array(repeating: Mark.empty, count: n), count: n)
    }

    func nextCase() {
        let number = current.number + 1
        UserDefaults.standard.set(number, forKey: "mysteryCase")
        load(CaseGenerator.make(number: number))
    }

    func restartIfReset() {
        let saved = max(1, UserDefaults.standard.integer(forKey: "mysteryCase"))
        if saved != current.number { load(CaseGenerator.make(number: saved)) }
    }

    private func load(_ c: MysteryCase) {
        current = c; marks = Self.blank(c.size); struck = []
        wrongGuesses = 0; hintsUsed = 0; message = nil
        solved = false; startDate = Date(); solveSeconds = 0
    }

    func cycle(_ s: Int, _ r: Int) {
        guard !solved else { return }
        switch marks[s][r] {
        case .empty: marks[s][r] = .cross
        case .cross: marks[s][r] = .check; autoCross(s, r)
        case .check: marks[s][r] = .empty
        }
        message = nil
    }

    private func autoCross(_ s: Int, _ r: Int) {
        for i in 0..<current.size {
            if i != r && marks[s][i] == .empty { marks[s][i] = .cross }
            if i != s && marks[i][r] == .empty { marks[i][r] = .cross }
        }
    }

    func toggleClue(_ index: Int) {
        if struck.contains(index) { struck.remove(index) } else { struck.insert(index) }
    }

    var readyToAccuse: Bool {
        marks.allSatisfy { row in row.filter { $0 == .check }.count == 1 }
    }

    func accuse() -> Bool {
        let placements = marks.map { $0.firstIndex(of: .check) ?? -1 }
        let correct    = zip(placements, current.solution).filter { $0.0 == $0.1 }.count
        if correct == current.size {
            solved = true
            solveSeconds = Int(Date().timeIntervalSince(startDate))
            message = nil
            return true
        }
        wrongGuesses += 1; shake += 1
        message = "Not quite — \(correct) of \(current.size) guests are placed correctly."
        return false
    }

    func hint() {
        guard !solved else { return }
        for s in 0..<current.size where marks[s][current.solution[s]] != .check {
            let room = current.solution[s]
            for r in 0..<current.size { marks[s][r] = r == room ? .check : .cross }
            for other in 0..<current.size where other != s && marks[other][room] == .check {
                marks[other][room] = .cross
            }
            autoCross(s, room)
            hintsUsed += 1
            message = "A footman whispers: \(current.suspects[s].name) was in the \(current.rooms[room].name)."
            return
        }
    }

    var score: Int {
        max(100, 1000 - solveSeconds * 3 - wrongGuesses * 150 - hintsUsed * 200)
    }
}
