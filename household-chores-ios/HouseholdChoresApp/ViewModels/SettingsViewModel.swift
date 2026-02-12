import Foundation
import Combine
import SwiftData

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var people: [Person] = []
    @Published var draftNames: [UUID: String] = [:]
    @Published var latestExportData: Data?
    @Published var importReportText: String?
    @Published var errorMessage: String?

    private let modelContext: ModelContext
    private let dataTransferService: DataTransferServiceProtocol

    init(modelContext: ModelContext, dataTransferService: DataTransferServiceProtocol) {
        self.modelContext = modelContext
        self.dataTransferService = dataTransferService
    }

    func refresh() {
        do {
            people = try modelContext.fetch(FetchDescriptor<Person>()).sorted(by: { $0.name < $1.name })
            draftNames = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0.name) })
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func renamePerson(_ person: Person, to name: String) {
        let clean = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty else { return }
        person.name = clean
        do {
            try modelContext.save()
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveDraftName(for person: Person) {
        guard let draft = draftNames[person.id] else { return }
        renamePerson(person, to: draft)
    }

    func exportData() {
        do {
            latestExportData = try dataTransferService.exportJSONData()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func importData(from data: Data) {
        do {
            let report = try dataTransferService.importJSONData(data)
            importReportText = "Imported: +\(report.insertedPeople) people, +\(report.insertedChores) chores, +\(report.insertedCompletions) completions, +\(report.insertedMonthlyResults) month results."
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func resetAllData() {
        do {
            let completions = try modelContext.fetch(FetchDescriptor<Completion>())
            for item in completions { modelContext.delete(item) }
            let monthly = try modelContext.fetch(FetchDescriptor<MonthlyResult>())
            for item in monthly { modelContext.delete(item) }
            let chores = try modelContext.fetch(FetchDescriptor<Chore>())
            for item in chores { modelContext.delete(item) }
            let peopleItems = try modelContext.fetch(FetchDescriptor<Person>())
            for item in peopleItems { modelContext.delete(item) }
            try modelContext.save()
            SeedDataLoader.seedIfNeeded(modelContext: modelContext)
            refresh()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
