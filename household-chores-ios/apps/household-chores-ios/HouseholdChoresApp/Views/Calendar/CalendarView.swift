import SwiftUI
import SwiftData

struct CalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject var viewModel: CalendarViewModel
    @State private var people: [Person] = []
    @State private var showAdd = false
    @State private var editingEvent: AdamCalendarEvent?

    var body: some View {
        List {
            Section("Permissions") {
                Button("Request Calendar Access") {
                    Task { await viewModel.requestAccess() }
                }
                Text(viewModel.permissionGranted ? "Access granted" : "Access not granted")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Actions") {
                Button("Add Dropoff / Pickup Event") { showAdd = true }
                    .disabled(!viewModel.permissionGranted)
            }

            Section("Upcoming 7 days") {
                ForEach(viewModel.upcomingEvents) { event in
                    VStack(alignment: .leading) {
                        Text(event.title)
                        Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { editingEvent = event }
                    .swipeActions {
                        Button("Edit") {
                            editingEvent = event
                        }
                        Button("Delete", role: .destructive) {
                            viewModel.deleteEvent(id: event.id)
                        }
                    }
                }
                if viewModel.upcomingEvents.isEmpty {
                    Text("No Adam events in next 7 days.")
                        .foregroundStyle(.secondary)
                }
            }

            if let error = viewModel.errorMessage {
                Section("Error") { Text(error).foregroundStyle(.red) }
            }
        }
        .navigationTitle("Calendar")
        .sheet(isPresented: $showAdd) {
            NavigationStack {
                CalendarEventEditorView(people: people, initialEvent: nil) { input in
                    viewModel.createEvent(input: input)
                }
            }
        }
        .sheet(item: $editingEvent) { event in
            NavigationStack {
                CalendarEventEditorView(people: people, initialEvent: event) { input in
                    viewModel.updateEvent(id: event.id, input: input)
                }
            }
        }
        .onAppear {
            people = (try? modelContext.fetch(FetchDescriptor<Person>()).sorted(by: { $0.name < $1.name })) ?? []
            try? viewModel.refreshUpcoming()
        }
    }
}
