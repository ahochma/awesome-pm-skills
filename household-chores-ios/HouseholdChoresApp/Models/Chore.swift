import Foundation
import SwiftData

@Model
final class Chore {
    var id: UUID = UUID()
    var title: String = ""
    var points: Int = 0
    var category: String?
    var isActive: Bool = true

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
