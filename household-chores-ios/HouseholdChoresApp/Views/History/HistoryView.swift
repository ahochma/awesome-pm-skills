import SwiftUI
import SwiftData

struct HistoryView: View {
    let monthKey: String

    @Environment(\.modelContext) private var modelContext
    @State private var completions: [Completion] = []
    @State private var people: [Person] = []

    private var groupedByDay: [(String, [Completion])] {
        let grouped = Dictionary(grouping: completions) { item in
            item.completedAt.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        }
        return grouped.sorted(by: { $0.value.first?.completedAt ?? Date.distantPast > $1.value.first?.completedAt ?? Date.distantPast })
    }

    var body: some View {
        Group {
            if completions.isEmpty {
                EmptyStateView(
                    icon: "clock.arrow.circlepath",
                    title: "No activity",
                    subtitle: "No chores were completed during this period."
                )
            } else {
                List {
                    ForEach(groupedByDay, id: \.0) { day, dayCompletions in
                        Section {
                            ForEach(dayCompletions, id: \.id) { item in
                                HStack(spacing: AppTheme.spacingMD) {
                                    // Person avatar
                                    let person = people.first(where: { $0.id == item.personId })
                                    let personIndex = people.firstIndex(where: { $0.id == item.personId }) ?? 0

                                    ZStack {
                                        Circle()
                                            .fill(AppTheme.color(for: personIndex).opacity(0.15))
                                            .frame(width: 32, height: 32)
                                        Text((person?.name.prefix(1) ?? "?").uppercased())
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(AppTheme.color(for: personIndex))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.choreTitleSnapshot)
                                            .font(.subheadline.weight(.medium))

                                        HStack(spacing: AppTheme.spacingSM) {
                                            if let name = person?.name {
                                                Text(name)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Text(item.completedAt.formatted(.dateTime.hour().minute()))
                                                .font(.caption)
                                                .foregroundStyle(.tertiary)
                                        }
                                    }

                                    Spacer()

                                    PointsBadge(points: item.pointsSnapshot, color: .green)
                                }
                                .padding(.vertical, AppTheme.spacingXS)
                            }
                        } header: {
                            SectionHeaderView(title: day.uppercased())
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
    }

    private func load() {
        people = (try? modelContext.fetch(FetchDescriptor<Person>()).sorted(by: { $0.name < $1.name })) ?? []

        guard let range = MonthKey.monthRange(for: monthKey) else { return }
        let descriptor = FetchDescriptor<Completion>(
            predicate: #Predicate<Completion> { $0.completedAt >= range.start && $0.completedAt < range.end }
        )
        completions = (try? modelContext.fetch(descriptor))?.sorted(by: { $0.completedAt > $1.completedAt }) ?? []
    }
}
