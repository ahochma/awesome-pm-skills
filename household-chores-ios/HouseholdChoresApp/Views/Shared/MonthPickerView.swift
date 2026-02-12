import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedMonthKey: String
    let keys: [String]

    var body: some View {
        Picker("Month", selection: $selectedMonthKey) {
            ForEach(keys, id: \.self) { key in
                Text(formattedMonth(key)).tag(key)
            }
        }
        .pickerStyle(.menu)
        .tint(.primary)
    }

    private func formattedMonth(_ key: String) -> String {
        let parts = key.split(separator: "-")
        guard parts.count == 2,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              month >= 1 && month <= 12 else { return key }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        if let date = Calendar.current.date(from: components) {
            return formatter.string(from: date)
        }
        return key
    }
}
