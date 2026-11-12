import XCTest
@testable import HouseholdChoresApp

final class MonthKeyTests: XCTestCase {
    func testMonthKeyFormatting() {
        let date = ISO8601DateFormatter().date(from: "2026-02-10T12:00:00Z")!
        XCTAssertEqual(MonthKey.from(date: date), "2026-02")
    }

    func testMonthRange() {
        let range = MonthKey.monthRange(for: "2026-02")
        XCTAssertNotNil(range)
        XCTAssertEqual(MonthKey.from(date: range!.start), "2026-02")
    }
}
