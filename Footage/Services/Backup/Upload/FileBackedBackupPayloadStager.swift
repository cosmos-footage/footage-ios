//
//  FileBackedBackupPayloadStager.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation
import Compression

enum FileBackedBackupPayloadStagerError: Error {
    case compressionFailed
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
        let payloadData: Data
        switch compression {
        case .none:
            payloadData = data
        case .gzip:
            payloadData = try GzipPayloadCompressor.compress(data)
        }

        let directoryURL = try prepareStagingDirectory()
        let fileURL = directoryURL
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("payload")

        try payloadData.write(
            to: fileURL,
            options: [.atomic, .completeFileProtectionUntilFirstUserAuthentication]
        )
        try applyFileProtection(to: fileURL)
        try excludeFromDeviceBackup(fileURL)

        return StagedBackupPayloadMetadata(
            localFileURL: fileURL,
            contentType: contentType,
            contentLength: payloadData.count,
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

private enum GzipPayloadCompressor {
    private static let gzipHeader = Data([0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff])
    private static let emptyZlibPayload = Data([0x78, 0x9c, 0x03, 0x00, 0x00, 0x00, 0x00, 0x01])

    static func compress(_ data: Data) throws -> Data {
        let zlibData = data.isEmpty ? emptyZlibPayload : try zlibCompress(data)
        guard zlibData.count >= 6 else {
            throw FileBackedBackupPayloadStagerError.compressionFailed
        }

        var gzipData = gzipHeader
        gzipData.append(zlibData.dropFirst(2).dropLast(4))
        appendLittleEndian(crc32(data), to: &gzipData)
        appendLittleEndian(UInt32(truncatingIfNeeded: data.count), to: &gzipData)
        return gzipData
    }

    private static func zlibCompress(_ data: Data) throws -> Data {
        let destinationCapacity = data.count + max(64, ((data.count / 16_384) + 1) * 5 + 64)
        var destination = [UInt8](repeating: 0, count: destinationCapacity)

        let encodedSize = data.withUnsafeBytes { sourceBuffer -> Int in
            guard let source = sourceBuffer.bindMemory(to: UInt8.self).baseAddress else {
                return 0
            }

            return destination.withUnsafeMutableBufferPointer { destinationBuffer -> Int in
                guard let destinationBase = destinationBuffer.baseAddress else {
                    return 0
                }

                return compression_encode_buffer(
                    destinationBase,
                    destinationBuffer.count,
                    source,
                    data.count,
                    nil,
                    COMPRESSION_ZLIB
                )
            }
        }

        guard encodedSize > 0 else {
            throw FileBackedBackupPayloadStagerError.compressionFailed
        }

        return Data(destination.prefix(encodedSize))
    }

    private static func crc32(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff
        data.withUnsafeBytes { buffer in
            for byte in buffer.bindMemory(to: UInt8.self) {
                let index = Int((crc ^ UInt32(byte)) & 0xff)
                crc = (crc >> 8) ^ crc32Table[index]
            }
        }
        return crc ^ 0xffffffff
    }

    private static let crc32Table: [UInt32] = (0..<256).map { value in
        var crc = UInt32(value)
        for _ in 0..<8 {
            if crc & 1 == 1 {
                crc = (crc >> 1) ^ 0xedb88320
            } else {
                crc >>= 1
            }
        }
        return crc
    }

    private static func appendLittleEndian(_ value: UInt32, to data: inout Data) {
        var littleEndianValue = value.littleEndian
        withUnsafeBytes(of: &littleEndianValue) { bytes in
            data.append(contentsOf: bytes)
        }
    }
}
