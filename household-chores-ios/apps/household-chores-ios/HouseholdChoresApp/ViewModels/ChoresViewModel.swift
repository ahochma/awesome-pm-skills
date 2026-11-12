import Foundation
import Combine
import SwiftData

@MainActor
final class ChoresViewModel: ObservableObject {
    @Published var chores: [Chore] = []
    @Published var errorMessage: String?

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func refresh() {
        do {
            let descriptor = FetchDescriptor<Chore>()
            chores = try modelContext.fetch(descriptor).sorted(by: { $0.title < $1.title })
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func save(id: UUID?, title: String, points: Int, category: String?, isActive: Bool) {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, points > 0 else {
            errorMessage = "Title is required and points must be greater than 0."
            return
        }

        do {
            if let id, let existing = chores.first(where: { $0.id == id }) {
                existing.title = title
                existing.points = points
                existing.category = category
                existing.isActive = isActive
            } else {
                modelContext.insert(
                    Chore(title: title, points: points, category: category, isActive: isActive)
                )
            }
            try modelContext.save()
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deactivate(_ chore: Chore) {
        chore.isActive = false
        try? modelContext.save()
        refresh()
    }
}
