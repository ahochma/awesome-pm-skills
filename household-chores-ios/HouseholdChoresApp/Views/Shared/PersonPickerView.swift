import SwiftUI

struct PersonPickerView: View {
    let people: [Person]
    @Binding var selectedPersonId: UUID?

    var body: some View {
        HStack(spacing: AppTheme.spacingMD) {
            ForEach(Array(people.enumerated()), id: \.element.id) { index, person in
                let isSelected = selectedPersonId == person.id
                let color = AppTheme.color(for: index)

                Button {
                    Haptics.selection()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedPersonId = person.id
                    }
                } label: {
                    VStack(spacing: AppTheme.spacingSM) {
                        ZStack {
                            Circle()
                                .fill(isSelected ? color : color.opacity(0.15))
                                .frame(width: 52, height: 52)

                            Text(person.name.prefix(1).uppercased())
                                .font(.title3.weight(.bold))
                                .foregroundStyle(isSelected ? .white : color)
                        }
                        .overlay {
                            Circle()
                                .strokeBorder(isSelected ? color : .clear, lineWidth: 2.5)
                                .frame(width: 58, height: 58)
                        }
                        .scaleEffect(isSelected ? 1.0 : 0.9)

                        Text(person.name)
                            .font(.caption.weight(isSelected ? .semibold : .regular))
                            .foregroundStyle(isSelected ? .primary : .secondary)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Select \(person.name)")
                .accessibilityAddTraits(isSelected ? [.isSelected] : [])
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppTheme.spacingSM)
    }
}
