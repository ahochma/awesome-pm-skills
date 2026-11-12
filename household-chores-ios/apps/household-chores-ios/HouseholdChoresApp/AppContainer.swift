import SwiftData

struct AppContainer {
    let modelContext: ModelContext
    let scoringService: ScoringServiceProtocol
    let calendarService: CalendarServiceProtocol
    let dataTransferService: DataTransferServiceProtocol

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.scoringService = ScoringService(modelContext: modelContext)
        self.calendarService = CalendarService()
        self.dataTransferService = DataTransferService(modelContext: modelContext)
    }
}
