import SwiftUI

struct ScoresView: View {
    @StateObject var viewModel: ScoresViewModel

    private var monthKeys: [String] {
        MonthKey.lastMonthKeys(count: 12)
    }

    var body: some View {
        List {
            Section("Month") {
                MonthPickerView(selectedMonthKey: $viewModel.selectedMonthKey, keys: monthKeys)
                    .onChange(of: viewModel.selectedMonthKey) { _, _ in viewModel.refresh() }

                Button("Close month") {
                    viewModel.closeSelectedMonth()
                }
            }

            Section("Points table") {
                ForEach(viewModel.people, id: \.id) { person in
                    HStack {
                        Text(person.name)
                        Spacer()
                        Text("\(viewModel.totalsByPerson[person.id, default: 0])")
                    }
                }
            }

            Section("Last 12 months winners") {
                ForEach(viewModel.monthlyResults, id: \.monthKey) { result in
                    VStack(alignment: .leading) {
                        Text(result.monthKey)
                        Text(viewModel.winnerText(for: result))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section("Last 6 months summary") {
                ForEach(viewModel.people, id: \.id) { person in
                    HStack {
                        Text(person.name)
                        Spacer()
                        Text("\(viewModel.sixMonthWins[person.id, default: 0]) wins")
                    }
                }
            }

            Section {
                NavigationLink("View completion history") {
                    HistoryView(monthKey: viewModel.selectedMonthKey)
                }
            }

            if let error = viewModel.errorMessage {
                Section("Error") { Text(error).foregroundStyle(.red) }
            }
        }
        .navigationTitle("Scores")
        .onAppear { viewModel.refresh() }
    }
}
