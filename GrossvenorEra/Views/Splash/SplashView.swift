import SwiftUI

struct SplashView: View {
    @Binding var isShowing: Bool

    @State private var scale: CGFloat = 0.7
    @State private var opacity: Double = 0
    @State private var taglineOpacity: Double = 0

    var body: some View {
        ZStack {
            ClubBackground()
            VStack(spacing: 24) {
                ClubCrest()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().strokeBorder(Palette.brassGradient, lineWidth: 3))
                    .shadow(color: Palette.brass.opacity(0.5), radius: 20, y: 8)
                    .scaleEffect(scale)
                    .opacity(opacity)
                VStack(spacing: 6) {
                    Text("GROSVENOR ERA")
                        .font(.smallCaps(22)).tracking(4).foregroundStyle(Palette.brassLight)
                    Text("A Mayfair Parlour Club")
                        .font(.display(16, .regular)).italic().foregroundStyle(Palette.mutedText)
                }
                .opacity(taglineOpacity)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                scale = 1; opacity = 1
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.4)) { taglineOpacity = 1 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation(.easeOut(duration: 0.5)) { isShowing = false }
            }
        }
    }
}
