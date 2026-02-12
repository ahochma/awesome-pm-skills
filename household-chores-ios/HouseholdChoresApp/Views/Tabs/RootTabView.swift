import SwiftUI

struct RootTabView: View {
    let container: AppContainer

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(
                    viewModel: HomeViewModel(
                        modelContext: container.modelContext,
                        scoringService: container.scoringService
                    )
                )
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            NavigationStack {
                ChoresListView(viewModel: ChoresViewModel(modelContext: container.modelContext))
            }
            .tabItem {
                Label("Chores", systemImage: "checklist.checked")
            }

            NavigationStack {
                ScoresView(
                    viewModel: ScoresViewModel(
                        modelContext: container.modelContext,
                        scoringService: container.scoringService
                    )
                )
            }
            .tabItem {
                Label("Scores", systemImage: "trophy.fill")
            }

            NavigationStack {
                CalendarView(viewModel: CalendarViewModel(calendarService: container.calendarService))
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }

            NavigationStack {
                SettingsView(
                    viewModel: SettingsViewModel(
                        modelContext: container.modelContext,
                        dataTransferService: container.dataTransferService
                    )
                )
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .tint(.blue)
    }
}
