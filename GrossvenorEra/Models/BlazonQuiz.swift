import Foundation
import Combine

final class BlazonQuiz: ObservableObject {
    enum Phase { case intro, playing, over }

    static let duration: Double = 60

    @Published private(set) var arms      = Arms.sample
    @Published private(set) var options:    [String] = []
    @Published private(set) var score      = 0
    @Published private(set) var streak     = 0
    @Published private(set) var correct    = 0
    @Published private(set) var timeLeft   = BlazonQuiz.duration
    @Published private(set) var phase: Phase = .intro
    @Published private(set) var picked: String?
    @Published private(set) var round      = 0

    private var timer: Timer?

    func start() {
        score = 0; streak = 0; correct = 0; timeLeft = Self.duration
        nextQuestion()
        phase = .playing
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard phase == .playing else { return }
        timeLeft = max(0, timeLeft - 0.1)
        if timeLeft <= 0 { finish() }
    }

    func answer(_ option: String) {
        guard picked == nil, phase == .playing else { return }
        picked = option
        if option == arms.blazon {
            streak += 1; correct += 1
            score += 100 + 25 * (streak - 1)
            Haptics.success()
        } else {
            streak = 0
            timeLeft = max(0, timeLeft - 3)
            Haptics.error()
        }
        let answeredRound = round
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [weak self] in
            guard let self, self.phase == .playing, self.round == answeredRound else { return }
            self.nextQuestion()
        }
    }

    private func nextQuestion() {
        let q = HeraldryGenerator.question()
        arms = q.arms; options = q.options; picked = nil; round += 1
    }

    private func finish() {
        timer?.invalidate(); timer = nil; phase = .over
    }

    func reset() { stop(); phase = .intro }

    func stop() { timer?.invalidate(); timer = nil }

    deinit { timer?.invalidate() }
}
