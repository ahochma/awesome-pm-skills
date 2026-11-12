import Foundation
import SwiftData

@Model
final class MonthlyResult {
    @Attribute(.unique) var monthKey: String
    var winnerPersonIdsCSV: String
    var pointsByPersonJSON: String
    var closedAt: Date

    init(
        monthKey: String,
        winnerPersonIds: [UUID],
        pointsByPerson: [UUID: Int],
        closedAt: Date = Date()
    ) {
        self.monthKey = monthKey
        self.winnerPersonIdsCSV = winnerPersonIds.map(\.uuidString).joined(separator: ",")
        self.pointsByPersonJSON = Self.encodePoints(pointsByPerson)
        self.closedAt = closedAt
    }

    var winnerPersonIds: [UUID] {
        winnerPersonIdsCSV
            .split(separator: ",")
            .compactMap { UUID(uuidString: String($0)) }
    }

    var pointsByPerson: [UUID: Int] {
        Self.decodePoints(pointsByPersonJSON)
    }

    private static func encodePoints(_ value: [UUID: Int]) -> String {
        let converted = Dictionary(uniqueKeysWithValues: value.map { ($0.key.uuidString, $0.value) })
        guard let data = try? JSONEncoder().encode(converted),
              let raw = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return raw
    }

    private static func decodePoints(_ raw: String) -> [UUID: Int] {
        guard let data = raw.data(using: .utf8),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        var result: [UUID: Int] = [:]
        for (idString, points) in decoded {
            guard let id = UUID(uuidString: idString) else { continue }
            result[id] = points
        }
        return result
    }
}
