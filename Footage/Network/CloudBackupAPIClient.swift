//
//  CloudBackupAPIClient.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation

enum CloudBackupAPIError: Error {
    case invalidResponse
    case httpStatus(Int)
    case missingData
    case decodingFailed(Error)
    case uploadMethodUnsupported(String)
}

protocol CloudBackupAPIClientProtocol {
    func bootstrapInstallation(
        _ request: BootstrapRequest,
        completion: @escaping (Result<BootstrapResponse, Error>) -> Void
    )
    func requestPresignedUpload(
        _ request: PresignUploadRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<PresignUploadResponse, Error>) -> Void
    )
    func uploadDataToPresignedURL(
        data: Data,
        response: PresignUploadResponse,
        contentType: String,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    func completeUpload(
        _ request: UploadCompleteRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<UploadCompleteResponse, Error>) -> Void
    )
    func registerSyncBatch(
        _ request: SyncBatchRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<SyncBatchResponse, Error>) -> Void
    )
}

final class CloudBackupAPIClient: CloudBackupAPIClientProtocol {
    private let configuration: CloudBackupConfiguration
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(configuration: CloudBackupConfiguration, session: URLSession = .shared) {
        self.configuration = configuration
        self.session = session

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func bootstrapInstallation(
        _ request: BootstrapRequest,
        completion: @escaping (Result<BootstrapResponse, Error>) -> Void
    ) {
        send(path: "/v1/bootstrap", method: "POST", body: request, completion: completion)
    }

    func requestPresignedUpload(
        _ request: PresignUploadRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<PresignUploadResponse, Error>) -> Void
    ) {
        send(
            path: "/v1/uploads/presign",
            method: "POST",
            body: request,
            bearerToken: bearerToken,
            idempotencyKey: idempotencyKey,
            completion: completion
        )
    }

    func uploadDataToPresignedURL(
        data: Data,
        response: PresignUploadResponse,
        contentType: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard response.method.uppercased() == "PUT" else {
            completion(.failure(CloudBackupAPIError.uploadMethodUnsupported(response.method)))
            return
        }

        var request = URLRequest(url: response.url, timeoutInterval: configuration.requestTimeout)
        request.httpMethod = response.method
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")

        for (header, value) in response.requiredHeaders {
            request.setValue(value, forHTTPHeaderField: header)
        }

        session.uploadTask(with: request, from: data) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(CloudBackupAPIError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(CloudBackupAPIError.httpStatus(httpResponse.statusCode)))
                return
            }

            completion(.success(()))
        }.resume()
    }

    func completeUpload(
        _ request: UploadCompleteRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<UploadCompleteResponse, Error>) -> Void
    ) {
        send(
            path: "/v1/uploads/complete",
            method: "POST",
            body: request,
            bearerToken: bearerToken,
            idempotencyKey: idempotencyKey,
            completion: completion
        )
    }

    func registerSyncBatch(
        _ request: SyncBatchRequest,
        bearerToken: String,
        idempotencyKey: IdempotencyKey,
        completion: @escaping (Result<SyncBatchResponse, Error>) -> Void
    ) {
        send(
            path: "/v1/sync/batches",
            method: "POST",
            body: request,
            bearerToken: bearerToken,
            idempotencyKey: idempotencyKey,
            completion: completion
        )
    }

    private func send<RequestBody: Encodable, ResponseBody: Decodable>(
        path: String,
        method: String,
        body: RequestBody,
        bearerToken: String? = nil,
        idempotencyKey: IdempotencyKey? = nil,
        completion: @escaping (Result<ResponseBody, Error>) -> Void
    ) {
        var request = URLRequest(url: configuration.baseURL.appendingPathComponent(path), timeoutInterval: configuration.requestTimeout)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let bearerToken = bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        if let idempotencyKey = idempotencyKey {
            request.setValue(idempotencyKey.rawValue, forHTTPHeaderField: "Idempotency-Key")
        }

        do {
            request.httpBody = try encoder.encode(body)
        } catch {
            completion(.failure(error))
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(CloudBackupAPIError.invalidResponse))
                return
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(CloudBackupAPIError.httpStatus(httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(CloudBackupAPIError.missingData))
                return
            }

            do {
                completion(.success(try self.decoder.decode(ResponseBody.self, from: data)))
            } catch {
                completion(.failure(CloudBackupAPIError.decodingFailed(error)))
            }
        }.resume()
    }
}
