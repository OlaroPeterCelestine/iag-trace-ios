import Foundation

public let batchStages = ["Intake", "Wet mill", "Drying", "Dry mill", "Approved", "Exported"]
public let intakeTypes = ["Farm", "Cooperative", "Shop", "Factory"]

public func nextCode(_ prefix: String, _ existing: [String]) -> String {
    var used = Set<Int>()
    let pattern = "^\(NSRegularExpression.escapedPattern(for: prefix))-(\\d+)$"
    let re = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
    for code in existing {
        if let match = re?.firstMatch(in: code, range: NSRange(code.startIndex..., in: code)),
           let range = Range(match.range(at: 1), in: code),
           let n = Int(code[range]) {
            used.insert(n)
        }
    }
    var n = existing.count + 1
    while used.contains(n) { n += 1 }
    return "\(prefix)-\(String(format: "%04d", n))"
}

public func netKg(_ gross: String, _ tare: String) -> String {
    let net = (Double(gross) ?? 0) - (Double(tare) ?? 0)
    return String(format: "%.1f", max(0, net))
}

public func hasGps(_ row: TraceRecord?) -> Bool {
    guard let row else { return false }
    let gps = row["gps"].trimmingCharacters(in: .whitespacesAndNewlines)
    let lat = row["latitude"].trimmingCharacters(in: .whitespacesAndNewlines)
    let lng = row["longitude"].trimmingCharacters(in: .whitespacesAndNewlines)
    if !lat.isEmpty && !lng.isEmpty { return true }
    return gps.range(of: #"[-+]?\d+(\.\d+)?\s*,\s*[-+]?\d+(\.\d+)?"#, options: .regularExpression) != nil
}

public func normalizeStage(_ raw: String) -> String {
    let key = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    for s in batchStages where s.lowercased() == key { return s }
    return "Intake"
}

public func stageIndex(_ raw: String) -> Int { batchStages.firstIndex(of: normalizeStage(raw)) ?? -1 }

public func nextStage(_ raw: String) -> String? {
    let i = stageIndex(raw)
    if i < 0 || i >= batchStages.count - 1 { return nil }
    return batchStages[i + 1]
}

public func eudrStatus(_ farmer: TraceRecord, _ farm: TraceRecord?) -> EudrResult {
    let gps = hasGps(farm) || hasGps(farmer) ? "verified" : "missing"
    let farmerBio = farmer["bio"].trimmingCharacters(in: .whitespacesAndNewlines)
    let farmBio = farm?["bio"].trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    let bio = (!farmerBio.isEmpty || !farmBio.isEmpty) ? "recorded" : "missing"
    let satRaw = (farmer["satellite"].isEmpty ? (farm?["satellite"] ?? "") : farmer["satellite"]).lowercased()
    let satellite = satRaw.range(of: "pass|ok|clear", options: .regularExpression) != nil ? "pass" : "pending"
    let due = (farmer["dueDiligence"].isEmpty ? (farm?["dueDiligence"] ?? "") : farmer["dueDiligence"])
        .trimmingCharacters(in: .whitespacesAndNewlines)
    let status = gps == "verified" && bio == "recorded" && satellite == "pass" && !due.isEmpty ? "Compliant" : "Incomplete"
    return EudrResult(gps: gps, satellite: satellite, bio: bio, dueDiligence: due, status: status)
}

public func matchesQuery(_ row: TraceRecord, _ query: String) -> Bool {
    let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    if needle.isEmpty { return true }
    return row.data.values.joined(separator: " ").lowercased().contains(needle)
}

public func recordStamp(_ row: TraceRecord) -> Int {
    let iso = ISO8601DateFormatter()
    iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    for key in ["updatedAt", "createdAt", "date"] {
        let raw = row[key]
        if let d = iso.date(from: raw) ?? ISO8601DateFormatter().date(from: raw) {
            return Int(d.timeIntervalSince1970)
        }
        if raw.count == 10, let d = DateFormatter.isoDate.date(from: raw) {
            return Int(d.timeIntervalSince1970)
        }
    }
    return 0
}

private extension DateFormatter {
    static let isoDate: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()
}
