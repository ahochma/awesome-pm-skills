import SwiftUI
import SwiftData

@main
struct HouseholdChoresApp: App {
    private let modelContainer: ModelContainer

    init() {
        let schema = Schema([
            Person.self,
            Chore.self,
            Completion.self,
            MonthlyResult.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            SeedDataLoader.seedIfNeeded(modelContext: modelContainer.mainContext)
        } catch {
            fatalError("Failed to initialize model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootTabView(container: AppContainer(modelContext: modelContainer.mainContext))
        }
        .modelContainer(modelContainer)
    }
}
