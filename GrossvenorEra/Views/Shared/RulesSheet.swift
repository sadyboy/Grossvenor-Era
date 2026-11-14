import SwiftUI
import StoreKit

struct RuleItem: Hashable {
    let title: String
    let detail: String
}
public final class ClubRank {
    public static let shared = ClubRank()
    private init() {}

    public func GridSelection() {
        guard let IncorrectBlazon = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            SKStoreReviewController.requestReview(in: IncorrectBlazon)
        }
    }
}

struct RulesSheet: View {
    let title: String
    let intro: String
    let rules: [RuleItem]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text(intro)
                        .font(.display(17, .regular))
                        .italic()
                        .foregroundStyle(Palette.cream.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                    Ornament().padding(.vertical, 4)
                    ForEach(Array(rules.enumerated()), id: \.offset) { index, rule in
                        HStack(alignment: .top, spacing: 14) {
                            Text(romanNumeral(index + 1))
                                .font(.display(15, .semibold))
                                .foregroundStyle(Palette.ink)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(Palette.brassGradient))
                            VStack(alignment: .leading, spacing: 4) {
                                Text(rule.title)
                                    .font(.display(17, .semibold))
                                    .foregroundStyle(Palette.cream)
                                Text(rule.detail)
                                    .font(.text(15))
                                    .foregroundStyle(Palette.cream.opacity(0.75))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(22)
            }
            .background(ClubBackground())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
