import Foundation

public enum TraceGroup: String, Equatable, Sendable, CaseIterable {
    case workspace, network, trace, quality, commerce, field, hub, access, more
}

public enum TraceSpecial: String, Equatable, Sendable {
    case dashboard, intake, batches, chain, qr, compliance, reports, map, hub, portal, audit, farmers, lookup, register
}

public struct TraceRoute: Equatable, Sendable {
    public var id: String
    public var label: String
    public var group: TraceGroup
    public var entity: String?
    public var staff: Bool
    public var portal: Bool
    public var open: Bool
    public var special: TraceSpecial?
    public var copy: String

    public init(
        id: String,
        label: String,
        group: TraceGroup,
        entity: String? = nil,
        staff: Bool = false,
        portal: Bool = false,
        open: Bool = false,
        special: TraceSpecial? = nil,
        copy: String = ""
    ) {
        self.id = id
        self.label = label
        self.group = group
        self.entity = entity
        self.staff = staff
        self.portal = portal
        self.open = open
        self.special = special
        self.copy = copy
    }
}

public struct TraceEntity: Equatable, Sendable {
    public var key: String
    public var label: String
    public var singular: String
    public var columns: [String]
}

public let traceVersion = "1.0.5"

public let groupLabels: [TraceGroup: String] = [
    .workspace: "Workspace",
    .network: "Producer network",
    .trace: "Traceability",
    .quality: "Quality & insight",
    .commerce: "Commerce",
    .field: "Field & HQ",
    .hub: "TraceAG Hub",
    .access: "Admin",
    .more: "More registers",
]

