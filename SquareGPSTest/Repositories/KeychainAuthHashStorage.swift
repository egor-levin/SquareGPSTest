//
// Created by Egor Levin
//

import Foundation
import Security

enum KeychainAuthHashStorageError: Error {
    case loadFailed(OSStatus)
    case encodeFailed(Error)
    case saveFailed(OSStatus)
    case updateFailed(OSStatus)
    case removeFailed(OSStatus)
    case cleanupFailed(Error)
}

final class KeychainAuthHashStorage: AuthHashStorage {

    // MARK: - Private Properties

    private let service = "SquareGPSTest.NavixyAuth"
    private let account = "AuthHash"
    private let logger: KeychainAuthHashStorageLogger

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    // MARK: - init deinit

    init(logger: KeychainAuthHashStorageLogger) {
        self.logger = logger
    }

    // MARK: - Public Methods

    func load() throws -> AuthHash? {
        var query = baseQuery
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnData as String] = true

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            if status != errSecItemNotFound {
                logger.logKeychainError(status, operation: "load auth hash")
                throw KeychainAuthHashStorageError.loadFailed(status)
            }
            return nil
        }

        guard let data = item as? Data else {
            logger.logLoadedAuthHashItemIsNotData()
            try removeCorruptedItem()
            return nil
        }

        do {
            let authHash = try JSONDecoder().decode(AuthHash.self, from: data)
            logger.logAuthHashLoaded()
            return authHash
        } catch {
            logger.logAuthHashDecodeFailed(error)
            try removeCorruptedItem()
            return nil
        }
    }

    func save(_ authHash: AuthHash) throws {
        let data: Data

        do {
            data = try JSONEncoder().encode(authHash)
        } catch {
            logger.logAuthHashEncodeFailed(error)
            throw KeychainAuthHashStorageError.encodeFailed(error)
        }

        var attributes = baseQuery
        attributes[kSecValueData as String] = data
        attributes[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let status = SecItemAdd(attributes as CFDictionary, nil)

        if status == errSecDuplicateItem {
            let updateStatus = SecItemUpdate(
                baseQuery as CFDictionary,
                [
                    kSecValueData as String: data,
                    kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
                ] as CFDictionary
            )

            if updateStatus == errSecSuccess {
                logger.logAuthHashUpdated()
            } else {
                logger.logKeychainError(updateStatus, operation: "update auth hash")
                throw KeychainAuthHashStorageError.updateFailed(updateStatus)
            }
        } else if status == errSecSuccess {
            logger.logAuthHashSaved()
        } else {
            logger.logKeychainError(status, operation: "save auth hash")
            throw KeychainAuthHashStorageError.saveFailed(status)
        }
    }

    func remove() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)

        if status == errSecSuccess {
            logger.logAuthHashRemoved()
        } else if status != errSecItemNotFound {
            logger.logKeychainError(status, operation: "remove auth hash")
            throw KeychainAuthHashStorageError.removeFailed(status)
        }
    }

    // MARK: - Private Methods

    private func removeCorruptedItem() throws {
        do {
            try remove()
        } catch {
            throw KeychainAuthHashStorageError.cleanupFailed(error)
        }
    }
}
