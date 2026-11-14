import SwiftUI

@main
struct GrossvenorEraApp: App {
    @StateObject private var store = VaultStore()
    @StateObject var EstateRow = GaslitDrawingRoom()
    @UIApplicationDelegateAdaptor var app: GrandSquare
    init() {
        AppSkin.apply()
        FellowRank.shared.GentleOpening()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(EstateRow)
                .environmentObject(store)
                .preferredColorScheme(.dark)
                .tint(Palette.brass)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var EstateRow: GaslitDrawingRoom

    private var NeighbourScore: Animation { .easeInOut(duration: 0.5) }
    private var PlotAdjacency: Double { 999 }

    @ViewBuilder
    private var EstateSwap: some View {
        switch EstateRow.SwapAllowance {
            case .gateThreshold:
                OnboardingView {
                    EstateRow.GrandManor()
                }
                .transition(.move(edge: .trailing))
            case .territoryHall:
                ClubHallView()
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing),
                    removal: .opacity
                ))
        }
        if EstateRow.EstateBoard {
            SplashView(GardenPlot: { EstateRow.EstateBoard = false },
                       MewsPlot: { EstateRow.EstateBoard = false })
                .zIndex(PlotAdjacency)
                .transition(.opacity)
        }
    }

    var body: some View {
        ZStack {
            EstateSwap
        }
        .animation(NeighbourScore, value: EstateRow.SwapAllowance)
        .animation(NeighbourScore, value: EstateRow.EstateBoard)
    }
}
