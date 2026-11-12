import Foundation
import SwiftData

@Model
final class Person {
    @Attribute(.unique) var id: UUID
    var name: String
    var avatar: String?
    var colorHex: String?

    init(id: UUID = UUID(), name: String, avatar: String? = nil, colorHex: String? = nil) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.colorHex = colorHex
    }
}
