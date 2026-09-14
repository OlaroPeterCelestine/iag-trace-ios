import Foundation

public final class TraceStore {
    public private(set) var user: AuthUser?
    public var records: [String: [TraceRecord]] = [:]
    public var audit: [AuditEntry] = []
    public var passwords: [String: String] = [:]
    public var seq: Int = 50
    public private(set) var booted = false
    public var query: String = ""

    private let persistence: KeyValueStore
    private var listeners: [() -> Void] = []

    public init(persistence: KeyValueStore = MemoryKeyValueStore()) {
        self.persistence = persistence
    }

    public func addListener(_ listener: @escaping () -> Void) { listeners.append(listener) }

    private func notifyChange() { listeners.forEach { $0() } }

    public var isSignedIn: Bool { user != nil }
    public var isAgent: Bool { user?.isAgent ?? false }
    public var isStaff: Bool { user?.isStaff ?? false }
    public var isAdmin: Bool { user?.isAdmin ?? false }
    public var isPortal: Bool { user?.isPortal ?? false }
    public var role: TraceRole? { user?.role }

    public func of(_ entity: String) -> [TraceRecord] { records[entity] ?? [] }

    public func byId(_ entity: String, _ id: String) -> TraceRecord? {
        of(entity).first { $0.id == id || $0["code"] == id || $0["reference"] == id }
    }

    public var farmers: [TraceRecord] { of("farmers") }
    public var farms: [TraceRecord] { of("farms") }
    public var lots: [TraceRecord] { of("harvest-lots") }
    public var collections: [TraceRecord] { of("collections") }
    public var inspections: [TraceRecord] { of("field-inspections") }
    public var certs: [TraceRecord] { of("certifications") }
    public var batches: [TraceRecord] { of("batches") }

    public func farmerById(_ id: String) -> TraceRecord? { byId("farmers", id) }
    public func farmById(_ id: String) -> TraceRecord? { byId("farms", id) }

    public var myFarmer: TraceRecord? {
        if let id = user?.farmerId, let hit = farmerById(id) { return hit }
        let name = user?.farmerName ?? user?.name
        guard let name else { return nil }
        return farmers.first { $0["name"] == name || $0["code"] == name }
    }

    private func owns(_ row: TraceRecord) -> Bool {
        let me = myFarmer
        let name = user?.name ?? ""
        let farmerName = me?["name"] ?? user?.farmerName ?? ""
        let farmerCode = me?["code"] ?? ""
        for k in ["farmer", "name", "seller", "supplier", "from"] {
            let v = row[k]
            if v.isEmpty { continue }
            if v == name || v == farmerName || v == farmerCode || v == me?.id { return true }
        }
        if !row["farmerId"].isEmpty && row["farmerId"] == me?.id { return true }
        return false
    }

    public func scoped(_ entity: String) -> [TraceRecord] {
        let rows = of(entity)
        if !isPortal { return rows }
        return rows.filter { owns($0) }
    }

    public func visibleRoutes() -> [TraceRoute] {
        guard let role else { return [] }
        return traceRoutes.filter { canAccessRoute(role, $0) }
    }

    public var pendingInspections: [TraceRecord] {
        inspections.filter { $0.status == "Draft" || $0["result"] == "Follow-up" }
    }

