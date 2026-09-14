import SwiftUI
import TraceCore

struct RouteDestination: View {
    let route: TraceRoute

    var body: some View {
        switch route.special {
        case .lookup: LookupView()
        case .intake: IntakeView()
        case .audit: AuditView()
        case .portal: PortalHomeView()
        default:
            if let entity = route.entity {
                RecordListView(entity: entity, title: route.label)
            } else if route.special == .dashboard {
                OverviewView()
            } else if route.special == .hub {
                HubView()
            } else if route.special == .map {
                MapView()
            } else if route.special == .reports {
                ReportsView()
            } else {
                RecordListView(entity: "farmers", title: route.label)
            }
        }
    }
}

struct RecordListView: View {
    @EnvironmentObject var box: StoreBox
    let entity: String
    var title: String
    @State private var query = ""

    var body: some View {
        let store = box.store
        let _ = box.tick
        let meta = entities[entity]
        let rows = store.scoped(entity).filter { matchesQuery($0, query) }
        List {
            ForEach(rows, id: \.id) { row in
                NavigationLink {
                    RecordDetailView(entity: entity, id: row.id)
                } label: {
                    VStack(alignment: .leading) {
                        Text(row.label)
                        Text(row.subtitle(meta?.columns ?? ["status"]))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(row.status)
                            .font(.caption2)
                            .foregroundStyle(statusColor(row.status))
                    }
                }
            }
        }
        .navigationTitle(title)
        .searchable(text: $query)
    }
}

struct RecordDetailView: View {
    @EnvironmentObject var box: StoreBox
    let entity: String
    let id: String

    var body: some View {
        let store = box.store
        let _ = box.tick
        let row = store.byId(entity, id)
        Form {
            if let row {
                Section(row.label) {
                    ForEach(row.data.keys.sorted(), id: \.self) { key in
                        if key != "id" {
                            LabeledContent(key, value: row[key])
                        }
                    }
                }
                if entity == "batches", let role = store.role, canAdvanceBatch(role), nextStage(row["stage"]) != nil {
                    Button("Advance to \(nextStage(row["stage"]) ?? "")") {
                        store.advanceBatch(id)
                    }
                }
                if entity == "qr-stories", let role = store.role, canPublishQr(role) {
                    Button("Publish QR") {
                        _ = store.publishQr(id)
                    }
                    Button("Revoke", role: .destructive) { store.revokeQr(id) }
                }
                if store.isAdmin {
                    Button("Delete", role: .destructive) { store.deleteRecord(entity, id) }
                }
            } else {
                Text("Record not found.")
            }
        }
        .navigationTitle(entities[entity]?.singular ?? entity)
    }
}

struct LookupView: View {
    @EnvironmentObject var box: StoreBox
    @State private var code = "IAG-LOT-00421"

    var body: some View {
        let store = box.store
        let _ = box.tick
        let hit = store.lookup(code)
        Form {
            Section("Public lookup") {
                TextField("Lot / QR / batch code", text: $code)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            if let hit {
                Section(hit.code) {
                    LabeledContent("Farmer", value: hit.farmer)
                    LabeledContent("Farm", value: hit.farm)
                    LabeledContent("District", value: hit.district)
                    LabeledContent("Crop", value: hit.crop)
                    LabeledContent("Harvest", value: hit.harvestDate)
                    LabeledContent("Quantity", value: kg(hit.quantityKg))
                    LabeledContent("Grade", value: hit.grade)
                    if !hit.stage.isEmpty { LabeledContent("Stage", value: hit.stage) }
                }
                if !hit.certs.isEmpty {
                    Section("Certifications") {
                        ForEach(hit.certs, id: \.self) { Text($0) }
                    }
                }
                if !hit.custody.isEmpty {
                    Section("Custody") {
                        ForEach(hit.custody, id: \.self) { Text($0) }
                    }
                }
                if !hit.story.isEmpty {
                    Section("Story") { Text(hit.story) }
                }
            } else if !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text("No public story for that code.")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Lookup")
    }
}

struct IntakeView: View {
    @EnvironmentObject var box: StoreBox
    @State private var kind = "Farm"
    @State private var name = ""
    @State private var phone = ""
    @State private var village = ""
    @State private var district = "Masaka"
    @State private var variety = "SL14"
    @State private var acres = "1"
    @State private var gps = ""
    @State private var bio = ""
    @State private var gross = "100"
    @State private var tare = "0"
    @State private var moisture = "12"
    @State private var message: String?

    var body: some View {
        Form {
            if let role = box.store.role, !canIntake(role) {
                Text("Your role cannot onboard farmers.")
            } else {
                Picker("Kind", selection: $kind) {
                    ForEach(intakeTypes, id: \.self) { Text($0).tag($0) }
                }
                TextField("Farmer name", text: $name)
                TextField("Phone", text: $phone)
                TextField("Village", text: $village)
                TextField("District", text: $district)
                TextField("Variety", text: $variety)
                TextField("Acres", text: $acres)
                TextField("GPS", text: $gps)
                TextField("Bio", text: $bio)
                TextField("Gross kg", text: $gross)
                TextField("Tare", text: $tare)
                TextField("Moisture", text: $moisture)
                if let message { Text(message).foregroundStyle(iagEmerald) }
                Button("Onboard") {
                    let farmer = box.store.intakeFarmer(
                        kind: kind, name: name, phone: phone, village: village, district: district,
                        variety: variety, acres: acres, gps: gps, bio: bio, gross: gross, tare: tare, moisture: moisture
                    )
                    message = farmer == nil ? "Could not onboard." : "Created \(farmer!["code"])."
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Web intake")
    }
}

struct AuditView: View {
    @EnvironmentObject var box: StoreBox

    var body: some View {
        let _ = box.tick
        List(box.store.audit, id: \.id) { entry in
            VStack(alignment: .leading) {
                Text("\(entry.action) · \(entry.entity)")
                Text("\(entry.label) · \(entry.actor)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Audit")
    }
}

struct HubView: View {
    var body: some View {
        List(hubSections, id: \.id) { section in
            VStack(alignment: .leading) {
                Text(section.label).font(.headline)
                Text(section.copy).font(.caption).foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Hub")
    }
}

struct MapView: View {
    @EnvironmentObject var box: StoreBox

    var body: some View {
        let _ = box.tick
        List(box.store.scoped("farms"), id: \.id) { farm in
            VStack(alignment: .leading) {
                Text(farm.label)
                Text(farm["gps"].isEmpty ? "GPS missing" : farm["gps"])
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Farm map")
    }
}

struct ReportsView: View {
    @EnvironmentObject var box: StoreBox

    var body: some View {
        let store = box.store
        let _ = box.tick
        List {
            LabeledContent("Farmers", value: "\(store.farmers.count)")
            LabeledContent("Batches", value: "\(store.batches.count)")
            LabeledContent("Lots", value: "\(store.lots.count)")
            LabeledContent("EUDR compliant", value: "\(store.eudrPercent())%")
            LabeledContent("Pending inspections", value: "\(store.pendingInspections.count)")
        }
        .navigationTitle("Reports")
    }
}
