import SwiftUI
import TraceCore

struct ShellView: View {
    @EnvironmentObject var box: StoreBox
    @State private var tab = 0

    var body: some View {
        let _ = box.tick
        if box.store.isPortal {
            TabView(selection: $tab) {
                PortalHomeView()
                    .tabItem { Label("My farm", systemImage: "house") }
                    .tag(0)
                NavigationStack { RecordListView(entity: "farms", title: "Farms") }
                    .tabItem { Label("Farms", systemImage: "map") }
                    .tag(1)
                NavigationStack { RecordListView(entity: "harvest-lots", title: "Lots") }
                    .tabItem { Label("Lots", systemImage: "cube.box") }
                    .tag(2)
                NavigationStack { LookupView() }
                    .tabItem { Label("Trace", systemImage: "viewfinder") }
                    .tag(3)
            }
        } else {
            TabView(selection: $tab) {
                OverviewView()
                    .tabItem { Label("Overview", systemImage: "square.grid.2x2") }
                    .tag(0)
                WorkCatalogView()
                    .tabItem { Label("Work", systemImage: "list.bullet.rectangle") }
                    .tag(1)
                NavigationStack { RecordListView(entity: "harvest-lots", title: "Lots") }
                    .tabItem { Label("Lots", systemImage: "cube.box") }
                    .tag(2)
                MoreView()
                    .tabItem { Label("More", systemImage: "ellipsis.circle") }
                    .tag(3)
            }
        }
    }
}

struct OverviewView: View {
    @EnvironmentObject var box: StoreBox

