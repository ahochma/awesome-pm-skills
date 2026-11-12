import XCTest
import CloudKit
@testable import HouseholdChoresApp

@MainActor
final class CloudKitSyncTests: XCTestCase {
    var syncService: CloudKitSyncService!
    
    override func setUp() {
        super.setUp()
        syncService = CloudKitSyncService()
    }
    
    override func tearDown() {
        syncService.stopMonitoring()
        syncService = nil
        super.tearDown()
    }
    
    func testSyncServiceInitialization() {
        XCTAssertNotNil(syncService)
        XCTAssertEqual(syncService.syncStatus, .unknown)
    }
    
    func testAccountStatusCheck() async {
        let status = await syncService.checkAccountStatus()
        XCTAssertTrue([.available, .noAccount, .restricted, .couldNotDetermine, .temporarilyUnavailable].contains(status))
    }
    
    func testSyncStatusViewModel() {
        let viewModel = SyncStatusViewModel(syncService: syncService)
        XCTAssertNotNil(viewModel)
        XCTAssertEqual(viewModel.syncStatus, .unknown)
    }
    
    func testSyncStatusIcon() {
        let viewModel = SyncStatusViewModel(syncService: syncService)
        
        viewModel.syncStatus = .synced
        XCTAssertEqual(viewModel.syncStatusIcon, "checkmark.circle.fill")
        
        viewModel.syncStatus = .syncing
        XCTAssertEqual(viewModel.syncStatusIcon, "arrow.clockwise")
        
        viewModel.syncStatus = .error("Test error")
        XCTAssertEqual(viewModel.syncStatusIcon, "exclamationmark.triangle.fill")
    }
    
    func testSyncStatusColor() {
        let viewModel = SyncStatusViewModel(syncService: syncService)
        
        viewModel.syncStatus = .synced
        XCTAssertEqual(viewModel.syncStatusColor, .green)
        
        viewModel.syncStatus = .syncing
        XCTAssertEqual(viewModel.syncStatusColor, .blue)
        
        viewModel.syncStatus = .error("Test error")
        XCTAssertEqual(viewModel.syncStatusColor, .orange)
    }
}
