import Foundation
import SwiftData

@Model
final class Chore {
    @Attribute(.unique) var id: UUID
    var title: String
    var points: Int
    var category: String?
    var isActive: Bool

    init(
        id: UUID = UUID(),
        title: String,
        points: Int,
        category: String? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.title = title
        self.points = points
        self.category = category
        self.isActive = isActive
    }
}
