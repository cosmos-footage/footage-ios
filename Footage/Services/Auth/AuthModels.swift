//
//  AuthModels.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum AuthProvider: String, Codable, Equatable {
    case apple
    case cognito
    case email
    case unknown
}

enum AuthLinkState: String, Codable, Equatable {
    case anonymous
    case linking
    case linked
    case failed
    case unavailable
}

struct AuthIdentity: Codable, Equatable {
    var provider: AuthProvider
    var providerSubject: String
    var email: String?
    var linkedAt: Date
    var ownerId: OwnerID
    var authUserId: String?
    var isLinked: Bool
}

struct AuthProviderCredential: Codable, Equatable {
    var provider: AuthProvider
    var providerSubject: String?
    var providerToken: String
    var authorizationCode: String?
    var nonce: String?
    var email: String?
}
