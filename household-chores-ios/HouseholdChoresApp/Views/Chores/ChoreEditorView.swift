import SwiftUI

struct ChoreEditorView: View {
    let chore: Chore?
    let onSave: (UUID?, String, Int, String?, Bool) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var title: String = ""
    @State private var points: Int = 5
    @State private var category: String = ""
    @State private var isActive: Bool = true
    @State private var showValidation = false

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && points > 0
    }

    private let categoryOptions = ["Kitchen", "Cleaning", "Laundry", "Shopping", "General"]

    var body: some View {
        Form {
            // Title
            Section {
                TextField("Chore name", text: $title)
                    .font(.body)

                if showValidation && title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Name is required")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } header: {
                SectionHeaderView(title: "NAME", icon: "pencil")
            }

            // Points
            Section {
                HStack {
                    Text("Points")
                    Spacer()
                    HStack(spacing: AppTheme.spacingMD) {
                        Button {
                            if points > 1 {
                                points -= 1
                                Haptics.light()
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(points > 1 ? .blue : .gray.opacity(0.3))
                        }
                        .buttonStyle(.plain)

                        Text("\(points)")
                            .font(.title3.weight(.bold).monospacedDigit())
                            .frame(minWidth: 32)
                            .contentTransition(.numericText())

                        Button {
                            if points < 100 {
                                points += 1
                                Haptics.light()
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(points < 100 ? .blue : .gray.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                    }
                }
            } header: {
                SectionHeaderView(title: "POINTS", icon: "star")
            }

            // Category
            Section {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppTheme.spacingSM) {
                        ForEach(categoryOptions, id: \.self) { option in
                            let isSelected = category.lowercased() == option.lowercased()
                            Button {
                                Haptics.selection()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    category = option
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: AppTheme.categoryIcon(for: option))
                                        .font(.caption)
                                    Text(option)
                                        .font(.subheadline.weight(isSelected ? .semibold : .regular))
                                }
                                .padding(.horizontal, AppTheme.spacingMD)
                                .padding(.vertical, AppTheme.spacingSM)
                                .background(
                                    isSelected
                                        ? AppTheme.categoryColor(for: option).opacity(0.15)
                                        : Color(.tertiarySystemFill)
                                )
                                .foregroundStyle(
                                    isSelected
                                        ? AppTheme.categoryColor(for: option)
                                        : .secondary
                                )
                                .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, AppTheme.spacingXS)
                }
            } header: {
                SectionHeaderView(title: "CATEGORY", icon: "tag")
            }

            // Active toggle
            Section {
                Toggle(isOn: $isActive) {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: isActive ? "checkmark.circle.fill" : "pause.circle.fill")
                            .foregroundStyle(isActive ? .green : .orange)
                        Text(isActive ? "Active" : "Inactive")
                    }
                }
                .tint(.green)
            }
        }
        .navigationTitle(chore == nil ? "New Chore" : "Edit Chore")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if isValid {
                        Haptics.success()
                        onSave(
                            chore?.id,
                            title,
                            points,
                            category.isEmpty ? nil : category,
                            isActive
                        )
                        dismiss()
                    } else {
                        showValidation = true
                        Haptics.error()
                    }
                }
                .font(.body.weight(.semibold))
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
