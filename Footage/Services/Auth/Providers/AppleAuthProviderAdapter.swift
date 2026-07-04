//
//  AppleAuthProviderAdapter.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct AppleAuthProviderAdapter: AuthProviderAdapter {
    let provider: AuthProvider = .apple

    func credential(completion: @escaping (Result<AuthProviderCredential, Error>) -> Void) {
        // Sign in with Apple requires capability and UI review before production use.
        completion(.failure(AuthProviderAdapterError.unavailable))
    }
}
