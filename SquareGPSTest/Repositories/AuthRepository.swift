//
// Created by Egor Levin
//

import Foundation
import Security

protocol AuthHashStorage {
    func load() throws -> AuthHash?
    func save(_ authHash: AuthHash) throws
    func remove() throws
}

actor AuthRepository {

    // MARK: - Private Properties

    private let loginProvider: () -> String
    private let passwordProvider: () -> String

    private let authHashStorage: AuthHashStorage
    private var authService: NavixyAuthService

    private var refreshHashTask: Task<AuthHash, Error>?

    private var _localAuthHash: AuthHash?

    // MARK: - init deinit

    init(
        loginProvider: @escaping () -> String,
        passwordProvider: @escaping () -> String,
        authService: NavixyAuthService,
        authHashStorage: AuthHashStorage
    ) {
        self.loginProvider = loginProvider
        self.passwordProvider = passwordProvider
        self.authService = authService
        self.authHashStorage = authHashStorage
    }

    // MARK: - Public Methods

    func getAuthHash(ignoringCache: Bool = false) async throws -> AuthHash {
        if let refreshHashTask {
            return try await refreshHashTask.value
        }

        if !ignoringCache, let localAuthHash = try localAuthHash() {
            return localAuthHash
        }

        let refreshHashTask = Task {
            let login = loginProvider()
            let password = passwordProvider()
            let hash = try await authService.getAuthHash(login: login, password: password)
            let generation = (try localAuthHash()?.generation ?? 0) + 1
            let authHash = AuthHash(value: hash, generation: generation)
            try saveLocalAuthHash(authHash)
            self.refreshHashTask = nil
            return authHash
        }
        self.refreshHashTask = refreshHashTask

        do {
            return try await refreshHashTask.value
        } catch {
            self.refreshHashTask = nil
            throw error
        }
    }

    func invalidateAuthHash(forGeneration generation: Int) async throws {
        guard refreshHashTask == nil, try localAuthHash()?.generation == generation else {
            return
        }

        try removeLocalAuthHash()
    }

    // MARK: - Private Methods

    private func localAuthHash() throws -> AuthHash? {
        if let _localAuthHash {
            return _localAuthHash
        } else {
            _localAuthHash = try authHashStorage.load()
            return _localAuthHash
        }
    }

    private func saveLocalAuthHash(_ authHash: AuthHash) throws {
        try authHashStorage.save(authHash)
        _localAuthHash = authHash
    }

    private func removeLocalAuthHash() throws {
        defer {
            _localAuthHash = nil
        }
        try authHashStorage.remove()
    }
}
