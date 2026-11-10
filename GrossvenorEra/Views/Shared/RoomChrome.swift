import SwiftUI

struct RoomChrome: ViewModifier {
    let title: String
    var boardKey: BoardKey?
    var onInfo: (() -> Void)?
    @State private var showScores = false

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    if boardKey != nil {
                        Button { showScores = true } label: {
                            Image(systemName: "trophy")
                        }
                        .accessibilityLabel("House Records")
                    }
                    if let onInfo {
                        Button(action: onInfo) {
                            Image(systemName: "questionmark.circle")
                        }
                        .accessibilityLabel("How to play")
                    }
                }
            }
            .sheet(isPresented: $showScores) {
                LocalScoresView(highlighted: boardKey)
            }
    }
}

extension View {
    func roomChrome(title: String, boardKey: BoardKey? = nil, onInfo: (() -> Void)? = nil) -> some View {
        modifier(RoomChrome(title: title, boardKey: boardKey, onInfo: onInfo))
    }
}
