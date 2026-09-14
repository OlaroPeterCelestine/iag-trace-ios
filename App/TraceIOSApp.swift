import SwiftUI
import TraceCore

@main
struct TraceIOSApp: App {
    @StateObject private var box = StoreBox()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(box)
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

    var body: some View {
        let _ = box.tick
        if box.store.isSignedIn {
            ShellView()
        } else {
            LoginView()
        }
    }
}

let iagOrange = Color(red: 249 / 255, green: 115 / 255, blue: 22 / 255)
let iagSlate = Color(red: 15 / 255, green: 23 / 255, blue: 42 / 255)
let iagEmerald = Color(red: 5 / 255, green: 150 / 255, blue: 105 / 255)

func statusColor(_ status: String) -> Color {
    let s = status.lowercased()
    if ["paid", "approved", "active", "live", "complete", "valid", "received", "pass"].contains(where: { s.contains($0) }) {
        return iagEmerald
    }
    if ["reject", "void", "cancel", "revok"].contains(where: { s.contains($0) }) {
        return Color(red: 185 / 255, green: 28 / 255, blue: 28 / 255)
    }
    if ["pending", "open", "draft", "follow", "incomplete"].contains(where: { s.contains($0) }) {
        return iagOrange
    }
    return .secondary
}
