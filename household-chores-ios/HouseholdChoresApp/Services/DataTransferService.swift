import Foundation
import SwiftData

struct ExportPayload: Codable {
    var people: [PersonDTO]
    var chores: [ChoreDTO]
    var completions: [CompletionDTO]
    var monthlyResults: [MonthlyResultDTO]
}

struct PersonDTO: Codable {
    let id: UUID
    let name: String
    let avatar: String?
    let colorHex: String?
}

struct ChoreDTO: Codable {
    let id: UUID
    let title: String
    let points: Int
    let category: String?
    let isActive: Bool
}

struct CompletionDTO: Codable {
    let id: UUID
    let choreId: UUID
    let choreTitleSnapshot: String
    let pointsSnapshot: Int
    let personId: UUID
    let completedAt: Date
}

struct MonthlyResultDTO: Codable {
    let monthKey: String
    let winnerPersonIds: [UUID]
    let pointsByPerson: [UUID: Int]
    let closedAt: Date
}

protocol DataTransferServiceProtocol {
    func exportJSONData() throws -> Data
    @discardableResult
    func importJSONData(_ data: Data) throws -> ImportReport
}

struct ImportReport {
    let insertedPeople: Int
    let insertedChores: Int
    let insertedCompletions: Int
    let insertedMonthlyResults: Int
}

final class DataTransferService: DataTransferServiceProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func exportJSONData() throws -> Data {
        let people = try modelContext.fetch(FetchDescriptor<Person>()).map {
            PersonDTO(id: $0.id, name: $0.name, avatar: $0.avatar, colorHex: $0.colorHex)
        }
        let chores = try modelContext.fetch(FetchDescriptor<Chore>()).map {
            ChoreDTO(id: $0.id, title: $0.title, points: $0.points, category: $0.category, isActive: $0.isActive)
        }
        let completions = try modelContext.fetch(FetchDescriptor<Completion>()).map {
            CompletionDTO(
                id: $0.id,
                choreId: $0.choreId,
                choreTitleSnapshot: $0.choreTitleSnapshot,
                pointsSnapshot: $0.pointsSnapshot,
                personId: $0.personId,
                completedAt: $0.completedAt
            )
        }
        let monthlyResults = try modelContext.fetch(FetchDescriptor<MonthlyResult>()).map {
            MonthlyResultDTO(
                monthKey: $0.monthKey,
                winnerPersonIds: $0.winnerPersonIds,
                pointsByPerson: $0.pointsByPerson,
                closedAt: $0.closedAt
            )
        }
        let payload = ExportPayload(
            people: people,
            chores: chores,
            completions: completions,
            monthlyResults: monthlyResults
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }

    @discardableResult
    func importJSONData(_ data: Data) throws -> ImportReport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(ExportPayload.self, from: data)

        let existingPeople = try Set(modelContext.fetch(FetchDescriptor<Person>()).map(\.id))
        let existingChores = try Set(modelContext.fetch(FetchDescriptor<Chore>()).map(\.id))
        let existingCompletions = try Set(modelContext.fetch(FetchDescriptor<Completion>()).map(\.id))
        let existingMonthKeys = try Set(modelContext.fetch(FetchDescriptor<MonthlyResult>()).map(\.monthKey))

        var insertedPeople = 0
        for dto in payload.people where !existingPeople.contains(dto.id) {
            modelContext.insert(Person(id: dto.id, name: dto.name, avatar: dto.avatar, colorHex: dto.colorHex))
            insertedPeople += 1
        }

        var insertedChores = 0
        for dto in payload.chores where !existingChores.contains(dto.id) {
            modelContext.insert(
                Chore(id: dto.id, title: dto.title, points: dto.points, category: dto.category, isActive: dto.isActive)
            )
            insertedChores += 1
        }

        var insertedCompletions = 0
        for dto in payload.completions where !existingCompletions.contains(dto.id) {
            modelContext.insert(
                Completion(
                    id: dto.id,
                    choreId: dto.choreId,
                    choreTitleSnapshot: dto.choreTitleSnapshot,
                    pointsSnapshot: dto.pointsSnapshot,
                    personId: dto.personId,
                    completedAt: dto.completedAt
                )
            )
            insertedCompletions += 1
        }

        var insertedMonthlyResults = 0
        for dto in payload.monthlyResults where !existingMonthKeys.contains(dto.monthKey) {
            modelContext.insert(
                MonthlyResult(
                    monthKey: dto.monthKey,
                    winnerPersonIds: dto.winnerPersonIds,
                    pointsByPerson: dto.pointsByPerson,
                    closedAt: dto.closedAt
                )
            )
            insertedMonthlyResults += 1
        }

        try modelContext.save()
        return ImportReport(
            insertedPeople: insertedPeople,
            insertedChores: insertedChores,
            insertedCompletions: insertedCompletions,
            insertedMonthlyResults: insertedMonthlyResults
        )
    }
}
