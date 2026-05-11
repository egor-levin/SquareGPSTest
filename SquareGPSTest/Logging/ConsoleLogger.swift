//
// Created by Egor Levin
//

import Foundation
import OSLog

struct ConsoleLogger: Logging {
    private let systemLogger: Logger
    
    init(category: String) {
        systemLogger = Logger(
            subsystem: Bundle.main.bundleIdentifier ?? "SquareGPSTest",
            category: category
        )
        
    }
    
    func log(_ event: Any) {
        let stringEvent = String(describing: event)
        log(stringEvent)
    }
    
    func log(_ event: String) {
        systemLogger.log("\(event)")
    }
    
    func log(errorString: String) {
        systemLogger.log(level: .error, "\(errorString)")
    }
    
    func log(error: Error) {
        systemLogger.log(level: .error, "\(error)")
    }
}
