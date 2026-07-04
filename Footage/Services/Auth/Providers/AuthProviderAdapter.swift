//
//  AuthProviderAdapter.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

protocol AuthProviderAdapter {
    var provider: AuthProvider { get }
    func credential(completion: @escaping (Result<AuthProviderCredential, Error>) -> Void)
}

enum AuthProviderAdapterError: Error {
    case unavailable
    case notImplemented
}
