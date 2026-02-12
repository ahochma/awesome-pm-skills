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
            // Event Type
            Section {
                HStack(spacing: AppTheme.spacingMD) {
                    ForEach(AdamEventType.allCases) { type in
                        let isSelected = eventType == type
                        Button {
                            Haptics.selection()
                            withAnimation(.easeInOut(duration: 0.2)) {
                                eventType = type
                            }
                        } label: {
                            VStack(spacing: AppTheme.spacingSM) {
                                Image(systemName: type == .dropoff ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(
                                        isSelected
                                            ? (type == .dropoff ? Color.blue : Color.green)
                                            : .secondary
                                    )
                                Text(type.rawValue)
                                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                                    .foregroundStyle(isSelected ? .primary : .secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, AppTheme.spacingMD)
                            .background(
                                isSelected
                                    ? (type == .dropoff ? Color.blue.opacity(0.1) : Color.green.opacity(0.1))
                                    : Color(.tertiarySystemFill)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppTheme.radiusSM, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                SectionHeaderView(title: "EVENT TYPE", icon: "arrow.up.arrow.down")
            }

            // Person
            Section {
                Picker("Assigned person", selection: $selectedPersonId) {
                    ForEach(people, id: \.id) { person in
                        Text(person.name).tag(Optional(person.id))
                    }
                }
            } header: {
                SectionHeaderView(title: "PERSON", icon: "person")
            }

            // Date & Time
            Section {
                DatePicker("Start", selection: $startDate)
                DatePicker("End", selection: $endDate)
            } header: {
                SectionHeaderView(title: "DATE & TIME", icon: "clock")
            }

            // Notes
            Section {
                TextField("Add a note (optional)", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
            } header: {
                SectionHeaderView(title: "NOTES", icon: "note.text")
            }
        }
        .navigationTitle(initialEvent == nil ? "New Event" : "Edit Event")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    guard let id = selectedPersonId,
                          let person = people.first(where: { $0.id == id }) else { return }
                    Haptics.success()
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
                .font(.body.weight(.semibold))
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
