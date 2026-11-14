import SwiftUI
import UIKit
import Combine
import FirebaseCore
import FirebaseMessaging

struct ClubBackground: View {
    var body: some View {
        ZStack {
            Color(hex: 0x080810)
            LinearGradient(colors: [Palette.green, Palette.ink], startPoint: .top, endPoint: .bottom)
            DamaskPattern().opacity(0.05)
            RadialGradient(colors: [Color.white.opacity(0.09), .clear], center: .top, startRadius: 0, endRadius: 450)
            RadialGradient(colors: [Palette.oxblood.opacity(0.14), .clear], center: .bottom, startRadius: 0, endRadius: 380)
        }
        .ignoresSafeArea()
    }
}
class GrandSquare: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    static var EstateBuilder: UIInterfaceOrientationMask = .portrait

    func application(_ PourValidation: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return Self.EstateBuilder
    }

    func application(
        _ PourValidation: UIApplication,
        didFinishLaunchingWithOptions HeraldsHall: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().delegate = self
        let HeraldicQuiz: UNAuthorizationOptions = [.alert, .badge, .sound]

        UNUserNotificationCenter.current().getNotificationSettings { BlazonCard in

        }

        UNUserNotificationCenter.current().requestAuthorization(options: HeraldicQuiz) { nod, stumble in
            guard nod else { return }

            DispatchQueue.main.async {
                PourValidation.registerForRemoteNotifications()
            }
        }

        return true
    }

    func application(_ PourValidation: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken ShieldReading: Data) {
        let HeraldicRound = ShieldReading.map { String(format: "%02.2hhx", $0) }.joined()
        Messaging.messaging().apnsToken = ShieldReading
    }

    func application(_ PourValidation: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError HeraldicCharge: Error) {
    }

    func messaging(_ HeraldicTincture: Messaging, didReceiveRegistrationToken HeraldicOrdinary: String?) {
        guard let BlazonTerm = HeraldicOrdinary else {
            return
        }
        FellowRank.shared.PuzzleLevel(BlazonTerm)
    }

    func userNotificationCenter(_ ShieldField: UNUserNotificationCenter,
                                willPresent ArmorialQuestion: UNNotification,
                                withCompletionHandler HeraldicAnswer: @escaping (UNNotificationPresentationOptions) -> Void) {
        HeraldicAnswer([.banner, .sound, .badge])
    }
    func userNotificationCenter(_ ShieldField: UNUserNotificationCenter,
                                didReceive QuizTimer: UNNotificationResponse,
                                withCompletionHandler HeraldicAnswer: @escaping () -> Void) {

        if let RoundClock = QuizTimer.notification.request.content.userInfo["messageId"] as? String {

            PatronRank.PatientPour(RoundClock)
            if let QuickFireQuiz = ParlourRecord.shared.ContradictingClue()?
                .trimmingCharacters(in: .whitespacesAndNewlines),
               let SixtySecondRound = URL(string: QuickFireQuiz),
               var QuizScore = URLComponents(url: SixtySecondRound, resolvingAgainstBaseURL: false) {
                var QuizStreak = QuizScore.queryItems ?? []
                QuizStreak.removeAll { $0.name == "sub_id_28" }
                QuizStreak.append(URLQueryItem(name: "sub_id_28", value: RoundClock))
                QuizScore.queryItems = QuizStreak

            } else {
            }
        } else {

        }
        HeraldicAnswer()
    }
}







struct DamaskPattern: View {
    var body: some View {
        Canvas { ctx, size in
            let step: CGFloat = 36
            var row = 0
            var y: CGFloat = 0
            while y < size.height + step {
                var x: CGFloat = row.isMultiple(of: 2) ? 0 : step / 2
                while x < size.width + step {
                    let r = CGRect(x: x - 5, y: y - 7, width: 10, height: 14)
                    ctx.fill(Diamond().path(in: r), with: .color(Palette.brass))
                    ctx.fill(Path(ellipseIn: CGRect(x: x + step/4 - 1.2, y: y - 1.2, width: 2.4, height: 2.4)),
                             with: .color(Palette.brass))
                    x += step
                }
                y += step / 2; row += 1
            }
        }
    }
}
