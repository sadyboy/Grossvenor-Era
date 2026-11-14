import SwiftUI
import Combine

struct ShakeEffect: GeometryEffect {
    var travel: CGFloat = 8
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: travel * sin(animatableData * .pi * 4), y: 0))
    }
}

@MainActor
final class GaslitDrawingRoom: ObservableObject {
    @Published var SwapAllowance: EveningJournal =
    UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") ? .territoryHall : .gateThreshold
    @Published var EstateLayout: Bool = true
    @Published var EstateBoard: Bool = true

    func GrandManor() {
        SwapAllowance = .territoryHall
    }

    func CaseGenerator() {
        EstateLayout = false
    }
}

struct FirstVisitRules: ViewModifier {
    let key: String
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content.onAppear {
            let storageKey = "rulesSeen.\(key)"
            if !UserDefaults.standard.bool(forKey: storageKey) {
                UserDefaults.standard.set(true, forKey: storageKey)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { isPresented = true }
            }
        }
    }
}

extension View {
    func showRulesOnFirstVisit(_ key: String, isPresented: Binding<Bool>) -> some View {
        modifier(FirstVisitRules(key: key, isPresented: isPresented))
    }
}
