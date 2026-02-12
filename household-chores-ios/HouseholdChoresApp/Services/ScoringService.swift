import Foundation
import SwiftData

protocol ScoringServiceProtocol {
    @discardableResult
    func markDone(chore: Chore, person: Person, at date: Date) throws -> Completion
    func totals(forMonth monthKey: String) throws -> [UUID: Int]
    func closeMonth(_ monthKey: String) throws -> MonthlyResult
    func todayTotals() throws -> [UUID: Int]
    func currentLeaderName() throws -> String?
    func winsLastSixMonths() throws -> [UUID: Int]
}

enum ScoringError: Error, LocalizedError {
    case monthAlreadyClosed(String)
    case invalidMonthKey(String)

    var errorDescription: String? {
        switch self {
        case .monthAlreadyClosed(let key):
            return "Month \(key) has already been closed."
        case .invalidMonthKey(let key):
            return "Invalid month key: \(key)"
        }
    }
}

final class ScoringService: ScoringServiceProtocol {
    private let modelContext: ModelContext
    private let calendar = Calendar.current

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    @discardableResult
    func markDone(chore: Chore, person: Person, at date: Date = Date()) throws -> Completion {
        let completion = Completion(
            choreId: chore.id,
            choreTitleSnapshot: chore.title,
            pointsSnapshot: chore.points,
            personId: person.id,
            completedAt: date
        )
        modelContext.insert(completion)
        try modelContext.save()
        return completion
    }

    func totals(forMonth monthKey: String) throws -> [UUID: Int] {
        guard let range = MonthKey.monthRange(for: monthKey) else {
            throw ScoringError.invalidMonthKey(monthKey)
        }

        let descriptor = FetchDescriptor<Completion>(
            predicate: #Predicate<Completion> {
                $0.completedAt >= range.start && $0.completedAt < range.end
            }
        )
        let completions = try modelContext.fetch(descriptor)
        return aggregate(completions: completions)
    }

    func closeMonth(_ monthKey: String) throws -> MonthlyResult {
        let existing = try modelContext.fetch(
            FetchDescriptor<MonthlyResult>(predicate: #Predicate<MonthlyResult> { $0.monthKey == monthKey })
        )
        if !existing.isEmpty {
            throw ScoringError.monthAlreadyClosed(monthKey)
        }

        let points = try totals(forMonth: monthKey)
        let maxPoints = points.values.max() ?? 0
        let winners = points.filter { $0.value == maxPoints && maxPoints > 0 }.map(\.key)
        let result = MonthlyResult(monthKey: monthKey, winnerPersonIds: winners, pointsByPerson: points)
        modelContext.insert(result)
        try modelContext.save()
        return result
    }

    func todayTotals() throws -> [UUID: Int] {
        let start = calendar.startOfDay(for: Date())
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return [:] }
        let descriptor = FetchDescriptor<Completion>(
            predicate: #Predicate<Completion> { $0.completedAt >= start && $0.completedAt < end }
        )
        return aggregate(completions: try modelContext.fetch(descriptor))
    }

    func currentLeaderName() throws -> String? {
        let month = MonthKey.from(date: Date())
        let totalsByPerson = try totals(forMonth: month)
        guard let (winnerId, winnerPoints) = totalsByPerson.max(by: { $0.value < $1.value }), winnerPoints > 0 else {
            return nil
        }
        let persons = try modelContext.fetch(FetchDescriptor<Person>())
        return persons.first(where: { $0.id == winnerId })?.name
    }

    func winsLastSixMonths() throws -> [UUID: Int] {
        let keys = Set(MonthKey.lastMonthKeys(count: 6))
        let results = try modelContext.fetch(FetchDescriptor<MonthlyResult>())
        var wins: [UUID: Int] = [:]
        for result in results where keys.contains(result.monthKey) {
            for winnerId in result.winnerPersonIds {
                wins[winnerId, default: 0] += 1
            }
        }
        return wins
    }

    private func aggregate(completions: [Completion]) -> [UUID: Int] {
        var totals: [UUID: Int] = [:]
        for completion in completions {
            totals[completion.personId, default: 0] += completion.pointsSnapshot
        }
        return totals
    }
}
