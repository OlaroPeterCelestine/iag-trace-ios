import SwiftUI
import TraceCore

@main
struct TraceIOSApp: App {
    @StateObject private var box = StoreBox()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(box)
                .tint(IagTheme.orange)
        }
    }
}

final class StoreBox: ObservableObject {
    let store: TraceStore
    @Published var tick: Int = 0

    init() {
        let store = TraceStore(persistence: UserDefaultsStore())
        store.load()
        self.store = store
        store.addListener { [weak self] in
            DispatchQueue.main.async { self?.tick += 1 }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var box: StoreBox
    @State private var showSplash = true

    var body: some View {
        let _ = box.tick
        ZStack {
            Group {
                if box.store.isSignedIn {
                    ShellView()
                } else {
                    LoginView()
                }
            }
            if showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.35) {
                withAnimation(.easeOut(duration: 0.35)) { showSplash = false }
            }
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            IagBrandLogo(height: 132)
                .padding(.horizontal, 40)
        }
        .preferredColorScheme(.dark)
    }
}

enum IagTheme {
    static let orange = Color(red: 249 / 255, green: 115 / 255, blue: 22 / 255)
    static let orangeDeep = Color(red: 234 / 255, green: 88 / 255, blue: 12 / 255)
    static let success = Color(red: 5 / 255, green: 150 / 255, blue: 105 / 255)
    static let canvas = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let muted = Color.secondary
    static let radius: CGFloat = 16
}

let iagOrange = IagTheme.orange
let iagSlate = Color(.label)
let iagEmerald = IagTheme.success

func iagGreeting() -> String {
    let hour = Calendar.current.component(.hour, from: Date())
    if hour < 12 { return "Good morning" }
    if hour < 17 { return "Good afternoon" }
    return "Good evening"
}

func statusColor(_ status: String) -> Color {
    let s = status.lowercased()
    if ["paid", "approved", "active", "live", "complete", "valid", "received", "pass", "open"].contains(where: { s.contains($0) }) {
        return IagTheme.success
    }
    if ["reject", "void", "cancel", "revok"].contains(where: { s.contains($0) }) {
        return Color.red
    }
    if ["pending", "open", "draft", "follow", "incomplete"].contains(where: { s.contains($0) }) {
        return IagTheme.orange
    }
    return IagTheme.muted
}

func routeIcon(_ route: TraceRoute) -> String {
    switch route.id {
    case "overview": return "square.grid.2x2"
    case "farmers": return "person.2"
    case "intake": return "person.badge.plus"
    case "farms": return "map"
    case "batches": return "cube.box"
    case "chain", "events": return "arrow.triangle.swap"
    case "qr", "lookup": return "qrcode.viewfinder"
    case "lab": return "flask"
    case "compliance": return "checkmark.seal"
    case "harvest-requests": return "shippingbox"
    case "export": return "airplane"
    default:
        switch route.group {
        case .network: return "leaf"
        case .trace: return "point.3.connected.trianglepath.dotted"
        case .quality: return "checkmark.seal"
        case .commerce: return "cart"
        case .field: return "mappin.and.ellipse"
        case .hub: return "building.2"
        case .access: return "lock.shield"
        default: return "square.grid.2x2"
        }
    }
}

struct IagBrandLogo: View {
    var height: CGFloat = 128
    var body: some View {
        Image("IagLogo")
            .resizable()
            .renderingMode(.original)
            .scaledToFit()
            .frame(maxWidth: 280, maxHeight: height)
            .accessibilityLabel("Inspire Africa Group")
    }
}

struct IagMark: View {
    var size: CGFloat = 56
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(IagTheme.orange)
            Text("IAG")
                .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: size, height: size)
    }
}

struct IagIconWell: View {
    var systemName: String
    var color: Color = IagTheme.orange
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.12))
            Image(systemName: systemName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(width: 40, height: 40)
    }
}

struct StatusPill: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .foregroundStyle(statusColor(text))
            .background(statusColor(text).opacity(0.12), in: Capsule())
    }
}

struct DeskRow: View {
    var title: String
    var subtitle: String
    var systemName: String = "square.grid.2x2"
    var status: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            IagIconWell(systemName: systemName)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.body.weight(.semibold))
                if !subtitle.isEmpty {
                    Text(subtitle).font(.caption).foregroundStyle(.secondary).lineLimit(2)
                }
            }
            Spacer(minLength: 8)
            if let status { StatusPill(text: status) }
        }
        .padding(.vertical, 2)
        .contentShape(Rectangle())
    }
}

struct IagSectionHeader: View {
    var title: String
    var accessory: String? = nil
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title).font(.subheadline.weight(.semibold))
            Spacer()
            if let accessory {
                Text(accessory).font(.caption.weight(.semibold)).foregroundStyle(IagTheme.orange)
            }
        }
    }
}

struct IagEmptyHint: View {
    var text: String
    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
    }
}

struct IagGrouped<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        VStack(spacing: 0) { content }
            .background(IagTheme.card, in: RoundedRectangle(cornerRadius: IagTheme.radius, style: .continuous))
    }
}

struct IagRowDivider: View {
    var body: some View {
        Divider().padding(.leading, 68)
    }
}

struct WelcomeStat: Identifiable {
    var id: String
    var label: String
    var value: String
}

struct WelcomeCard: View {
    var name: String
    var subtitle: String
    var stats: [WelcomeStat]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(iagGreeting()), \(name)")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(2)
                }
                Spacer(minLength: 8)
                IagMark(size: 36)
            }
            if !stats.isEmpty {
                HStack(spacing: 0) {
                    ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                        if index > 0 {
                            Rectangle()
                                .fill(.white.opacity(0.22))
                                .frame(width: 1, height: 28)
                                .padding(.horizontal, 8)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(stat.value)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.white)
                            Text(stat.label)
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.78))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(12)
                .background(.white.opacity(0.14), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [IagTheme.orange, IagTheme.orangeDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: IagTheme.radius, style: .continuous)
        )
    }
}

extension View {
    func iagCanvas() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(IagTheme.canvas.ignoresSafeArea())
    }

    func iagCard() -> some View {
        self.background(IagTheme.card, in: RoundedRectangle(cornerRadius: IagTheme.radius, style: .continuous))
    }
}
