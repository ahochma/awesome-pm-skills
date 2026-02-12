import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @State private var exporting = false
    @State private var exportDoc = JSONExportDocument(data: Data())
    @State private var showResetAlert = false
    @State private var isImporting = false
    @State private var showImportSuccess = false

    var body: some View {
        List {
            // MARK: - People
            Section {
                ForEach(Array(viewModel.people.enumerated()), id: \.element.id) { index, person in
                    HStack(spacing: AppTheme.spacingMD) {
                        ZStack {
                            Circle()
                                .fill(AppTheme.color(for: index).opacity(0.15))
                                .frame(width: 36, height: 36)
                            Text(person.name.prefix(1).uppercased())
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(AppTheme.color(for: index))
                        }

                        TextField("Name", text: Binding(
                            get: { viewModel.draftNames[person.id] ?? person.name },
                            set: { viewModel.draftNames[person.id] = $0 }
                        ))
                        .textContentType(.name)

                        Spacer()

                        if viewModel.draftNames[person.id] != person.name {
                            Button {
                                Haptics.success()
                                viewModel.saveDraftName(for: person)
                            } label: {
                                Text("Save")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.accentColor)
                            }
                        }
                    }
                }
            } header: {
                SectionHeaderView(title: "HOUSEHOLD MEMBERS", icon: "person.2")
            }

            // MARK: - Data Transfer
            Section {
                Button {
                    Haptics.light()
                    viewModel.exportData()
                    if let data = viewModel.latestExportData {
                        exportDoc = JSONExportDocument(data: data)
                        exporting = true
                    }
                } label: {
                    HStack(spacing: AppTheme.spacingMD) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundStyle(.blue)
                            .frame(width: 28)
                        Text("Export data")
                            .foregroundStyle(.primary)
                    }
                }

                Button {
                    Haptics.light()
                    isImporting = true
                } label: {
                    HStack(spacing: AppTheme.spacingMD) {
                        Image(systemName: "square.and.arrow.down")
                            .foregroundStyle(.green)
                            .frame(width: 28)
                        Text("Import data")
                            .foregroundStyle(.primary)
                    }
                }

                if let report = viewModel.importReportText {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                        Text(report)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, AppTheme.spacingXS)
                }
            } header: {
                SectionHeaderView(title: "DATA", icon: "externaldrive")
            }

            // MARK: - Danger Zone
            Section {
                Button(role: .destructive) {
                    Haptics.medium()
                    showResetAlert = true
                } label: {
                    HStack(spacing: AppTheme.spacingMD) {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                            .frame(width: 28)
                        Text("Reset all data")
                            .foregroundStyle(.red)
                    }
                }
            } header: {
                SectionHeaderView(title: "DANGER ZONE", icon: "exclamationmark.triangle")
            } footer: {
                Text("This will remove all people, chores, completions, and monthly results, then re-seed default data.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            // MARK: - Error
            if let error = viewModel.errorMessage {
                Section {
                    HStack(spacing: AppTheme.spacingSM) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.subheadline)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
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
            Haptics.success()
        }
        .alert("Reset all data?", isPresented: $showResetAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
                Haptics.medium()
            }
        } message: {
            Text("This removes people, chores, completions, and monthly results. Default data will be re-seeded.")
        }
    }
}
