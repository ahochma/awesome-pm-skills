import Foundation
import CloudKit
import SwiftData

@MainActor
protocol CloudKitSyncServiceProtocol {
    var syncStatus: SyncStatus { get }
    var lastSyncDate: Date? { get }
    var accountStatus: CKAccountStatus { get }
    
    func checkAccountStatus() async -> CKAccountStatus
    func startMonitoring()
    func stopMonitoring()
}

enum SyncStatus {
    case unknown
    case syncing
    case synced
    case error(String)
}

@MainActor
final class CloudKitSyncService: CloudKitSyncServiceProtocol, ObservableObject {
    @Published var syncStatus: SyncStatus = .unknown
    @Published var lastSyncDate: Date?
    @Published var accountStatus: CKAccountStatus = .noAccount
    
    nonisolated init(containerIdentifier: String = "iCloud.com.bmad.householdchores") {
        // CloudKit disabled
    }
    
    func checkAccountStatus() async -> CKAccountStatus {
        return .noAccount
    }
    
    nonisolated func startMonitoring() {
        // No-op
    }
    
    func stopMonitoring() {
        // No-op
    }
}
