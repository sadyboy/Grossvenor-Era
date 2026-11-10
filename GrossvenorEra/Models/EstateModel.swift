import Foundation
import Combine

enum Plot: Int, CaseIterable, Hashable {
    case house, garden, mews, chapel, fountain, inn

    var name: String {
        switch self {
        case .house:    "Townhouse"
        case .garden:   "Garden"
        case .mews:     "Mews"
        case .chapel:   "Chapel"
        case .fountain: "Fountain"
        case .inn:      "Coaching Inn"
        }
    }

    var shortName: String {
        switch self {
        case .house:    "House"
        case .garden:   "Garden"
        case .mews:     "Mews"
        case .chapel:   "Chapel"
        case .fountain: "Fountain"
        case .inn:      "Inn"
        }
    }

    var rule: String {
        switch self {
        case .house:
            "+1 for each neighbouring Townhouse, +2 for each Garden, −2 for each Mews."
        case .garden:
            "+1 on its own, +2 more when it borders a Chapel."
        case .mews:
            "+3 on the edge of the estate, +1 more beside another Mews."
        case .chapel:
            "+2 for each different kind of plot beside it. −3 beside another Chapel."
        case .fountain:
            "Scores 0 itself, but raises the value of every adjacent plot by +1."
        case .inn:
            "+1 for each distinct type of building directly adjacent (up to +4). The more varied the neighbourhood, the livelier the trade."
        }
    }
}

final class SquareEngine: ObservableObject {
    static let size = 5

    @Published private(set) var grid: [Plot?] = []
    @Published private(set) var queue: [Plot]  = []
    @Published private(set) var swapsLeft = 2
    @Published private(set) var isOver    = false
    @Published private(set) var lastPlaced: Int?

    init() { reset() }

    func reset() {
        grid       = Array(repeating: nil, count: Self.size * Self.size)
        queue      = (0..<3).map { _ in Self.draw() }
        swapsLeft  = 2
        isOver     = false
        lastPlaced = nil
    }

    var current: Plot  { queue[0] }
    var emptyCount: Int { grid.filter { $0 == nil }.count }
    var score: Int     { Self.score(grid) }

    @discardableResult
    func place(at index: Int) -> Bool {
        guard !isOver, grid.indices.contains(index), grid[index] == nil else { return false }
        grid[index] = queue.removeFirst()
        queue.append(Self.draw())
        lastPlaced = index
        if emptyCount == 0 { isOver = true }
        return true
    }

    func swap() {
        guard swapsLeft > 0, !isOver else { return }
        swapsLeft -= 1
        queue.removeFirst()
        queue.append(Self.draw())
    }

    func points(at index: Int) -> Int { Self.points(grid, index) }

    func delta(placing plot: Plot, at index: Int) -> Int {
        var copy = grid; copy[index] = plot
        return Self.score(copy) - score
    }

    private static func draw() -> Plot {
        switch Int.random(in: 0..<100) {
        case 0..<34:  return .house
        case 34..<58: return .garden
        case 58..<76: return .mews
        case 76..<90: return .chapel
        case 90..<96: return .fountain
        default:      return .inn
        }
    }

    static func neighbours(_ i: Int) -> [Int] {
        let r = i / size, c = i % size
        var out: [Int] = []
        if r > 0        { out.append(i - size) }
        if r < size - 1 { out.append(i + size) }
        if c > 0        { out.append(i - 1) }
        if c < size - 1 { out.append(i + 1) }
        return out
    }

    // Fountain bonus: how many fountains are adjacent to index i?
    private static func fountainBonus(_ grid: [Plot?], _ i: Int) -> Int {
        neighbours(i).filter { grid[$0] == .fountain }.count
    }

    static func points(_ grid: [Plot?], _ i: Int) -> Int {
        guard let plot = grid[i] else { return 0 }
        let around = neighbours(i).compactMap { grid[$0] }
        let bonus  = fountainBonus(grid, i)

        switch plot {
        case .house:
            let base = around.filter { $0 == .house }.count
                     + around.filter { $0 == .garden }.count * 2
                     - around.filter { $0 == .mews }.count * 2
            return base + bonus

        case .garden:
            let base = 1 + (around.contains(.chapel) ? 2 : 0)
            return base + bonus

        case .mews:
            let r = i / size, c = i % size
            let onEdge = r == 0 || c == 0 || r == size - 1 || c == size - 1
            let base = (onEdge ? 3 : 0) + (around.contains(.mews) ? 1 : 0)
            return base + bonus

        case .chapel:
            let base = Set(around).count * 2 - (around.contains(.chapel) ? 3 : 0)
            return base + bonus

        case .fountain:
            // Fountain scores 0 itself; its value is reflected in neighbours' points
            return 0

        case .inn:
            // +1 per distinct adjacent type (not counting fountain and not counting nil)
            let distinctTypes = Set(around.filter { $0 != .fountain }).count
            return distinctTypes + bonus
        }
    }

    static func score(_ grid: [Plot?]) -> Int {
        grid.indices.reduce(0) { $0 + points(grid, $1) }
    }
}
