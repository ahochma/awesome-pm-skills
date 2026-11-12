import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @State private var exporting = false
    @State private var exportDoc = JSONExportDocument(data: Data())
    @State private var showResetAlert = false
    @State private var isImporting = false

    var body: some View {
        List {
            Section("People") {
                ForEach(viewModel.people, id: \.id) { person in
                    HStack {
                        TextField("Name", text: Binding(
                            get: { viewModel.draftNames[person.id] ?? person.name },
                            set: { viewModel.draftNames[person.id] = $0 }
                        ))
                        Spacer()
                        Button("Save") {
                            viewModel.saveDraftName(for: person)
                        }
                    }
                }
            }

            Section("Data Transfer") {
                Button("Export data") {
                    viewModel.exportData()
                    if let data = viewModel.latestExportData {
                        exportDoc = JSONExportDocument(data: data)
                        exporting = true
                    }
                }

                Button("Import data") {
                    isImporting = true
                }

                if let report = viewModel.importReportText {
                    Text(report).font(.caption).foregroundStyle(.secondary)
                }
            }

            Section("Danger Zone") {
                Button("Reset all data", role: .destructive) {
                    showResetAlert = true
                }
            }

            if let error = viewModel.errorMessage {
                Section("Error") {
                    Text(error).foregroundStyle(.red)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear { viewModel.refresh() }
        .fileExporter(
            isPresented: $exporting,
            document: exportDoc,
            contentType: .json,
            defaultFilename: "household-chores-export"
        ) { _ in }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [UTType.json]
        ) { result in
            guard case .success(let url) = result else { return }
            guard let data = try? JSONImportParser.loadData(from: url) else { return }
            viewModel.importData(from: data)
        }
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) { viewModel.resetAllData() }
        } message: {
            Text("This removes people, chores, completions, and monthly results.")
        }
    }
}
