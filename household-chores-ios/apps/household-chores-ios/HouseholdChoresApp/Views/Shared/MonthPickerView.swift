import SwiftUI

struct MonthPickerView: View {
    @Binding var selectedMonthKey: String
    let keys: [String]

    var body: some View {
        Picker("Month", selection: $selectedMonthKey) {
            ForEach(keys, id: \.self) { key in
                Text(key).tag(key)
            }
        }
        .pickerStyle(.menu)
    }
}
