//
//  FileBackedBackupPayloadStager.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum FileBackedBackupPayloadStagerError: Error {
    case gzipCompressionUnsupported
    case stagedFileOutsidePrivateDirectory
}

final class FileBackedBackupPayloadStager: BackupPayloadStager {
    private let fileManager: FileManager
    private let rootDirectory: URL?
    private let directoryName: String

    init(
        rootDirectory: URL? = nil,
        directoryName: String = "PrivateBackupPayloadStaging",
        fileManager: FileManager = .default
    ) {
        self.rootDirectory = rootDirectory
        self.directoryName = directoryName
        self.fileManager = fileManager
    }

    func stagePayload(
        _ data: Data,
        contentType: String,
        checksumSha256: String? = nil,
        compression: BackupPayloadCompression = .none
    ) throws -> StagedBackupPayloadMetadata {
        guard compression == .none else {
            throw FileBackedBackupPayloadStagerError.gzipCompressionUnsupported
        }

        let directoryURL = try prepareStagingDirectory()
        let fileURL = directoryURL
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("payload")

        try data.write(
            to: fileURL,
            options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        )
        try applyFileProtection(to: fileURL)
        try excludeFromDeviceBackup(fileURL)

        return StagedBackupPayloadMetadata(
            localFileURL: fileURL,
            contentType: contentType,
            contentLength: data.count,
            checksumSha256: checksumSha256,
            compression: compression
        )
    }

    func removeStagedPayload(at localFileURL: URL) throws {
        guard try isInsideStagingDirectory(localFileURL) else {
            throw FileBackedBackupPayloadStagerError.stagedFileOutsidePrivateDirectory
        }

        guard fileManager.fileExists(atPath: localFileURL.path) else {
            return
        }

        try fileManager.removeItem(at: localFileURL)
    }

    private func prepareStagingDirectory() throws -> URL {
        let directoryURL = try stagingDirectoryURL()

        if !fileManager.fileExists(atPath: directoryURL.path) {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        try applyFileProtection(to: directoryURL)
        try excludeFromDeviceBackup(directoryURL)

        return directoryURL
    }

    private func stagingDirectoryURL() throws -> URL {
        if let rootDirectory = rootDirectory {
            return rootDirectory.appendingPathComponent(directoryName, isDirectory: true)
        }

        let applicationSupportURL = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        return applicationSupportURL.appendingPathComponent(directoryName, isDirectory: true)
    }

    private func applyFileProtection(to url: URL) throws {
        try fileManager.setAttributes(
            [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
            ofItemAtPath: url.path
        )
    }

    private func excludeFromDeviceBackup(_ url: URL) throws {
        var mutableURL = url
        var resourceValues = URLResourceValues()
        resourceValues.isExcludedFromBackup = true
        try mutableURL.setResourceValues(resourceValues)
    }

    private func isInsideStagingDirectory(_ url: URL) throws -> Bool {
        let directoryPath = try stagingDirectoryURL()
            .standardizedFileURL
            .path
            .appending("/")
        let filePath = url.standardizedFileURL.path

        return filePath.hasPrefix(directoryPath)
    }
}