    public func load() {
        if let raw = persistence.get(storeKey),
           let data = raw.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let u = json["user"] as? [String: Any] { user = AuthUser.fromJSON(u) } else { user = nil }
            seq = json["seq"] as? Int ?? 50
            passwords = [:]
            if let pw = json["passwords"] as? [String: Any] {
                for (k, v) in pw { passwords[k] = "\(v)" }
            }
            audit = ((json["audit"] as? [Any]) ?? []).compactMap { item in
                (item as? [String: Any]).map(AuditEntry.fromJSON)
            }
            records = [:]
            if let recs = json["records"] as? [String: Any] {
                for (key, value) in recs {
                    let list = (value as? [Any]) ?? []
                    records[key] = list.compactMap { item in
                        (item as? [String: Any]).map(TraceRecord.fromJSON)
                    }
                }
            }
            if farmers.isEmpty { seed() }
            for (key, value) in seedTraceRecords() {
                if records[key] == nil { records[key] = value }
            }
        } else {
            seed()
            persist()
        }
        booted = true
        notifyChange()
    }

    public func persist() {
        var recs: [String: Any] = [:]
        for (key, rows) in records {
            recs[key] = rows.map { $0.toJSON() }
        }
        let payload: [String: Any] = [
            "user": user?.toJSON() as Any,
            "seq": seq,
            "passwords": passwords,
            "audit": audit.map { $0.toJSON() },
            "records": recs,
        ]
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let text = String(data: data, encoding: .utf8) {
            persistence.put(storeKey, text)
        }
    }

    private func seed() {
        records = seedTraceRecords()
        audit = seedAudit()
        passwords = [:]
        seq = 50
    }

    public func resetDemo() {
        seed()
        user = nil
        persist()
        notifyChange()
    }

    @discardableResult
    public func login(_ username: String, _ password: String) -> String? {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let expected = passwords[u] ?? demoPassword
        if password != expected { return "Wrong password." }
        if u == "farmer" {
            user = AuthUser(username: "farmer", name: "Nakato Grace", role: .farmer, farmerId: "frm-nakato", farmerName: "Nakato Grace")
        } else if u == "supplier" {
            user = AuthUser(username: "supplier", name: "Namuli Sarah", role: .supplier, farmerId: "frm-1", farmerName: "Namuli Sarah")
        } else if u == "agent" {
            user = AuthUser(username: "agent", name: "Auma Inspector", role: .agent)
        } else if u == "admin" || u == "superadmin" {
            user = AuthUser(username: u, name: u == "admin" ? "Field Supervisor" : "Trace Admin", role: .admin)
        } else {
            return "Unknown user. Try farmer, supplier, agent, or admin."
        }
        persist()
        notifyChange()
        return nil
    }

    public func resetPassword(username: String, newPassword: String, confirm: String) -> String? {
        let u = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !knownUsernames.contains(u) { return "Unknown user." }
        if newPassword.count < 6 { return "Use at least 6 characters." }
        if newPassword != confirm { return "Passwords do not match." }
        passwords[u] = newPassword
        persist()
        notifyChange()
        return nil
    }

    public func logout() {
        user = nil
        persist()
        notifyChange()
    }

    public func nextRef(_ prefix: String) -> String {
        seq += 1
        return "\(prefix)-\(String(format: "%04d", seq))"
    }

    public func nextEntityCode(_ entity: String, _ prefix: String) -> String {
        let codes = of(entity).map { $0["code"].isEmpty ? $0["reference"] : $0["code"] }
        return nextCode(prefix, codes)
    }

    private func appendAudit(_ action: String, _ entity: String, _ label: String) {
        audit.insert(
            AuditEntry(id: newId(), at: ISO8601DateFormatter().string(from: Date()), action: action, entity: entity, label: label, actor: user?.name ?? ""),
            at: 0
        )
    }

    @discardableResult
    public func addRecord(_ entity: String, _ fields: [String: String]) -> TraceRecord? {
        guard let role, canCreateIn(role, entity: entity) else { return nil }
        let now = ISO8601DateFormatter().string(from: Date())
        var data = fields
        if (data["id"] ?? "").isEmpty { data["id"] = newId() }
        data["createdAt"] = now
        data["updatedAt"] = now
        let row = TraceRecord(data)
        records[entity] = [row] + of(entity)
        appendAudit("create", entity, row.label)
        persist()
        notifyChange()
        return row
    }

    public func updateRecord(_ entity: String, _ id: String, _ patch: [String: String]) {
        guard let role, canEditIn(role, entity: entity) else { return }
        var rows = of(entity)
        guard let i = rows.firstIndex(where: { $0.id == id }) else { return }
        var next = rows[i].data
        for (k, v) in patch { next[k] = v }
        next["id"] = id
        next["updatedAt"] = ISO8601DateFormatter().string(from: Date())
        let row = TraceRecord(next)
        rows[i] = row
        records[entity] = rows
        appendAudit("update", entity, row.label)
        persist()
        notifyChange()
    }

    public func deleteRecord(_ entity: String, _ id: String) {
        guard let role, canDeleteIn(role, entity: entity) else { return }
        let row = byId(entity, id)
        records[entity] = of(entity).filter { $0.id != id }
        appendAudit("delete", entity, row?.label ?? id)
        persist()
        notifyChange()
    }

    public func addInspection(farmId: String, result: String, findings: String) {
        guard let role, canInspect(role) else { return }
        let farm = farmById(farmId)
        _ = addRecord("field-inspections", [
            "reference": nextRef("INSP"),
            "date": todayIsoDate(),
            "farm": farm?["name"] ?? farmId,
            "farmId": farmId,
            "inspector": user?.name ?? "Agent",
            "result": result,
            "findings": findings,
            "status": result == "Follow-up" ? "Draft" : "Complete",
        ])
    }

    public func addCollection(farmerId: String, lotId: String, centre: String, kg: Double, amount: Double) {
        guard let role, canCollect(role) else { return }
        let farmer = farmerById(farmerId)
        let lot = byId("harvest-lots", lotId)
        _ = addRecord("collections", [
            "reference": nextRef("COL"),
            "date": todayIsoDate(),
            "farmer": farmer?["name"] ?? farmerId,
            "farmerId": farmerId,
            "lot": lot?["traceCode"].isEmpty == false ? lot!["traceCode"] : (lot?["code"] ?? ""),
            "lotId": lotId,
            "buyingCentre": centre,
            "quantity": "\(kg)",
            "amount": String(format: "%.0f", amount),
            "status": amount > 0 ? "Paid" : "Received",
        ])
    }

    public func requestHarvest(volumeKg: Double, notes: String) {
        guard let role, canRequestHarvest(role) else { return }
        let me = myFarmer
        let volume = volumeKg.rounded() == volumeKg ? String(format: "%.0f", volumeKg) : "\(volumeKg)"
        _ = addRecord("harvest-requests", [
            "reference": nextEntityCode("harvest-requests", "HR"),
            "date": todayIsoDate(),
            "farmer": me?["name"] ?? user?.name ?? "Supplier",
            "village": me?["village"] ?? "",
            "volumeKg": volume,
            "status": "Pending",
            "notes": notes,
        ])
    }

    @discardableResult
    public func intakeFarmer(
        kind: String,
        name: String,
        phone: String,
        village: String,
        district: String,
        variety: String,
        acres: String,
        gps: String,
        bio: String,
        gross: String,
        tare: String,
        moisture: String
    ) -> TraceRecord? {
        guard let role, canIntake(role) else { return nil }
        let farmerCode = nextEntityCode("farmers", "FRM")
        let farmCode = nextEntityCode("farms", "FARM")
        let batchCode = nextEntityCode("batches", "BATCH")
        let farmer = addRecord("farmers", [
            "name": name, "code": farmerCode, "phone": phone, "village": village, "district": district,
            "variety": variety, "acres": acres, "gps": gps, "bio": bio, "status": "Active",
        ])
        _ = addRecord("farms", [
            "name": "\(name) farm", "code": farmCode, "farmer": name, "farmerId": farmer?.id ?? "",
            "district": district, "village": village, "variety": variety, "acres": acres, "gps": gps, "status": "Active",
        ])
        _ = addRecord("suppliers", [
            "name": name, "code": "SUP-\(farmerCode)", "kind": kind, "district": district, "phone": phone, "status": "Active",
        ])
        _ = addRecord("batches", [
            "name": "\(name) intake", "code": batchCode, "farmer": name, "farm": "\(name) farm",
            "beanType": "Arabica", "variety": variety, "stage": "Intake", "date": todayIsoDate(),
            "grossKg": gross, "tare": tare.isEmpty ? "0" : tare, "netKg": netKg(gross, tare),
            "moisture": moisture, "status": "Active",
        ])
        return farmer
    }

    public func advanceBatch(_ id: String) {
        guard let role, canAdvanceBatch(role) else { return }
        guard let batch = byId("batches", id), let next = nextStage(batch["stage"]) else { return }
        var patch = ["stage": next]
        if next == "Exported" { patch["status"] = "Exported" }
        updateRecord("batches", id, patch)
    }

    public func publishQr(_ id: String) -> String? {
        guard let role, canPublishQr(role) else { return "Your role cannot publish QR stories." }
        guard let story = byId("qr-stories", id) else { return "Story not found." }
        let lot = of("export-lots").first { $0["code"] == story["lot"] || $0["code"] == story["code"] }
        guard let lot else { return "Export lot is missing." }
        if lot.status.range(of: "ready|ship", options: [.regularExpression, .caseInsensitive]) == nil {
            return "Lot must be Ready or Shipped."
        }
        var ids = Set(story["lot"].split(whereSeparator: { $0 == "," || $0.isWhitespace }).map(String.init).filter { !$0.isEmpty })
        for part in lot["batches"].split(whereSeparator: { $0 == "," || $0.isWhitespace }) {
            ids.insert(String(part))
        }
        let related = batches.filter { ids.contains($0["code"]) || ids.contains($0.id) }
        if related.contains(where: { $0["stage"].range(of: "approved|export", options: [.regularExpression, .caseInsensitive]) == nil }) {
            return "Every batch in the lot must be Approved or Exported."
        }
        updateRecord("qr-stories", id, ["status": "Live"])
        return nil
    }

    public func revokeQr(_ id: String) {
        updateRecord("qr-stories", id, ["status": "Revoked"])
    }

    public func lookup(_ raw: String) -> TraceHit? {
        let q = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return nil }

        func hitCode(_ row: TraceRecord) -> Bool {
            for key in ["code", "traceCode", "lot", "reference"] {
                if row[key].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == q { return true }
            }
            return false
        }

        let stories = of("qr-stories").filter { hitCode($0) && $0.status.range(of: "revok", options: [.regularExpression, .caseInsensitive]) == nil }
        let codes = of("trace-codes").filter(hitCode)
        let harvest = lots.filter(hitCode)
        let exports = of("export-lots").filter(hitCode)
        let batchHits = batches.filter(hitCode)
        let match = harvest.first ?? codes.first ?? exports.first ?? stories.first ?? batchHits.first
        guard let match else { return nil }

        let lot = harvest.first ?? lots.first { $0["code"] == match["lot"] || $0["traceCode"].lowercased() == q }
        let farmerName = match["farmer"].isEmpty ? (lot?["farmer"] ?? "") : match["farmer"]
        let farmer = farmers.first { $0["name"] == farmerName || $0["code"] == farmerName || $0.id == farmerName }
        let farmName = (lot == nil || lot!["farm"].isEmpty) ? match["farm"] : lot!["farm"]
        let farm = farms.first { $0["name"] == farmName || $0["code"] == farmName }
        let farmerLabel = farmer?["name"] ?? farmerName
        let relatedCerts = certs.filter { $0["farmer"] == farmerName || $0["farmer"] == farmerLabel }
        let lotCode = lot?["code"] ?? ""
        let lotTrace = lot?["traceCode"] ?? ""
        let movements = of("chain-of-custody").filter { row in
            let lotRef = row["lot"].lowercased()
            return lotRef == q || lotRef == lotCode.lowercased() || lotRef == lotTrace.lowercased()
                || lotRef == match["code"].lowercased() || lotRef == match["lot"].lowercased()
        }
        let story = stories.first
        let qtyRaw = (lot != nil && !(lot!["quantity"].isEmpty)) ? lot!["quantity"] : (match["weightKg"].isEmpty ? match["netKg"] : match["weightKg"])
        let crop = (lot != nil && !(lot!["crop"].isEmpty)) ? lot!["crop"] : (match["variety"].isEmpty ? match["grade"] : match["variety"])
        let harvestDate = (lot != nil && !(lot!["date"].isEmpty)) ? lot!["date"] : match["date"]
        let grade = (lot != nil && !(lot!["grade"].isEmpty)) ? lot!["grade"] : match["grade"]
        return TraceHit(
            code: match["traceCode"].isEmpty ? match["code"] : match["traceCode"],
            farmer: farmerLabel,
            district: (farmer != nil && !(farmer!["district"].isEmpty)) ? farmer!["district"] : (farm?["district"] ?? ""),
            farm: farm?["name"] ?? farmName,
            crop: crop,
            harvestDate: harvestDate,
            quantityKg: asNum(qtyRaw),
            grade: grade,
            certs: relatedCerts.map { "\($0["scheme"]) · \($0.status)" },
            custody: movements.map { "\($0["date"]): \($0["from"]) → \($0["to"])" },
            story: story?["notes"] ?? "",
            stage: match["stage"],
            status: match.status
        )
    }

    public func eudrPercent() -> Int {
        if farmers.isEmpty { return 0 }
        var ok = 0
        for farmer in farmers {
            let farm = farms.first { $0["farmer"] == farmer["name"] || $0["farmer"] == farmer["code"] }
            if eudrStatus(farmer, farm).compliant { ok += 1 }
        }
        return Int(((Double(ok) / Double(farmers.count)) * 100).rounded())
    }

    public func recentActivity() -> [ActivityItem] {
        var rows: [ActivityItem] = []
        func push(_ entity: String, _ title: String, _ routeId: String, _ pick: (TraceRecord) -> String) {
            for row in of(entity) {
                rows.append(ActivityItem(title: title, copy: pick(row), routeId: routeId, at: recordStamp(row)))
            }
        }
        push("batches", "Batch", "batches") { "\($0["code"]) · \($0["stage"])" }
        push("harvest-requests", "Harvest request", "harvest-requests") { "\($0["farmer"]) · \($0.status)" }
        push("lab-results", "Lab", "lab") { "\($0["batch"]) · \($0.status)" }
        push("farmer-payments", "Payout", "payments") { "\($0["farmer"]) · \(ugx(asNum($0["amount"])))" }
        push("custody-events", "Custody", "events") { "\($0["lot"]): \($0["from"]) → \($0["to"])" }
        rows.sort { $0.at > $1.at }
        return Array(rows.prefix(8))
    }
}