public let traceRoutes: [TraceRoute] = [
    TraceRoute(id: "overview", label: "Overview", group: .workspace, open: true, special: .dashboard, copy: "KPIs, EUDR coverage, and recent activity."),
    TraceRoute(id: "farmers", label: "Farmers", group: .network, entity: "farmers", special: .farmers, copy: "Registry, GPS, variety, and certifications."),
    TraceRoute(id: "intake", label: "Web intake", group: .network, open: true, special: .intake, copy: "Onboard a farmer, farm, and first batch."),
    TraceRoute(id: "cooperatives", label: "Cooperatives", group: .network, entity: "cooperatives", copy: "Co-ops and membership counts."),
    TraceRoute(id: "harvest-requests", label: "Harvest requests", group: .network, entity: "harvest-requests", copy: "Pickup inbox from the supplier portal."),
    TraceRoute(id: "suppliers", label: "Suppliers", group: .network, entity: "suppliers", copy: "Farms, co-ops, shops, and factories."),
    TraceRoute(id: "farms", label: "Farms", group: .network, entity: "farms", copy: "Plots, GPS, acres, and variety."),
    TraceRoute(id: "batches", label: "Batches", group: .trace, entity: "batches", special: .batches, copy: "Pipeline: intake → wet mill → drying → dry mill → export."),
    TraceRoute(id: "chain", label: "Chain of custody", group: .trace, entity: "chain-of-custody", special: .chain, copy: "Movements from farm to mill to warehouse."),
    TraceRoute(id: "events", label: "Event ledger", group: .trace, entity: "custody-events", copy: "Append-only custody events."),
    TraceRoute(id: "export", label: "Export lots", group: .trace, entity: "export-lots", copy: "Ready, pending, and shipped lots."),
    TraceRoute(id: "qr", label: "QR stories", group: .trace, entity: "qr-stories", special: .qr, copy: "Publish, preview, or revoke consumer stories."),
    TraceRoute(id: "lab", label: "Lab results", group: .quality, entity: "lab-results", copy: "Moisture, cupping, and grade."),
    TraceRoute(id: "compliance", label: "Compliance", group: .quality, entity: "certifications", special: .compliance, copy: "EUDR GPS, satellite, bio, and due diligence."),
    TraceRoute(id: "reports", label: "Reports", group: .quality, open: true, special: .reports, copy: "CSV packs for farmers, batches, lab, chain, payouts."),
    TraceRoute(id: "procurement", label: "Procurement", group: .commerce, entity: "purchase-orders", copy: "Purchase orders with suppliers."),
    TraceRoute(id: "sales", label: "Sales orders", group: .commerce, entity: "sales-orders", copy: "Buyer orders against export lots."),
    TraceRoute(id: "inventory", label: "Inventory", group: .commerce, entity: "inventory-skus", copy: "SKU stock by grade."),
    TraceRoute(id: "payments", label: "Farmer payments", group: .commerce, entity: "farmer-payments", copy: "Cherry payouts in UGX."),
    TraceRoute(id: "logistics", label: "Logistics", group: .commerce, entity: "shipments", copy: "Shipments of export lots."),
    TraceRoute(id: "agents", label: "Field agents", group: .field, entity: "field-agents", staff: true, copy: "Roster and catchment."),
    TraceRoute(id: "stock", label: "Stock & sacks", group: .field, entity: "stock-sessions", staff: true, copy: "Loading sessions and RFID / QR sacks."),
    TraceRoute(id: "map", label: "Farm map", group: .field, open: true, special: .map, copy: "GPS pins and EUDR fences."),
    TraceRoute(id: "marketplace", label: "Marketplace", group: .field, entity: "marketplace-listings", copy: "Listings, price, and quantity."),
    TraceRoute(id: "prices", label: "Farmgate prices", group: .field, entity: "farmgate-prices", copy: "Published UGX / kg by district."),
    TraceRoute(id: "surveys", label: "Surveys", group: .field, entity: "surveys", staff: true, copy: "Quizzes, notices, and engagement."),
    TraceRoute(id: "rewards", label: "Rewards", group: .field, entity: "rewards", staff: true, copy: "Loyalty points and badges."),
    TraceRoute(id: "notifications", label: "Notifications", group: .field, entity: "sms-blasts", staff: true, copy: "SMS, email, and USSD blasts."),
    TraceRoute(id: "portal", label: "Portal home", group: .access, portal: true, open: true, special: .portal, copy: "Your batches, harvest requests, and GPS."),
    TraceRoute(id: "portal-harvest", label: "Request pickup", group: .access, entity: "harvest-requests", portal: true, copy: "Ask staff to collect cherry."),
    TraceRoute(id: "portal-batches", label: "My batches", group: .access, entity: "batches", portal: true, copy: "Lots in the mill pipeline."),
    TraceRoute(id: "portal-farms", label: "My farms", group: .access, entity: "farms", portal: true, copy: "Plots and GPS on file."),
    TraceRoute(id: "portal-payments", label: "My payments", group: .access, entity: "farmer-payments", portal: true, copy: "Cherry payouts in UGX."),
    TraceRoute(id: "portal-orders", label: "My orders", group: .access, entity: "purchase-orders", portal: true, copy: "Orders placed with you."),
    TraceRoute(id: "hub", label: "Hub overview", group: .hub, open: true, special: .hub, copy: "ACP snapshot, tracker, ledger, loans, housing."),
    TraceRoute(id: "lookup", label: "Public lookup", group: .workspace, open: true, special: .lookup, copy: "Same story as the desk app /trace?code=."),
    TraceRoute(id: "admin", label: "Audit log", group: .access, staff: true, open: true, special: .audit, copy: "Creates, patches, and service health."),
    TraceRoute(id: "register", label: "All registers", group: .more, staff: true, special: .register, copy: "Plots, crops, inspections, sacks, disputes, tickets."),
]

public let hubSections: [(id: String, label: String, copy: String)] = [
    ("overview", "Overview & analytics", "ACP snapshot, batches, EUDR, and payouts."),
    ("tracker", "Supply-chain tracker", "Follow cherry from farm to export lot."),
    ("ledger", "Blockchain ledger", "Local custody hashes and event history."),
    ("farmers", "Farmer profiles", "Identity, GPS, variety, and certs."),
    ("health", "Health & insurance", "Membership cover and clinic desk."),
    ("market", "Crop market", "Farmgate board and marketplace GMV."),
    ("contracts", "E-contracts", "Draft offtake and membership agreements."),
    ("payments", "Payments portal", "Cherry payouts and wallet status."),
    ("loans", "Loans & scoring", "Credit desk and simple score cards."),
    ("housing", "Rent-to-own housing", "ACP housing benefit tracker."),
    ("apps", "Mobile apps", "Farmer City and Field Agent surfaces in this app."),
]