    var body: some View {
        let store = box.store
        let _ = box.tick
        let first = store.user?.name.split(separator: " ").first.map(String.init) ?? "there"
        let recent = store.recentActivity()
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    WelcomeCard(
                        name: first,
                        subtitle: "\(store.user?.name ?? "") · \(store.user?.role.rawValue.capitalized ?? "")",
                        stats: [
                            WelcomeStat(id: "farmers", label: "Farmers", value: "\(store.farmers.count)"),
                            WelcomeStat(id: "lots", label: "Lots", value: "\(store.lots.count)"),
                            WelcomeStat(id: "eudr", label: "EUDR", value: "\(store.eudrPercent())%"),
                            WelcomeStat(id: "inspect", label: "Checks", value: "\(store.pendingInspections.count)"),
                        ]
                    )
                    IagSectionHeader(title: "Recent")
                    if recent.isEmpty {
                        IagGrouped { IagEmptyHint(text: "No recent activity.") }
                    } else {
                        IagGrouped {
                            ForEach(Array(recent.enumerated()), id: \.element.copy) { index, item in
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title).font(.caption).foregroundStyle(.secondary)
                                    Text(item.copy).font(.subheadline.weight(.medium))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                if index < recent.count - 1 { Divider().padding(.leading, 16) }
                            }
                        }
                    }
                    IagSectionHeader(title: "Shortcuts")
                    IagGrouped {
                        NavigationLink {
                            LookupView()
                        } label: {
                            DeskRow(title: "Public lookup", subtitle: "Trace a lot or QR code", systemName: "qrcode.viewfinder")
                                .padding(16)
                        }
                        .buttonStyle(.plain)
                        if let role = store.role, canIntake(role) {
                            IagRowDivider()
                            NavigationLink {
                                IntakeView()
                            } label: {
                                DeskRow(title: "Web intake", subtitle: "Onboard a farmer and first batch", systemName: "person.badge.plus")
                                    .padding(16)
                            }
                            .buttonStyle(.plain)
                        }
                        IagRowDivider()
                        NavigationLink {
                            ProfileView()
                        } label: {
                            DeskRow(title: "Account", subtitle: "Signed in as \(store.user?.name ?? "")", systemName: "person")
                                .padding(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .iagCanvas()
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PortalHomeView: View {
    @EnvironmentObject var box: StoreBox
    @State private var volume = "50"
    @State private var notes = ""
    @State private var message: String?

    var body: some View {
        let store = box.store
        let _ = box.tick
        let lots = store.scoped("harvest-lots")
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    WelcomeCard(
                        name: store.user?.name.split(separator: " ").first.map(String.init) ?? "there",
                        subtitle: "\(store.myFarmer?["district"] ?? "") · \(store.myFarmer?["variety"] ?? "")",
                        stats: [
                            WelcomeStat(id: "lots", label: "Lots", value: "\(lots.count)"),
                            WelcomeStat(id: "farm", label: "Farm", value: store.myFarmer?["name"] ?? "Yours"),
                        ]
                    )
                    if let role = store.role, canRequestHarvest(role) {
                        IagSectionHeader(title: "Request pickup")
                        IagGrouped {
                            VStack(alignment: .leading, spacing: 12) {
                                TextField("Volume kg", text: $volume)
                                    .keyboardType(.decimalPad)
                                TextField("Notes", text: $notes)
                                if let message { Text(message).foregroundStyle(IagTheme.success) }
                                Button("Send harvest request") {
                                    store.requestHarvest(volumeKg: asNum(volume), notes: notes)
                                    message = "Request sent."
                                    notes = ""
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(IagTheme.orange)
                            }
                            .padding(16)
                        }
                    }
                    IagSectionHeader(title: "Your lots")
                    if lots.isEmpty {
                        IagGrouped { IagEmptyHint(text: "No lots on your farm yet.") }
                    } else {
                        IagGrouped {
                            ForEach(Array(lots.enumerated()), id: \.element.id) { index, lot in
                                NavigationLink {
                                    RecordDetailView(entity: "harvest-lots", id: lot.id)
                                } label: {
                                    DeskRow(
                                        title: lot.label,
                                        subtitle: "\(lot["crop"]) · \(kg(asNum(lot["quantity"]))) · \(lot["grade"])",
                                        systemName: "cube.box",
                                        status: lot.status.isEmpty ? nil : lot.status
                                    )
                                    .padding(16)
                                }
                                .buttonStyle(.plain)
                                if index < lots.count - 1 { IagRowDivider() }
                            }
                        }
                    }
                    IagGrouped {
                        NavigationLink {
                            LookupView()
                        } label: {
                            DeskRow(title: "Trace a lot", subtitle: "Public lot story", systemName: "viewfinder")
                                .padding(16)
                        }
                        .buttonStyle(.plain)
                        IagRowDivider()
                        NavigationLink {
                            ProfileView()
                        } label: {
                            DeskRow(title: "Account", subtitle: store.user?.name ?? "", systemName: "person")
                                .padding(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .iagCanvas()
            .navigationTitle("My farm")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WorkCatalogView: View {
    @EnvironmentObject var box: StoreBox

    var body: some View {
        let store = box.store
        let _ = box.tick
        let groups = Dictionary(grouping: store.visibleRoutes()) { $0.group }
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(TraceGroup.allCases, id: \.self) { group in
                        if let routes = groups[group], !routes.isEmpty {
                            IagSectionHeader(title: groupLabels[group] ?? group.rawValue)
                            IagGrouped {
                                ForEach(Array(routes.enumerated()), id: \.element.id) { index, route in
                                    NavigationLink {
                                        RouteDestination(route: route)
                                    } label: {
                                        DeskRow(title: route.label, subtitle: route.copy, systemName: routeIcon(route))
                                            .padding(16)
                                    }
                                    .buttonStyle(.plain)
                                    if index < routes.count - 1 { IagRowDivider() }
                                }
                            }
                        }
                    }
                }
                .padding(16)
            }
            .iagCanvas()
            .navigationTitle("Work")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MoreView: View {
    @EnvironmentObject var box: StoreBox

    var body: some View {
        let store = box.store
        let _ = box.tick
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    IagSectionHeader(title: "Registers")
                    IagGrouped {
                        ForEach(Array(moreRegisters.enumerated()), id: \.element.entity) { index, item in
                            NavigationLink {
                                RecordListView(entity: item.entity, title: item.label)
                            } label: {
                                DeskRow(title: item.label, subtitle: "Open register", systemName: "archivebox")
                                    .padding(16)
                            }
                            .buttonStyle(.plain)
                            if index < moreRegisters.count - 1 { IagRowDivider() }
                        }
                    }
                    IagSectionHeader(title: "Admin")
                    IagGrouped {
                        NavigationLink {
                            AuditView()
                        } label: {
                            DeskRow(title: "Audit log", subtitle: "Who changed what", systemName: "list.bullet.rectangle")
                                .padding(16)
                        }
                        .buttonStyle(.plain)
                        IagRowDivider()
                        NavigationLink {
                            ProfileView()
                        } label: {
                            DeskRow(title: "Account", subtitle: store.user?.name ?? "", systemName: "person")
                                .padding(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(16)
            }
            .iagCanvas()
            .navigationTitle("More")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ProfileView: View {
    @EnvironmentObject var box: StoreBox

    var body: some View {
        let store = box.store
        let _ = box.tick
        Form {
            Section("Signed in") {
                Text(store.user?.name ?? "")
                Text(store.user?.role.rawValue.capitalized ?? "").foregroundStyle(.secondary)
                Text("\(appName) \(appVersion)").font(.caption).foregroundStyle(.secondary)
            }
            Section {
                Button("Sign out", role: .destructive) { store.logout() }
                Button("Reset demo data") { store.resetDemo() }
            }
        }
        .iagCanvas()
        .navigationTitle("Account")
    }
}
