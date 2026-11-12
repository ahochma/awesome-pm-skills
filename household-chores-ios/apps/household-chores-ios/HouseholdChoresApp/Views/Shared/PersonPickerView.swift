import SwiftUI

struct PersonPickerView: View {
    let people: [Person]
    @Binding var selectedPersonId: UUID?

    var body: some View {
        Picker("Person", selection: $selectedPersonId) {
            ForEach(people, id: \.id) { person in
                Text(person.name).tag(Optional(person.id))
            }
        }
        .pickerStyle(.segmented)
    }
}
