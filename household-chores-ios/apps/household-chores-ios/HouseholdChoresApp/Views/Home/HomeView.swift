import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel

    var body: some View {
        List {
            Section("Who is completing chores?") {
                PersonPickerView(people: viewModel.people, selectedPersonId: $viewModel.selectedPersonId)
            }

            Section("Quick Chores") {
                ForEach(viewModel.topChores, id: \.id) { chore in
                    Button {
                        viewModel.markDone(chore: chore)
                    } label: {
                        HStack {
                            Text(chore.title)
                            Spacer()
                            Text("+\(chore.points)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityLabel("Done \(chore.title)")
                }
            }

            Section("Summary") {
                Text(viewModel.todaySummaryText)
                Text(viewModel.leaderText)
            }

            if let error = viewModel.errorMessage {
                Section("Error") { Text(error).foregroundStyle(.red) }
            }
        }
        .navigationTitle("Home")
        .onAppear { viewModel.refresh() }
    }
}
