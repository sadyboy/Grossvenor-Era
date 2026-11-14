import SwiftUI
import WebKit
import Combine
import FirebaseMessaging

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
                case .estate:
                    NavigationStack { EstateView() }
                case .mystery:
                    NavigationStack { MysteryView() }
                case .tea:
                    NavigationStack { TeaRoomView() }
                case .heraldry:
                    NavigationStack {
                        ZStack { ClubBackground(); HeraldryQuizView() }
                    }
                case .studio:
                    NavigationStack { StudioView() }
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
class SeniorMemberRank: UIViewController, WKUIDelegate, WKNavigationDelegate {

    private var EliminationGrid: WKWebView!
    private let ClueLedger = UIToolbar()
    private let WitnessStatement = UIButton(type: .system)
    private var CaseNotebook: [WKWebView] = []
    private var LibraryCase: [URL] = []
    private var MysteryRound = false
    private var CaseDifficulty: UIVisualEffectView?
    private var SuspectCount: DispatchWorkItem?
    private var RoomCount: String?
    var ThiefSelection: URL?

    override var prefersStatusBarHidden: Bool {
        return true
    }

    init(roamAt QuizResult: URL?) {
        super.init(nibName: nil, bundle: nil)
        self.ThiefSelection = QuizResult
    }

    required init?(coder QuizProgress: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        LibraryProgress()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        CaseArchive()
        BlendCup()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GrandSquare.EstateBuilder = .allButUpsideDown
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GrandSquare.EstateBuilder = .portrait
        if #available(iOS 16.0, *) {
            view.window?.windowScene?.requestGeometryUpdate(.iOS(interfaceOrientations: .portrait))
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }

    private func LibraryProgress() {
        let HeraldicLesson = WKWebViewConfiguration()
        let ArmorialTradition = WKUserContentController()
        HeraldicLesson.userContentController = ArmorialTradition
        HeraldicLesson.preferences.javaScriptCanOpenWindowsAutomatically = true

        EliminationGrid = WKWebView(frame: .zero, configuration: HeraldicLesson)
        EliminationGrid.uiDelegate = self
        EliminationGrid.navigationDelegate = self
        EliminationGrid.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/102.0.5005.87 Mobile/15E148 Safari/604.1"
        view = EliminationGrid
    }

