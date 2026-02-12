import Foundation

enum JSONImportParser {
    static func loadData(from url: URL) throws -> Data {
        try Data(contentsOf: url)
    }
}
