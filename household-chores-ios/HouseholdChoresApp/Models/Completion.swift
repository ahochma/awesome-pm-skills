import Foundation
import SwiftData

@Model
final class Completion {
    @Attribute(.unique) var id: UUID
    var choreId: UUID
    var choreTitleSnapshot: String
    var pointsSnapshot: Int
    var personId: UUID
    var completedAt: Date

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
