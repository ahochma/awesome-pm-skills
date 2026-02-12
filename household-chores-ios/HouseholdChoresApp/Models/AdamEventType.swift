import Foundation

enum AdamEventType: String, CaseIterable, Codable, Identifiable {
    case dropoff = "Dropoff"
    case pickup = "Pickup"

    var id: String { rawValue }

    func title(personName: String) -> String {
        "Adam \(rawValue) - \(personName)"
    }
}
