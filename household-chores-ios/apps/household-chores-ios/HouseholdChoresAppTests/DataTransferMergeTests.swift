import XCTest
import SwiftData
@testable import HouseholdChoresApp

final class DataTransferMergeTests: XCTestCase {
    func testImportIsIdempotentByUUID() throws {
        let context = try testModelContext()
        let service = DataTransferService(modelContext: context)

        let personId = UUID()
        let payload = ExportPayload(
            people: [PersonDTO(id: personId, name: "Amit", avatar: nil, colorHex: nil)],
            chores: [],
            completions: [],
            monthlyResults: []
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)

        let first = try service.importJSONData(data)
        let second = try service.importJSONData(data)

        XCTAssertEqual(first.insertedPeople, 1)
        XCTAssertEqual(second.insertedPeople, 0)
    }

    private func testModelContext() throws -> ModelContext {
        let schema = Schema([Person.self, Chore.self, Completion.self, MonthlyResult.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [config])
        return ModelContext(container)
    }
}
