import Foundation
import OSLog

enum PersistenceLogger {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "KontoKlar", category: "Persistence")

    static func log(_ error: Error, operation: String) {
        logger.error("\(operation, privacy: .public): \(error.localizedDescription, privacy: .public)")
    }
}

