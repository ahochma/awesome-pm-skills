import XCTest
import SwiftData
@testable import HouseholdChoresApp

final class MonthCloseTests: XCTestCase {
    func testCloseMonthOnce() throws {
        let context = try testModelContext()
        let person = Person(name: "Gal")
        let chore = Chore(title: "Laundry", points: 8)
        context.insert(person)
        context.insert(chore)
        try context.save()

        let service = ScoringService(modelContext: context)
        try service.markDone(chore: chore, person: person, at: ISO8601DateFormatter().date(from: "2026-02-01T08:00:00Z")!)
        _ = try service.closeMonth("2026-02")

        XCTAssertThrowsError(try service.closeMonth("2026-02"))
    }

    private func testModelContext() throws -> ModelContext {
        let schema = Schema([Person.self, Chore.self, Completion.self, MonthlyResult.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }
}
