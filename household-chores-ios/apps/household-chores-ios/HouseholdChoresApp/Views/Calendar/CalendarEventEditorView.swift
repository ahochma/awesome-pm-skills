import SwiftUI

struct CalendarEventEditorView: View {
    let people: [Person]
    let initialEvent: AdamCalendarEvent?
    let onSave: (AdamCalendarEventInput) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var eventType: AdamEventType = .pickup
    @State private var selectedPersonId: UUID?
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    @State private var notes = ""

    var body: some View {
        Form {
            Picker("Type", selection: $eventType) {
                ForEach(AdamEventType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            Picker("Assigned person", selection: $selectedPersonId) {
                ForEach(people, id: \.id) { person in
                    Text(person.name).tag(Optional(person.id))
                }
            }
            DatePicker("Start", selection: $startDate)
            DatePicker("End", selection: $endDate)
            TextField("Notes", text: $notes)
        }
        .navigationTitle("Add Adam Event")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard let id = selectedPersonId,
                          let person = people.first(where: { $0.id == id }) else { return }
                    onSave(
                        AdamCalendarEventInput(
                            type: eventType,
                            personName: person.name,
                            startDate: startDate,
                            endDate: endDate,
                            notes: notes.isEmpty ? nil : notes
                        )
                    )
                    dismiss()
                }
            }
        }
        .onAppear {
            selectedPersonId = people.first?.id
            guard let initialEvent else { return }

            startDate = initialEvent.startDate
            endDate = initialEvent.endDate
            notes = initialEvent.notes ?? ""
            if initialEvent.title.contains("Dropoff") {
                eventType = .dropoff
            } else {
                eventType = .pickup
            }
            if let personName = initialEvent.title.components(separatedBy: " - ").last,
               let person = people.first(where: { $0.name == personName }) {
                selectedPersonId = person.id
            }
        }
    }
}
