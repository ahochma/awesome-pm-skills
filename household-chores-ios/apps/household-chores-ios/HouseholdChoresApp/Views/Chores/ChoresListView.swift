import SwiftUI

struct ChoresListView: View {
    @StateObject var viewModel: ChoresViewModel
    @State private var editingChore: Chore?
    @State private var showingAdd = false

    var body: some View {
        List {
            ForEach(viewModel.chores, id: \.id) { chore in
                HStack {
                    VStack(alignment: .leading) {
                        Text(chore.title)
                        Text("\(chore.points) pts")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if !chore.isActive {
                        Text("Inactive").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { editingChore = chore }
                .swipeActions {
                    Button("Deactivate", role: .destructive) { viewModel.deactivate(chore) }
                }
            }
        }
        .navigationTitle("Chores")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { showingAdd = true } label: { Image(systemName: "plus") }
            }
        }
        .sheet(item: $editingChore) { chore in
            NavigationStack {
                ChoreEditorView(chore: chore, onSave: viewModel.save)
            }
        }
        .sheet(isPresented: $showingAdd) {
            NavigationStack {
                ChoreEditorView(chore: nil, onSave: viewModel.save)
            }
        }
        .onAppear { viewModel.refresh() }
    }
}