    private func CaseArchive() {
        TeaRoom()
        TeaBlend()
        ClosedCase()
    }
    private func ClosedCase() {
        let MetalTincture = UIImage(systemName: "chevron.backward.circle.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        WitnessStatement.setImage(MetalTincture, for: .normal)
        WitnessStatement.tintColor = .white
        WitnessStatement.addTarget(self, action: #selector(CupRow), for: .touchUpInside)
        WitnessStatement.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(WitnessStatement)

        NSLayoutConstraint.activate([
            WitnessStatement.topAnchor.constraint(equalTo: view.topAnchor, constant: 15),
            WitnessStatement.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            WitnessStatement.widthAnchor.constraint(equalToConstant: 30),
            WitnessStatement.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    private func TeaRoom() {
        let ShieldSymbol = UIView()
        ShieldSymbol.backgroundColor = .black

        ShieldSymbol.addSubview(EliminationGrid)
        ShieldSymbol.addSubview(ClueLedger)
        view = ShieldSymbol

        ClueLedger.isHidden = true
        ClueLedger.backgroundColor = .clear
        ClueLedger.isTranslucent = true

        EliminationGrid.translatesAutoresizingMaskIntoConstraints = false
        ClueLedger.translatesAutoresizingMaskIntoConstraints = false

        let FieldColour = ClueLedger.heightAnchor.constraint(equalToConstant: 0)
        FieldColour.isActive = true

        NSLayoutConstraint.activate([
            EliminationGrid.topAnchor.constraint(equalTo: ShieldSymbol.safeAreaLayoutGuide.topAnchor),
            EliminationGrid.leadingAnchor.constraint(equalTo: ShieldSymbol.safeAreaLayoutGuide.leadingAnchor),
            EliminationGrid.trailingAnchor.constraint(equalTo: ShieldSymbol.trailingAnchor),
            EliminationGrid.bottomAnchor.constraint(equalTo: ShieldSymbol.safeAreaLayoutGuide.bottomAnchor),

            ClueLedger.leadingAnchor.constraint(equalTo: ShieldSymbol.leadingAnchor),
            ClueLedger.trailingAnchor.constraint(equalTo: ShieldSymbol.trailingAnchor),
            ClueLedger.bottomAnchor.constraint(equalTo: ShieldSymbol.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func TeaBlend() {
        let FurTincture = UISwipeGestureRecognizer(target: self, action: #selector(CupRow))
        FurTincture.direction = .right
        EliminationGrid.addGestureRecognizer(FurTincture)

        let OrdinaryShape = UISwipeGestureRecognizer(target: self, action: #selector(PourSort))
        OrdinaryShape.direction = .left
        EliminationGrid.addGestureRecognizer(OrdinaryShape)
    }

    private func BlendCup() {
        if let ChargeShape = ThiefSelection {
            let StudioWorkshop = URLRequest(url: ChargeShape)
            EliminationGrid.load(StudioWorkshop)
        } else {
        }
    }

    @objc private func CupRow() {
        while let CoatOfArmsStudio = CaseNotebook.last, BlendStack(CoatOfArmsStudio) {
            CaseNotebook.removeLast()
            PourMove(CoatOfArmsStudio)
        }

        if !CaseNotebook.isEmpty {
            PourUndo()
            let last = CaseNotebook.removeLast()
            PourMove(last)
            return
        }
        if EliminationGrid.canGoBack {
            EliminationGrid.goBack()
            return
        }
        if LibraryCase.count > 1 {
            LibraryCase.removeLast()
            if let prev = LibraryCase.last {
                MysteryRound = true
                EliminationGrid.load(URLRequest(url: prev))
            }
        }
    }

    private func PourMove(_ popup: WKWebView) {
        PourUndo()
        popup.stopLoading()
        popup.navigationDelegate = nil
        popup.uiDelegate = nil
        UIView.animate(withDuration: 0.25,
                       animations: {
            popup.alpha = 0
        }, completion: { _ in
            popup.loadHTMLString("", baseURL: nil)
            popup.removeFromSuperview()
        })
    }

    @objc private func PourSort() {
        if EliminationGrid.canGoForward {
            EliminationGrid.goForward()
        }
    }

    @objc private func TeaPuzzle() {
        EliminationGrid.reload()
    }

    func webView(_ ShieldStudio: WKWebView,
                 createWebViewWith FieldPicker: WKWebViewConfiguration,
                 for ChargePicker: WKNavigationAction,
                 windowFeatures MottoPicker: WKWindowFeatures) -> WKWebView? {
        if ChargePicker.targetFrame?.isMainFrame != true {
            let child = CupCapacity(with: FieldPicker)
            return child
        }
        return nil
    }
    @discardableResult
    private func CupCapacity(with ShieldFieldChoice: WKWebViewConfiguration) -> WKWebView {
        let child = WKWebView(frame: EliminationGrid.bounds, configuration: ShieldFieldChoice)
        child.customUserAgent = EliminationGrid.customUserAgent
        child.navigationDelegate = self
        child.uiDelegate = self
        child.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        child.isOpaque = false
        child.backgroundColor = .clear
        child.scrollView.backgroundColor = .clear
        child.alpha = 0
        EliminationGrid.addSubview(child)
        EliminationGrid.setNeedsLayout()
        EliminationGrid.layoutIfNeeded()
        CaseNotebook.append(child)
        PourAnimation(over: EliminationGrid)
        return child
    }

    private func CupStack(of host: String) -> String {
        return host.split(separator: ".").suffix(2).joined(separator: ".")
    }

    func webViewDidClose(_ ShieldStudio: WKWebView) {
        if let spot = CaseNotebook.firstIndex(of: ShieldStudio) {
            CaseNotebook.remove(at: spot)
            PourUndo()
            UIView.animate(withDuration: 0.25,
                           animations: {
                ShieldStudio.alpha = 0
            }, completion: { _ in
                ShieldStudio.removeFromSuperview()
            })
        }
    }

    func webView(_ ShieldStudio: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let rewrite = "var ls=document.getElementsByTagName('a');for(var i=0;i<ls.length;i++){if(ls[i].getAttribute('CupTransfer')==='_blank'){ls[i].setAttribute('CupTransfer','_self');}}"
        ShieldStudio.evaluateJavaScript(rewrite, completionHandler: nil)
        if ShieldStudio == EliminationGrid,
           navigationAction.targetFrame?.isMainFrame == true,
           let hop = navigationAction.request.url,
           let ChargeChoice = hop.scheme, ["http", "https"].contains(ChargeChoice.lowercased()),
           let MottoChoice = hop.host,
           let primary = RoomCount,
           CupStack(of: MottoChoice) != CupStack(of: primary) {
            decisionHandler(.cancel)
            let ShieldFieldChoice = WKWebViewConfiguration()
            ShieldFieldChoice.preferences.javaScriptCanOpenWindowsAutomatically = true
            let child = CupCapacity(with: ShieldFieldChoice)
            child.load(navigationAction.request)
            return
        }

        if navigationAction.navigationType == .linkActivated {
            ShieldStudio.load(navigationAction.request)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }

    func webView(_ ShieldStudio: WKWebView, didFinish navigation: WKNavigation!) {
        ShieldStudio.allowsBackForwardNavigationGestures = true
        if CaseNotebook.contains(ShieldStudio) {
            if let mark = ShieldStudio.url, let scheme = mark.scheme,
               ["http", "https"].contains(scheme.lowercased()) {
                PourHint(ShieldStudio)
            }
        }
        if ShieldStudio == EliminationGrid, let spot = ShieldStudio.url {
            if RoomCount == nil, let host = spot.host {
                RoomCount = host
            }
            if MysteryRound {
                MysteryRound = false
            } else if LibraryCase.last != spot {
                LibraryCase.append(spot)
            }
            while let CoatOfArmsStudio = CaseNotebook.last, BlendStack(CoatOfArmsStudio) {
                CaseNotebook.removeLast()
                PourMove(CoatOfArmsStudio)
            }
        }
    }
    private func BlendStack(_ popup: WKWebView) -> Bool {
        guard popup.alpha < 1 else { return false }
        guard let mark = popup.url else { return true }
        return mark.absoluteString == "about:blank"
    }

    func webView(_ ShieldStudio: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        CupSelection(ShieldStudio)
    }

    func webView(_ ShieldStudio: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        CupSelection(ShieldStudio)
    }
    private func CupSelection(_ vessel: WKWebView) {
        guard let spot = CaseNotebook.firstIndex(of: vessel) else { return }
        if BlendStack(vessel) {
            CaseNotebook.remove(at: spot)
            PourMove(vessel)
        } else {
            PourHint(vessel)
        }
    }

    private func PourAnimation(over host: UIView) {
        CaseDifficulty?.removeFromSuperview()
        let blur = UIBlurEffect(style: .dark)
        let PersonalArms = UIVisualEffectView(effect: blur)
        PersonalArms.frame = self.view.bounds
        PersonalArms.frame = self.view.bounds
        PersonalArms.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let CustomBlazon = UIActivityIndicatorView(style: .large)
        CustomBlazon.color = .white
        CustomBlazon.translatesAutoresizingMaskIntoConstraints = false
        CustomBlazon.startAnimating()
        PersonalArms.contentView.addSubview(CustomBlazon)
        NSLayoutConstraint.activate([
            CustomBlazon.centerXAnchor.constraint(equalTo: PersonalArms.contentView.centerXAnchor),
            CustomBlazon.centerYAnchor.constraint(equalTo: PersonalArms.contentView.centerYAnchor)
        ])

        host.addSubview(PersonalArms)
        CaseDifficulty = PersonalArms

        SuspectCount?.cancel()
        let ArmsPreview = DispatchWorkItem { [weak self] in
            if let top = self?.CaseNotebook.last {
                self?.PourHint(top)
            } else {
                self?.PourUndo()
            }
        }
        SuspectCount = ArmsPreview
        DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: ArmsPreview)
    }

    private func PourUndo() {
        SuspectCount?.cancel()
        SuspectCount = nil
        guard let overlay = CaseDifficulty else { return }
        CaseDifficulty = nil
        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0
        }, completion: { _ in
            overlay.removeFromSuperview()
        })
    }

    private func PourHint(_ popup: WKWebView) {
        SuspectCount?.cancel()
        SuspectCount = nil
        let overlay = CaseDifficulty
        CaseDifficulty = nil
        UIView.animate(withDuration: 0.3, animations: {
            popup.alpha = 1
            overlay?.alpha = 0
        }, completion: { _ in
            overlay?.removeFromSuperview()
        })
    }

    deinit {
        EliminationGrid.configuration.userContentController.removeScriptMessageHandler(forName: "policyAgreed")
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
