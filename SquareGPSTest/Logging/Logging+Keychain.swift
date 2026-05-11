//
// Created by Egor Levin
//

import Foundation
import Security

protocol KeychainAuthHashStorageLogger: Logging {
    func logAuthHashLoaded()
    func logAuthHashSaved()
    func logAuthHashUpdated()
    func logAuthHashRemoved()
    func logLoadedAuthHashItemIsNotData()
    func logAuthHashDecodeFailed(_ error: Error)
    func logAuthHashEncodeFailed(_ error: Error)
    func logKeychainError(_ status: OSStatus, operation: String)
}

extension ConsoleLogger: KeychainAuthHashStorageLogger {
    private var prefix: String { "KeychainAuthHashStorage:" }
    
    func logAuthHashLoaded() {
        log("\(prefix) auth hash loaded")
    }
    
    func logAuthHashSaved() {
        log("\(prefix) auth hash saved")
    }
    
    func logAuthHashUpdated() {
        log("\(prefix) auth hash updated")
    }
    
    func logAuthHashRemoved() {
        log("\(prefix) auth hash removed")
    }
    
    func logLoadedAuthHashItemIsNotData() {
        log(errorString: "\(prefix) loaded auth hash item is not Data")
    }
    
    func logAuthHashDecodeFailed(_ error: Error) {
        log(errorString: "\(prefix) failed to decode auth hash with error: \(error)")
    }
    
    func logAuthHashEncodeFailed(_ error: Error) {
        log(errorString: "\(prefix) failed to encode auth hash with error: \(error)")
    }
    
    func logKeychainError(_ status: OSStatus, operation: String) {
        let message = SecCopyErrorMessageString(status, nil) as String? ?? "Unknown Keychain error"
        log(errorString: "\(prefix) failed to \(operation). Status: \(status). \(message)")
    }
}
