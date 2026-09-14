import Foundation

public enum TraceRole: String, Equatable, Sendable, CaseIterable {
    case farmer
    case supplier
    case agent
    case admin
}

public let demoPassword = "iagdemo"
public let appName = "IAG Trace"
public let appVersion = "1.0.0"
public let storeKey = "iag-trace-ios-v1"

public let knownUsernames: Set<String> = ["farmer", "supplier", "agent", "admin", "superadmin"]

public func parseTraceRole(_ raw: String?) -> TraceRole {
    switch (raw ?? "").trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
    case "farmer": return .farmer
    case "supplier": return .supplier
    case "admin", "superadmin", "super admin": return .admin
    default: return .agent
    }
}

public func isStaffRole(_ role: TraceRole) -> Bool {
    role == .agent || role == .admin
}

public func isPortalRole(_ role: TraceRole) -> Bool {
    role == .farmer || role == .supplier
}

public func canAccessRoute(_ role: TraceRole, _ route: TraceRoute) -> Bool {
    if route.id == "register" && !isStaffRole(role) { return false }
    if isPortalRole(role) {
        return route.portal || route.open || route.special == .lookup
    }
    if route.portal && !isStaffRole(role) { return false }
    if route.staff && !isStaffRole(role) { return false }
    return true
}

public func canCreateIn(_ role: TraceRole, entity: String) -> Bool {
    if isPortalRole(role) { return entity == "harvest-requests" }
    return isStaffRole(role)
}

public func canEditIn(_ role: TraceRole, entity: String) -> Bool {
    _ = entity
    return isStaffRole(role)
}

public func canDeleteIn(_ role: TraceRole, entity: String) -> Bool {
    _ = entity
    return role == .admin
}

public func canIntake(_ role: TraceRole) -> Bool { isStaffRole(role) }
public func canAdvanceBatch(_ role: TraceRole) -> Bool { isStaffRole(role) }
public func canPublishQr(_ role: TraceRole) -> Bool { isStaffRole(role) }
public func canRequestHarvest(_ role: TraceRole) -> Bool { isPortalRole(role) }
public func canInspect(_ role: TraceRole) -> Bool { isStaffRole(role) }
public func canCollect(_ role: TraceRole) -> Bool { isStaffRole(role) }
