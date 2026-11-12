import SwiftUI
import SwiftData

@main
struct HouseholdChoresApp: App {
    private let modelContainer: ModelContainer

    init() {
        // Ensure the Application Support directory exists before SwiftData/CoreData tries to write the store file.
        let fileManager = FileManager.default
        if let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            if !fileManager.fileExists(atPath: appSupportURL.path) {
                try? fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
            }
        }

        do {
            // Local-only SwiftData store
            let localConfig = ModelConfiguration()
            modelContainer = try ModelContainer(
                for: Person.self,
                    Chore.self,
                    Completion.self,
                    MonthlyResult.self,
                configurations: localConfig
            )
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
