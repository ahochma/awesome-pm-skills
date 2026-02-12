import Foundation
import Combine
import SwiftData

@MainActor
final class ScoresViewModel: ObservableObject {
    @Published var selectedMonthKey: String = MonthKey.from(date: Date())
    @Published var totalsByPerson: [UUID: Int] = [:]
    @Published var people: [Person] = []
    @Published var monthlyResults: [MonthlyResult] = []
    @Published var sixMonthWins: [UUID: Int] = [:]
    @Published var errorMessage: String?

    private let modelContext: ModelContext
    private let scoringService: ScoringServiceProtocol

    init(modelContext: ModelContext, scoringService: ScoringServiceProtocol) {
        self.modelContext = modelContext
        self.scoringService = scoringService
    }

    func refresh() {
        do {
            people = try modelContext.fetch(FetchDescriptor<Person>()).sorted(by: { $0.name < $1.name })
            totalsByPerson = try scoringService.totals(forMonth: selectedMonthKey)
            monthlyResults = try modelContext.fetch(FetchDescriptor<MonthlyResult>())
                .sorted(by: { $0.monthKey > $1.monthKey })
            sixMonthWins = try scoringService.winsLastSixMonths()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func closeSelectedMonth() {
        do {
            _ = try scoringService.closeMonth(selectedMonthKey)
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func winnerText(for result: MonthlyResult) -> String {
        let names = people
            .filter { result.winnerPersonIds.contains($0.id) }
            .map(\.name)
            .sorted()
        if names.isEmpty { return "No winner" }
        if names.count == 1 { return names[0] }
        return "Tie: \(names.joined(separator: ", "))"
    }
}
