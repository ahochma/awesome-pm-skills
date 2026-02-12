import Foundation
import SwiftData

enum SeedDataLoader {
    static func seedIfNeeded(modelContext: ModelContext) {
        let descriptor = FetchDescriptor<Person>()
        guard (try? modelContext.fetchCount(descriptor)) == 0 else { return }

        modelContext.insert(Person(name: "Amit"))
        modelContext.insert(Person(name: "Gal"))

        let defaults: [(String, Int, String)] = [
            ("Dishes", 5, "Kitchen"),
            ("Laundry", 8, "Laundry"),
            ("Vacuum", 7, "Cleaning"),
            ("Trash", 4, "General"),
            ("Grocery run", 10, "Shopping"),
            ("Bathroom cleanup", 9, "Cleaning")
        ]

        for chore in defaults {
            modelContext.insert(Chore(title: chore.0, points: chore.1, category: chore.2, isActive: true))
        }

        try? modelContext.save()
    }
}
