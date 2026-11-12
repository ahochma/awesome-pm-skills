import Foundation
import SwiftData

@Model
final class Completion {
    var id: UUID = UUID()
    var choreId: UUID = UUID()
    var choreTitleSnapshot: String = ""
    var pointsSnapshot: Int = 0
    var personId: UUID = UUID()
    var completedAt: Date = Date()

    init(
        id: UUID = UUID(),
        choreId: UUID,
        choreTitleSnapshot: String,
        pointsSnapshot: Int,
        personId: UUID,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.choreId = choreId
        self.choreTitleSnapshot = choreTitleSnapshot
        self.pointsSnapshot = pointsSnapshot
        self.personId = personId
        self.completedAt = completedAt
    }
}