public let moreRegisters: [(label: String, entity: String)] = [
    ("Plots", "plots"),
    ("Crops", "crops"),
    ("Harvest lots", "harvest-lots"),
    ("Collections", "collections"),
    ("Trace codes", "trace-codes"),
    ("Field inspections", "field-inspections"),
    ("Co-op members", "cooperative-members"),
    ("Buyers", "buyers"),
    ("Sacks", "sacks"),
    ("Disputes", "disputes"),
    ("Support tickets", "support-tickets"),
    ("Notices", "notices"),
]

public let entities: [String: TraceEntity] = {
    var map: [String: TraceEntity] = [:]
    func add(_ key: String, _ label: String, _ singular: String, _ columns: [String]) {
        map[key] = TraceEntity(key: key, label: label, singular: singular, columns: columns)
    }
    add("farmers", "Farmers", "Farmer", ["name", "code", "district", "status"])
    add("farms", "Farms", "Farm", ["name", "code", "farmer", "status"])
    add("plots", "Plots", "Plot", ["name", "code", "farm", "status"])
    add("crops", "Crops", "Crop", ["name", "code", "season", "status"])
    add("cooperatives", "Cooperatives", "Cooperative", ["name", "code", "district", "status"])
    add("cooperative-members", "Co-op members", "Member", ["name", "cooperative", "farmer", "status"])
    add("harvest-requests", "Harvest requests", "Harvest request", ["reference", "farmer", "volumeKg", "status"])
    add("suppliers", "Suppliers", "Supplier", ["name", "code", "kind", "status"])
    add("batches", "Batches", "Batch", ["code", "farmer", "stage", "status"])
    add("custody-events", "Custody events", "Event", ["reference", "lot", "from", "status"])
    add("chain-of-custody", "Chain of custody", "Movement", ["reference", "lot", "from", "status"])
    add("export-lots", "Export lots", "Export lot", ["name", "code", "grade", "status"])
    add("qr-stories", "QR stories", "QR story", ["name", "code", "farmer", "status"])
    add("lab-results", "Lab results", "Lab result", ["reference", "batch", "grade", "status"])
    add("certifications", "Certifications", "Certification", ["name", "farmer", "scheme", "status"])
    add("purchase-orders", "Purchase orders", "Purchase order", ["reference", "supplier", "amount", "status"])
    add("sales-orders", "Sales orders", "Sales order", ["reference", "buyer", "lot", "status"])
    add("buyers", "Buyers", "Buyer", ["name", "code", "country", "status"])
    add("inventory-skus", "Inventory", "SKU", ["name", "code", "grade", "status"])
    add("farmer-payments", "Farmer payments", "Payment", ["reference", "farmer", "amount", "status"])
    add("field-agents", "Field agents", "Agent", ["name", "code", "district", "status"])
    add("stock-sessions", "Stock sessions", "Session", ["reference", "vehicle", "agent", "status"])
    add("sacks", "Sacks", "Sack", ["code", "lot", "status"])
    add("marketplace-listings", "Marketplace", "Listing", ["name", "priceKg", "status"])
    add("surveys", "Surveys", "Survey", ["name", "status"])
    add("rewards", "Rewards", "Reward", ["name", "status"])
    add("notices", "Notices", "Notice", ["name", "status"])
    add("farmgate-prices", "Farmgate prices", "Price", ["name", "district", "priceKg", "status"])
    add("disputes", "Disputes", "Dispute", ["reference", "status"])
    add("support-tickets", "Support tickets", "Ticket", ["subject", "status"])
    add("sms-blasts", "Notifications", "Blast", ["name", "status"])
    add("harvest-lots", "Harvest lots", "Harvest lot", ["name", "traceCode", "farmer", "status"])
    add("collections", "Collections", "Collection", ["reference", "farmer", "quantity", "status"])
    add("trace-codes", "Trace codes", "Trace code", ["code", "farmer", "lot", "status"])
    add("field-inspections", "Field inspections", "Inspection", ["reference", "farm", "result", "status"])
    add("shipments", "Shipments", "Shipment", ["reference", "customer", "status"])
    return map
}()

public func routeById(_ id: String) -> TraceRoute? {
    traceRoutes.first { $0.id == id }
}
