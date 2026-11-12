import SwiftUI
import SwiftData

struct HistoryView: View {
    let monthKey: String

    @Environment(\.modelContext) private var modelContext
    @State private var completions: [Completion] = []

    var body: some View {
        List(completions, id: \.id) { item in
            VStack(alignment: .leading) {
                Text(item.choreTitleSnapshot)
                Text("+\(item.pointsSnapshot) • \(item.completedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("History")
        .onAppear(perform: load)
    }

    private func load() {
        guard let range = MonthKey.monthRange(for: monthKey) else { return }
        let descriptor = FetchDescriptor<Completion>(
            predicate: #Predicate<Completion> { $0.completedAt >= range.start && $0.completedAt < range.end }
        )
        completions = (try? modelContext.fetch(descriptor))?.sorted(by: { $0.completedAt > $1.completedAt }) ?? []
    }
}
