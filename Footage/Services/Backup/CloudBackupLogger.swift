//
//  CloudBackupLogger.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

struct CloudBackupLogger {
    static func info(_ message: String) {
        #if DEBUG
        print("[CloudBackup] \(message)")
        #endif
    }

    static func failure(operation: String, statusCode: Int? = nil) {
        #if DEBUG
        if let statusCode = statusCode {
            print("[CloudBackup] \(operation) failed with status \(statusCode)")
        } else {
            print("[CloudBackup] \(operation) failed")
        }
        #endif
    }
}
