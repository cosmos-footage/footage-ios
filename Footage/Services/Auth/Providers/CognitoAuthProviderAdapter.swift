//
//  CognitoAuthProviderAdapter.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct CognitoAuthProviderAdapter: AuthProviderAdapter {
    let provider: AuthProvider = .cognito

    func credential(completion: @escaping (Result<AuthProviderCredential, Error>) -> Void) {
        completion(.failure(AuthProviderAdapterError.notImplemented))
    }
}
