import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var store: VaultStore
    @Environment(\.dismiss) private var dismiss
    @AppStorage("profile.name")      private var memberName = ""
    @AppStorage("profile.avatar")    private var avatarIndex = 0
    @AppStorage("profile.photoData") private var photoData = Data()
    @State private var editingName = false
    @State private var nameInput = ""
    @State private var showJournal = false
    @State private var showPhotoOptions = false
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    private let avatarSymbols = ["crown", "star", "shield", "flame", "leaf.fill",
                                  "moon.stars.fill", "bolt.fill", "diamond.fill"]

    private var profileImage: UIImage? {
        photoData.isEmpty ? nil : UIImage(data: photoData)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ClubBackground()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        avatarSection
                        memberInfoSection
                        prestigeSection
                        recordsSection
                        journalSection
                    }
                    .padding(16).padding(.bottom, 32)
                }
            }
            .navigationTitle("Your Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }.foregroundStyle(Palette.brassLight)
            }}
        }
        .onAppear { nameInput = memberName }
        .sheet(isPresented: $showJournal) { JournalView() }
        .sheet(isPresented: $showCamera) {
            CameraImagePicker(imageData: $photoData)
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data),
                   let compressed = uiImage.jpegData(compressionQuality: 0.75) {
                    photoData = compressed
                }
            }
        }
        .confirmationDialog("Profile Photo", isPresented: $showPhotoOptions, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") { showCamera = true }
            }
            Button("Choose from Library") { showPhotoPicker = true }
            if !photoData.isEmpty {
                Button("Remove Photo", role: .destructive) {
                    photoData = Data()
                    Haptics.select()
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle()
                        .fill(Palette.brassGradient)
                        .frame(width: 100, height: 100)
                    if let img = profileImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: avatarSymbols[avatarIndex])
                            .font(.system(size: 42)).foregroundStyle(Palette.ink)
                    }
                }
                .shadow(color: Palette.brass.opacity(0.5), radius: 10, y: 4)

                Button {
                    showPhotoOptions = true
                    Haptics.select()
                } label: {
                    ZStack {
                        Circle().fill(Palette.brassDeep).frame(width: 30, height: 30)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 13)).foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .offset(x: 4, y: 4)
            }

            if profileImage == nil {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                    ForEach(Array(avatarSymbols.enumerated()), id: \.offset) { i, symbol in
                        Button { avatarIndex = i; Haptics.select() } label: {
                            ZStack {
                                Circle().fill(avatarIndex == i
                                              ? AnyShapeStyle(Palette.brassGradient)
                                              : AnyShapeStyle(Palette.parchment.opacity(0.7)))
                                    .frame(width: 52, height: 52)
                                Image(systemName: symbol).font(.system(size: 22))
                                    .foregroundStyle(avatarIndex == i ? Palette.ink : Palette.brassDeep)
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Avatar \(symbol)" + (avatarIndex == i ? ", selected" : ""))
                    }
                }
            }
        }
        .parchmentCard()
    }

    private var memberInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Member Name").eyebrow(onLight: true)
            if editingName {
                HStack(spacing: 10) {
                    TextField("Your name", text: $nameInput)
                        .font(.display(18)).foregroundStyle(Palette.inkText)
                        .submitLabel(.done)
                        .onSubmit { saveName() }
                    Button { saveName() } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24)).foregroundStyle(Palette.greenMid)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                HStack {
                    Text(memberName.isEmpty ? "Tap to set your name" : memberName)
                        .font(.display(20, .semibold)).foregroundStyle(Palette.inkText)
                        .onTapGesture { nameInput = memberName; editingName = true }
                    Spacer()
                    CircleIconButton(symbol: "pencil", label: "Edit name") {
                        nameInput = memberName; editingName = true
                    }
                }
            }
        }
        .parchmentCard()
    }

    private var prestigeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Standing").eyebrow(onLight: true)
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(store.prestige)")
                        .font(.display(32, .semibold)).foregroundStyle(Palette.brassDeep)
                    Text("Prestige Points").font(.text(13)).foregroundStyle(Palette.mutedText)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(store.rank.title)
                        .font(.display(20, .semibold)).foregroundStyle(Palette.brassDeep)
                    Text("Current Rank").font(.text(13)).foregroundStyle(Palette.mutedText)
                }
            }
            if let next = store.nextRank {
                let needed = next.threshold - store.prestige
                Text("\(needed) prestige until \(next.title)")
                    .font(.text(13)).italic().foregroundStyle(Palette.mutedText)
                ProgressView(value: store.progressToNext)
                    .tint(Palette.brassLight)
            } else {
                Text("You have reached the highest rank. The Club bows.")
                    .font(.text(13)).italic().foregroundStyle(Palette.mutedText)
            }
        }
        .parchmentCard()
    }

    private var recordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("House Records").eyebrow(onLight: true)
            ForEach(Room.allCases, id: \.self) { room in
                let best = store.best(for: room)
                HStack {
                    Image(systemName: room.symbol).font(.system(size: 15))
                        .foregroundStyle(Palette.brassDeep).frame(width: 24)
                    Text(room.title).font(.display(15, .regular)).foregroundStyle(Palette.inkText)
                    Spacer()
                    Text(best > 0 ? "\(best)" : "—")
                        .font(.display(15, .semibold))
                        .foregroundStyle(best > 0 ? Palette.brassDeep : Palette.mutedText)
                }
            }
        }
        .parchmentCard()
    }

    private var journalSection: some View {
        Button {
            showJournal = true
            Haptics.select()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 20)).foregroundStyle(Palette.brassDeep)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Club Journal").font(.display(16, .semibold)).foregroundStyle(Palette.inkText)
                    Text("Your record of past sessions").font(.text(13)).foregroundStyle(Palette.mutedText)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold)).foregroundStyle(Palette.brass.opacity(0.6))
            }
        }
        .buttonStyle(.plain)
        .parchmentCard()
    }

    private func saveName() {
        memberName = nameInput.trimmingCharacters(in: .whitespaces)
        editingName = false
    }
}

struct ProfileAvatarButton: View {
    @AppStorage("profile.avatar")    private var avatarIndex = 0
    @AppStorage("profile.photoData") private var photoData = Data()
    private let symbols = ["crown","star","shield","flame","leaf.fill","moon.stars.fill","bolt.fill","diamond.fill"]
    let onTap: () -> Void

    private var profileImage: UIImage? {
        photoData.isEmpty ? nil : UIImage(data: photoData)
    }

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle().fill(Palette.brassGradient).frame(width: 38, height: 38)
                if let img = profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 38, height: 38)
                        .clipShape(Circle())
                } else {
                    Image(systemName: symbols[avatarIndex])
                        .font(.system(size: 17)).foregroundStyle(Palette.ink)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Your profile")
    }
}

struct CameraImagePicker: UIViewControllerRepresentable {
    @Binding var imageData: Data
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraImagePicker

        init(_ parent: CameraImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.75) {
                parent.imageData = data
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
