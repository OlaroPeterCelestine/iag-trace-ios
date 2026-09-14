import Foundation

public struct AuthUser: Equatable, Sendable {
    public var username: String
    public var name: String
    public var role: TraceRole
    public var farmerId: String?
    public var farmerName: String?

    public init(username: String, name: String, role: TraceRole, farmerId: String? = nil, farmerName: String? = nil) {
        self.username = username
        self.name = name
        self.role = role
        self.farmerId = farmerId
        self.farmerName = farmerName
    }

    public var isAgent: Bool { isStaffRole(role) }
    public var isStaff: Bool { isStaffRole(role) }
    public var isAdmin: Bool { role == .admin }
    public var isPortal: Bool { isPortalRole(role) }

    public var initials: String {
        let parts = name.split(whereSeparator: \.isWhitespace).map(String.init)
        if parts.isEmpty { return username.isEmpty ? "?" : String(username.prefix(1)).uppercased() }
        if parts.count == 1 { return String(parts[0].prefix(1)).uppercased() }
        return "\(parts[0].prefix(1))\(parts[parts.count - 1].prefix(1))".uppercased()
    }

    public func toJSON() -> [String: Any] {
        var json: [String: Any] = ["username": username, "name": name, "role": role.rawValue]
        if let farmerId { json["farmerId"] = farmerId }
        if let farmerName { json["farmerName"] = farmerName }
        return json
    }

    public static func fromJSON(_ j: [String: Any]) -> AuthUser {
        AuthUser(
            username: j["username"] as? String ?? "",
            name: j["name"] as? String ?? "",
            role: parseTraceRole(j["role"] as? String),
            farmerId: j["farmerId"] as? String,
            farmerName: j["farmerName"] as? String
        )
    }
}

public final class TraceRecord: Equatable {
    public var data: [String: String]

    public init(_ data: [String: String]) {
        self.data = data
    }

    public var id: String { data["id"] ?? "" }
    public var status: String { data["status"] ?? "" }

    public subscript(key: String) -> String {
        get { data[key] ?? "" }
        set { data[key] = newValue }
    }

    public var label: String {
        for key in ["name", "code", "reference", "traceCode"] {
            let v = (data[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !v.isEmpty { return v }
        }
        return id
    }

    public func subtitle(_ columns: [String]) -> String {
        var parts: [String] = []
        for c in columns where c != "name" && c != "code" && c != "reference" {
            let v = (data[c] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !v.isEmpty { parts.append(v) }
        }
        return parts.prefix(3).joined(separator: " · ")
    }

    public func toJSON() -> [String: String] { data }

    public static func fromJSON(_ j: [String: Any]) -> TraceRecord {
        var out: [String: String] = [:]
        for (k, v) in j {
            if v is NSNull { continue }
            out[k] = "\(v)"
        }
        return TraceRecord(out)
    }

    public static func == (lhs: TraceRecord, rhs: TraceRecord) -> Bool { lhs.id == rhs.id }
}

public struct AuditEntry: Equatable, Sendable {
    public var id: String
    public var at: String
    public var action: String
    public var entity: String
    public var label: String
    public var actor: String

    public init(id: String, at: String, action: String, entity: String, label: String, actor: String) {
        self.id = id
        self.at = at
        self.action = action
        self.entity = entity
        self.label = label
        self.actor = actor
    }

    public func toJSON() -> [String: Any] {
        ["id": id, "at": at, "action": action, "entity": entity, "label": label, "actor": actor]
    }

    public static func fromJSON(_ j: [String: Any]) -> AuditEntry {
        AuditEntry(
            id: j["id"] as? String ?? newId(),
            at: j["at"] as? String ?? "",
            action: j["action"] as? String ?? "",
            entity: j["entity"] as? String ?? "",
            label: j["label"] as? String ?? "",
            actor: j["actor"] as? String ?? ""
        )
    }
}

public struct EudrResult: Equatable, Sendable {
    public var gps: String
    public var satellite: String
    public var bio: String
    public var dueDiligence: String
    public var status: String
    public var compliant: Bool { status == "Compliant" }
}

public struct TraceHit: Equatable, Sendable {
    public var code: String
    public var farmer: String
    public var district: String
    public var farm: String
    public var crop: String
    public var harvestDate: String
    public var quantityKg: Double
    public var grade: String
    public var certs: [String]
    public var custody: [String]
    public var story: String
    public var stage: String
    public var status: String
}

public struct ActivityItem: Equatable, Sendable {
    public var title: String
    public var copy: String
    public var routeId: String
    public var at: Int
}

public protocol KeyValueStore: AnyObject {
    func get(_ key: String) -> String?
    func put(_ key: String, _ value: String)
}

public final class MemoryKeyValueStore: KeyValueStore {
    private var data: [String: String] = [:]
    public init() {}
    public func get(_ key: String) -> String? { data[key] }
    public func put(_ key: String, _ value: String) { data[key] = value }
}

public final class UserDefaultsStore: KeyValueStore {
    private let defaults: UserDefaults
    public init(_ defaults: UserDefaults = .standard) { self.defaults = defaults }
    public func get(_ key: String) -> String? { defaults.string(forKey: key) }
    public func put(_ key: String, _ value: String) { defaults.set(value, forKey: key) }
}

public func todayIsoDate(_ date: Date = Date()) -> String {
    let c = Calendar.current
    return String(format: "%04d-%02d-%02d", c.component(.year, from: date), c.component(.month, from: date), c.component(.day, from: date))
}

public func newId() -> String {
    "\(DispatchTime.now().uptimeNanoseconds)-\(Int(Date().timeIntervalSince1970 * 1000) % 997)"
}

public func asNum(_ raw: String) -> Double {
    Double(raw.replacingOccurrences(of: ",", with: "")) ?? 0
}

public func kg(_ n: Double) -> String {
    if n.rounded() == n { return "\(Int(n)) kg" }
    return String(format: "%.1f kg", n)
}

public func ugx(_ n: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.maximumFractionDigits = 0
    let body = formatter.string(from: NSNumber(value: abs(n))) ?? "0"
    return "\(n < 0 ? "-" : "")UGX \(body)"
}
