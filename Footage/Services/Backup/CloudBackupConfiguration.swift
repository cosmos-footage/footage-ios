//
//  CloudBackupConfiguration.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct CloudBackupConfiguration {
    var baseURL: URL
    var isCloudBackupEnabled: Bool
    var isDevelopmentUploadEnabled: Bool
    var requestTimeout: TimeInterval
    var schemaVersion: Int

    init(
        baseURL: URL = URL(string: "https://footage-cloud-backup.invalid")!,
        isCloudBackupEnabled: Bool = false,
        isDevelopmentUploadEnabled: Bool = false,
        requestTimeout: TimeInterval = 30,
        schemaVersion: Int = 1
    ) {
        self.baseURL = baseURL
        self.isCloudBackupEnabled = isCloudBackupEnabled
        self.isDevelopmentUploadEnabled = isDevelopmentUploadEnabled
        self.requestTimeout = requestTimeout
        self.schemaVersion = schemaVersion
    }

    var canPerformDevelopmentUpload: Bool {
        isCloudBackupEnabled && isDevelopmentUploadEnabled
    }
}
