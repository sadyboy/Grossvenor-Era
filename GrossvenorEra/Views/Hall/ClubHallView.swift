import SwiftUI

enum RoomDestination: Identifiable {
    case estate, mystery, tea, heraldry, studio
    var id: Self { self }
}

struct ClubHallView: View {
    @EnvironmentObject private var store: VaultStore
    @AppStorage("profile.name") private var memberName = ""
    @State private var destination: RoomDestination?
    @State private var showScores = false

    private let rooms: [(RoomDestination, Room)] = [
        (.estate,  .estate),
        (.mystery, .mystery),
        (.tea,     .tea),
        (.heraldry,.heraldry),
        (.studio,  .studio),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                ClubBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        memberCard
                        SectionHeading(title: "Rooms of the Club")
                        LazyVGrid(columns: [GridItem(.flexible(), spacing: 14),
                                            GridItem(.flexible(), spacing: 14)],
                                  spacing: 14) {
                            ForEach(rooms, id: \.0) { dest, room in
                                RoomCard(room: room) { destination = dest }
                            }
                        }
                        HStack(spacing: 10) {
                            StatPill(label: "Prestige", value: "\(store.prestige)")
                            Spacer()
                            Button { showScores = true } label: {
                                Label("House Records", systemImage: "trophy")
                            }
                            .buttonStyle(ChipButtonStyle())
                        }
                        SecretaryNotice().padding(.top, 4)
                    }
                    .padding(16).padding(.bottom, 32)
                }
            }
            .navigationTitle("Grosvenor Club")
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $destination) { dest in
                switch dest {
                case .estate:  EstateView()
                case .mystery: MysteryView()
                case .tea:     TeaRoomView()
                case .heraldry:
                    NavigationStack {
                        ZStack { ClubBackground(); HeraldryQuizView() }
                    }
                case .studio: StudioView()
                }
            }
            .sheet(isPresented: $showScores) { LocalScoresView() }
        }
        .environmentObject(store)
    }

    private var memberCard: some View {
        HStack(spacing: 14) {
            ClubCrest()
                .frame(width: 68, height: 68)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(Palette.brassGradient, lineWidth: 2))
                .shadow(color: .black.opacity(0.3), radius: 6, y: 3)
            VStack(alignment: .leading, spacing: 4) {
                Text(memberName.isEmpty ? "Member" : memberName)
                    .font(.display(20, .semibold)).foregroundStyle(Palette.inkText)
                Text(store.rank.title)
                    .font(.smallCaps(13)).tracking(1.5).foregroundStyle(Palette.brassLight)
                Text("Prestige · \(store.prestige)")
                    .font(.display(12, .regular)).italic().foregroundStyle(Palette.mutedText)
            }
            Spacer(minLength: 0)
        }
        .parchmentCard()
    }
}

struct RoomCard: View {
    let room: Room
    let onEnter: () -> Void

    var body: some View {
        Button(action: onEnter) {
            VStack(alignment: .leading, spacing: 10) {
                RoomArt(room: room)
                    .frame(height: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text(room.title).font(.display(16, .semibold)).foregroundStyle(Palette.inkText).lineLimit(1)
                    Text(room.subtitle).font(.display(12, .regular)).italic()
                        .foregroundStyle(Palette.mutedText).lineLimit(2)
                        .minimumScaleFactor(0.85)
                }
                Spacer(minLength: 4)
                Label("Enter", systemImage: "arrow.right.circle")
                    .font(.system(size: 12, weight: .semibold)).foregroundStyle(Palette.brassLight)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Palette.parchment.opacity(0.9))
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(Palette.brassDeep.opacity(0.5), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .accessibilityLabel("\(room.title). \(room.subtitle). Enter.")
    }
}

struct RoomArt: View {
    let room: Room

    var body: some View {
        switch room {
        case .estate:  EstatePlanArt().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .mystery: MagnifierArt().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .tea:     TeacupArt().frame(maxWidth: .infinity, maxHeight: .infinity)
        case .heraldry: ArmsPanelArt()
        case .studio:  TrophyArt().frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct ArmsPanelArt: View {
    private let samples: [Arms] = [
        Arms(field: .azure, ordinary: .cross, ordinaryTincture: .argent),
        Arms(division: .perPale, field: .gules, field2: .or, charge: .mullet, chargeTincture: .argent),
        Arms(field: .or, ordinary: .chevron, ordinaryTincture: .sable, charge: .roundel, chargeTincture: .gules),
    ]
    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(samples.enumerated()), id: \.offset) { _, arms in
                HeraldicShield(arms: arms, borderWidth: 1.5)
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 4)
        .background(Color(hex: 0x1A1200))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct MembershipCard: View {
    @AppStorage("profile.name")  private var memberName = ""
    @EnvironmentObject private var store: VaultStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("GROSVENOR CLUB").font(.smallCaps(10)).tracking(2).foregroundStyle(Palette.brassDeep)
                    Text(memberName.isEmpty ? "Member" : memberName)
                        .font(.display(22, .semibold)).foregroundStyle(Palette.inkText)
                }
                Spacer()
                ClubCrest().frame(width: 52, height: 52)
                    .clipShape(Circle()).overlay(Circle().strokeBorder(Palette.brassGradient, lineWidth: 1.5))
            }
            Divider().overlay(Palette.brassDeep.opacity(0.35))
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PRESTIGE").font(.smallCaps(9)).tracking(1.5).foregroundStyle(Palette.mutedText)
                    Text("\(store.prestige)").font(.display(16, .semibold)).foregroundStyle(Palette.brassDeep)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("RANK").font(.smallCaps(9)).tracking(1.5).foregroundStyle(Palette.mutedText)
                    Text(store.rank.title).font(.display(16, .semibold)).foregroundStyle(Palette.brassDeep)
                }
                Spacer()
                Text("EST. MDCCCXLVII")
                    .font(.display(10, .regular)).italic().foregroundStyle(Palette.mutedText)
            }
        }
        .padding(16)
        .background(LinearGradient(colors: [Palette.parchment, Palette.parchmentDark], startPoint: .top, endPoint: .bottom))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(Palette.brassGradient, lineWidth: 1.5))
        .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
    }
}

struct SecretaryNotice: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "scroll").font(.system(size: 18)).foregroundStyle(Palette.brassDeep)
            Text("All game records are kept locally on your device. Play the five rooms of the Club to build prestige and climb the register.")
                .font(.display(13, .regular)).italic().foregroundStyle(Palette.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Palette.parchment.opacity(0.4)))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
            .strokeBorder(Palette.brassDeep.opacity(0.3), lineWidth: 1))
    }
}
