import Foundation
import Combine
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var people: [Person] = []
    @Published var selectedPersonId: UUID?
    @Published var topChores: [Chore] = []
    @Published var todaySummaryText: String = "No completions today"
    @Published var leaderText: String = "Current leader: -"
    @Published var errorMessage: String?

    private let modelContext: ModelContext
    private let scoringService: ScoringServiceProtocol

    init(modelContext: ModelContext, scoringService: ScoringServiceProtocol) {
        self.modelContext = modelContext
        self.scoringService = scoringService
    }

    func refresh() {
        do {
            let peopleList = try modelContext.fetch(FetchDescriptor<Person>())
            people = peopleList.sorted(by: { $0.name < $1.name })
            if selectedPersonId == nil {
                selectedPersonId = people.first?.id
            }

            let activeChores = try modelContext.fetch(
                FetchDescriptor<Chore>(predicate: #Predicate<Chore> { $0.isActive })
            )
            topChores = Array(activeChores.sorted(by: { $0.points > $1.points }).prefix(6))

            let todayTotals = try scoringService.todayTotals()
            let summary = people.compactMap { person -> String? in
                guard let points = todayTotals[person.id], points > 0 else { return nil }
                return "\(person.name) +\(points)"
            }
            todaySummaryText = summary.isEmpty ? "No completions today" : summary.joined(separator: ", ")
            if let leader = try scoringService.currentLeaderName() {
                leaderText = "Current leader: \(leader)"
            } else {
                leaderText = "Current leader: -"
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markDone(chore: Chore) {
        guard let selectedPersonId,
              let person = people.first(where: { $0.id == selectedPersonId }) else {
            errorMessage = "Select a person first."
            return
        }
        do {
            try scoringService.markDone(chore: chore, person: person, at: Date())
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
