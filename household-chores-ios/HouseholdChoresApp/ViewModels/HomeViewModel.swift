import Foundation
import Combine
import SwiftData

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var people: [Person] = []
    @Published var selectedPersonId: UUID?
    @Published var topChores: [Chore] = []
    @Published var todayTotals: [UUID: Int] = [:]
    @Published var leaderName: String?
    @Published var todayCompletionCount: Int = 0
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

            todayTotals = try scoringService.todayTotals()
            todayCompletionCount = todayTotals.values.reduce(0, +)
            leaderName = try scoringService.currentLeaderName()
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
