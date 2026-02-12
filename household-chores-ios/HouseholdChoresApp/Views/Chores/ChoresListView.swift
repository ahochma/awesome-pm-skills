import SwiftUI

struct ChoresListView: View {
    @StateObject var viewModel: ChoresViewModel
    @State private var editingChore: Chore?
    @State private var showingAdd = false

    private var groupedChores: [(String, [Chore])] {
        let grouped = Dictionary(grouping: viewModel.chores) { $0.category ?? "General" }
        return grouped.sorted(by: { $0.key < $1.key })
    }

    var body: some View {
        Group {
            if viewModel.chores.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    title: "No chores yet",
                    subtitle: "Add your first chore to start tracking household tasks.",
                    actionLabel: "Add Chore",
                    action: { showingAdd = true }
                )
            } else {
                List {
                    ForEach(groupedChores, id: \.0) { category, chores in
                        Section {
                            ForEach(chores, id: \.id) { chore in
                                ChoreRow(chore: chore)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        Haptics.light()
                                        editingChore = chore
                                    }
                                    .swipeActions(edge: .trailing) {
                                        if chore.isActive {
                                            Button {
                                                withAnimation {
                                                    viewModel.deactivate(chore)
                                                }
                                                Haptics.medium()
                                            } label: {
                                                Label("Deactivate", systemImage: "pause.circle")
                                            }
                                            .tint(.orange)
                                        }
                                    }
                            }
                        } header: {
                            SectionHeaderView(
                                title: category.uppercased(),
                                icon: AppTheme.categoryIcon(for: category)
                            )
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("Chores")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    Haptics.light()
                    showingAdd = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(item: $editingChore) { chore in
            NavigationStack {
                ChoreEditorView(chore: chore, onSave: { id, title, points, category, isActive in
                    viewModel.save(id: id, title: title, points: points, category: category, isActive: isActive)
                })
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                ChoreEditorView(chore: nil, onSave: { id, title, points, category, isActive in
                    viewModel.save(id: id, title: title, points: points, category: category, isActive: isActive)
                })
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .onAppear { viewModel.refresh() }
    }
}

// MARK: - Chore Row

private struct ChoreRow: View {
    let chore: Chore

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            // Category icon
            Image(systemName: AppTheme.categoryIcon(for: chore.category))
                .font(.body)
                .foregroundStyle(AppTheme.categoryColor(for: chore.category).gradient)
                .frame(width: 32, height: 32)
                .background(AppTheme.categoryColor(for: chore.category).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(chore.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(chore.isActive ? .primary : .secondary)

                if !chore.isActive {
                    Text("Inactive")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            PointsBadge(
                points: chore.points,
                color: chore.isActive
                    ? AppTheme.categoryColor(for: chore.category)
                    : .gray
            )
        }
        .padding(.vertical, AppTheme.spacingXS)
        .opacity(chore.isActive ? 1.0 : 0.7)
    }
}
