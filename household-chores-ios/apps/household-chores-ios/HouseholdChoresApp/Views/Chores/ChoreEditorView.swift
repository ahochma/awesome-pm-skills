import SwiftUI

struct ChoreEditorView: View {
    let chore: Chore?
    let onSave: (UUID?, String, Int, String?, Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var points: Int = 5
    @State private var category: String = ""
    @State private var isActive: Bool = true

    var body: some View {
        Form {
            TextField("Title", text: $title)
            Stepper("Points: \(points)", value: $points, in: 1...100)
            TextField("Category (optional)", text: $category)
            Toggle("Active", isOn: $isActive)
        }
        .navigationTitle(chore == nil ? "Add Chore" : "Edit Chore")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    onSave(
                        chore?.id,
                        title,
                        points,
                        category.isEmpty ? nil : category,
                        isActive
                    )
                    dismiss()
                }
            }
        }
        .onAppear {
            guard let chore else { return }
            title = chore.title
            points = chore.points
            category = chore.category ?? ""
            isActive = chore.isActive
        }
    }
}
