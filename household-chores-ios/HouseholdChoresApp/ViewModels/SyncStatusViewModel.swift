import Foundation
import CloudKit
import SwiftUI

@MainActor
final class SyncStatusViewModel: ObservableObject {
    @Published var syncStatus: SyncStatus = .unknown
    @Published var lastSyncDate: Date?
    @Published var accountStatus: CKAccountStatus = .couldNotDetermine
    @Published var accountStatusMessage: String = ""
    
    private let syncService: CloudKitSyncServiceProtocol
    
    init(syncService: CloudKitSyncServiceProtocol) {
        self.syncService = syncService
        updateFromService()
    }
    
    func refresh() {
        Task {
            _ = await syncService.checkAccountStatus()
            updateFromService()
        }
    }
    
    private func updateFromService() {
        syncStatus = syncService.syncStatus
        lastSyncDate = syncService.lastSyncDate
        accountStatus = syncService.accountStatus
        
        switch accountStatus {
        case .available:
            accountStatusMessage = "iCloud account signed in"
        case .noAccount:
            accountStatusMessage = "No iCloud account"
        case .restricted:
            accountStatusMessage = "iCloud account restricted"
        case .couldNotDetermine:
            accountStatusMessage = "Unable to determine iCloud status"
        case .temporarilyUnavailable:
            accountStatusMessage = "iCloud temporarily unavailable"
        @unknown default:
            accountStatusMessage = "Unknown iCloud status"
        }
    }
    
    var syncStatusIcon: String {
        switch syncStatus {
        case .unknown:
            return "questionmark.circle"
        case .syncing:
            return "arrow.clockwise"
        case .synced:
            return "checkmark.circle.fill"
        case .error:
            return "exclamationmark.triangle.fill"
        }
    }
    
    var syncStatusColor: Color {
        switch syncStatus {
        case .unknown:
            return .gray
        case .syncing:
            return .blue
        case .synced:
            return .green
        case .error:
            return .orange
        }
    }
    
    var syncStatusText: String {
        switch syncStatus {
        case .unknown:
            return "Unknown"
        case .syncing:
            return "Syncing..."
        case .synced:
            if let lastSync = lastSyncDate {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .abbreviated
                return "Synced \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
            }
            return "Synced"
        case .error(let message):
            return message
        }
    }
}
