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
        NavigationStack {
            List {
                Section {
                    Text("Good morning, \(first)").font(.title2.bold())
                    Text("\(store.user?.name ?? "") · \(store.user?.role.rawValue.capitalized ?? "")")
                        .foregroundStyle(.secondary)
                }
                Section("Snapshot") {
                    HStack {
                        kpi("Farmers", "\(store.farmers.count)")
                        kpi("Lots", "\(store.lots.count)")
                    }
                    HStack {
                        kpi("EUDR", "\(store.eudrPercent())%")
                        kpi("Inspections", "\(store.pendingInspections.count)")
                    }
                }
                Section("Recent") {
                    ForEach(store.recentActivity(), id: \.copy) { item in
                        VStack(alignment: .leading) {
                            Text(item.title).font(.caption).foregroundStyle(.secondary)
                            Text(item.copy)
                        }
                    }
                }
                Section("Shortcuts") {
                    NavigationLink("Public lookup") { LookupView() }
                    if let role = store.role, canIntake(role) {
                        NavigationLink("Web intake") { IntakeView() }
                    }
                    NavigationLink("Account") { ProfileView() }
                }
            }
            .navigationTitle("Overview")
        }
    }

    func kpi(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(label).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
        NavigationStack {
            Form {
                Section("Your farm") {
                    Text(store.myFarmer?["name"] ?? store.user?.name ?? "")
                        .font(.headline)
                    Text("\(store.myFarmer?["district"] ?? "") · \(store.myFarmer?["variety"] ?? "")")
                        .foregroundStyle(.secondary)
                }
                if let role = store.role, canRequestHarvest(role) {
                    Section("Request pickup") {
                        TextField("Volume kg", text: $volume)
                            .keyboardType(.decimalPad)
                        TextField("Notes", text: $notes)
                        if let message { Text(message).foregroundStyle(iagEmerald) }
                        Button("Send harvest request") {
                            store.requestHarvest(volumeKg: asNum(volume), notes: notes)
                            message = "Request sent."
                            notes = ""
                        }
                    }
                }
                Section("Your lots") {
                    ForEach(store.scoped("harvest-lots"), id: \.id) { lot in
                        NavigationLink {
                            RecordDetailView(entity: "harvest-lots", id: lot.id)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(lot.label)
                                Text("\(lot["crop"]) · \(kg(asNum(lot["quantity"]))) · \(lot["grade"])")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                Section {
                    NavigationLink("Trace a lot") { LookupView() }
                    NavigationLink("Account") { ProfileView() }
                }
            }
            .navigationTitle("My farm")
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
            List {
                ForEach(TraceGroup.allCases, id: \.self) { group in
                    if let routes = groups[group], !routes.isEmpty {
                        Section(groupLabels[group] ?? group.rawValue) {
                            ForEach(routes, id: \.id) { route in
                                NavigationLink(route.label) {
                                    RouteDestination(route: route)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Work")
        }
    }
}

struct MoreView: View {
    @EnvironmentObject var box: StoreBox

    var body: some View {
        let store = box.store
        let _ = box.tick
        NavigationStack {
            List {
                Section("Registers") {
                    ForEach(moreRegisters, id: \.entity) { item in
                        NavigationLink(item.label) {
                            RecordListView(entity: item.entity, title: item.label)
                        }
                    }
                }
                Section("Admin") {
                    NavigationLink("Audit log") { AuditView() }
                    NavigationLink("Account") { ProfileView() }
                }
            }
            .navigationTitle("More")
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
                Text("Trace iOS \(appVersion)").font(.caption).foregroundStyle(.secondary)
            }
            Section {
                Button("Sign out", role: .destructive) { store.logout() }
                Button("Reset demo data") { store.resetDemo() }
            }
        }
        .navigationTitle("Account")
    }
}
