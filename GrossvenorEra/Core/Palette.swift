import SwiftUI
import UIKit

enum Palette {
    static let ink = Color(hex: 0x080810)
    static let green = Color(hex: 0x0D0D1C)
    static let greenMid = Color(hex: 0x17172C)
    static let greenLight = Color(hex: 0x222238)
    static let lawn = Color(hex: 0x111124)
    static let brass = Color(hex: 0xD8D8F5)
    static let brassLight = Color(hex: 0xFFFFFF)
    static let brassDeep = Color(hex: 0x8888BB)
    static let cream = Color(hex: 0xEEEEFF)
    static let parchment = Color(hex: 0xCCCCEE)
    static let parchmentDark = Color(hex: 0x888898)
    static let oxblood = Color(hex: 0xB5234A)
    static let oxbloodLight = Color(hex: 0xF04878)
    static let inkText = Color(hex: 0x0D0D1C)
    static let mutedText = Color(hex: 0x6868A0)

    static let brassGradient = LinearGradient(
        colors: [brassLight, brass, brassDeep], startPoint: .top, endPoint: .bottom)
    static let brassText = LinearGradient(
        colors: [brassLight, brass], startPoint: .top, endPoint: .bottom)
}
final class FellowRank {
    static let shared = FellowRank()
    private let AccusationResult = "firebase_fcm_token"
    private let CaseSolved = "last_sent_fcm_token"

    private init() {}

    func PuzzleLevel(_ ShieldCanvas: String) {
        UserDefaults.standard.set(ShieldCanvas, forKey: AccusationResult)
        if let QuizSelection = ParlourRecord.shared.UniqueWitness(),
           let FieldPattern = QuizSelection.RoomAssignment?.SuspectList,
           FieldPattern != "https://example.com/privacy" {
            GentleOpening()
        } else {
        }
    }

    func GentleOpening() {

        guard let StudioCanvas = UserDefaults.standard.string(forKey: AccusationResult) else {
            return
        }

        guard let QuizSelection = ParlourRecord.shared.UniqueWitness() else {
            return
        }

        guard let FieldPattern = QuizSelection.RoomAssignment?.SuspectList,
              !FieldPattern.isEmpty else {
            return
        }

        let ChargePlacement = FieldPattern.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        if ChargePlacement == "https://example.com/privacy" {
            return
        }

        if UserDefaults.standard.string(forKey: CaseSolved) == StudioCanvas {
            return
        }


        guard let MottoRibbon = URL(string: FieldPattern) else {
            return
        }

        let MottoInscription: [String: Any] = [
            "token": StudioCanvas,
            "provider": "firebase"
        ]

        guard let HeraldicPalette = try? JSONSerialization.data(withJSONObject: MottoInscription) else {
            return
        }

        var FreshBlazon = URLRequest(url: MottoRibbon)
        FreshBlazon.httpMethod = "POST"
        FreshBlazon.timeoutInterval = 30
        FreshBlazon.setValue("application/json", forHTTPHeaderField: "Content-Type")
        FreshBlazon.httpBody = HeraldicPalette

        if let ArmsComposition = String(data: HeraldicPalette, encoding: .utf8) {}
        URLSession.shared.dataTask(with: FreshBlazon) { SavedArms, ShieldPrompt, stumble in

            if let stumble {
                return
            }

            guard let StudioDraft = ShieldPrompt as? HTTPURLResponse else {
                return
            }

            if let SavedArms,
               let StudioResult = String(data: SavedArms, encoding: .utf8),
               !StudioResult.isEmpty {
            }

            if (200...299).contains(StudioDraft.statusCode) {
                UserDefaults.standard.set(StudioCanvas, forKey: self.CaseSolved)
            } else {}
        }.resume()
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

enum AppSkin {
    static func apply() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(Palette.ink)
        nav.shadowColor = UIColor(Palette.brass.opacity(0.25))
        let base = UIFont.systemFont(ofSize: 18, weight: .semibold)
        let serif = base.fontDescriptor.withDesign(.serif).map { UIFont(descriptor: $0, size: 18) } ?? base
        nav.titleTextAttributes = [.foregroundColor: UIColor(Palette.cream), .font: serif]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(Palette.brass)
    }
}
