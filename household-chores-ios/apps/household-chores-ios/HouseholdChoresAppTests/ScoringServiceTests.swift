import XCTest
import SwiftData
@testable import HouseholdChoresApp

final class ScoringServiceTests: XCTestCase {
    func testMarkDoneAndTotals() throws {
        let context = try testModelContext()
        let person = Person(name: "Amit")
        let chore = Chore(title: "Dishes", points: 5)
        context.insert(person)
        context.insert(chore)
        try context.save()

        let service = ScoringService(modelContext: context)
        try service.markDone(chore: chore, person: person, at: ISO8601DateFormatter().date(from: "2026-02-10T10:00:00Z")!)
        try service.markDone(chore: chore, person: person, at: ISO8601DateFormatter().date(from: "2026-02-11T10:00:00Z")!)
        let totals = try service.totals(forMonth: "2026-02")

        XCTAssertEqual(totals[person.id], 10)
    }

    private func testModelContext() throws -> ModelContext {
        let schema = Schema([Person.self, Chore.self, Completion.self, MonthlyResult.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }
}
