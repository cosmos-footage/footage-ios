//
//  CloudBackupAPIClientTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/04.
//

import XCTest
@testable import footage

final class CloudBackupAPIClientTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testPresignUploadBuildsAuthenticatedIdempotentJSONRequest() {
        let client = makeClient()
        let expectation = expectation(description: "presign completion")

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url?.path, "/v1/uploads/presign")
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer bearer_token")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Idempotency-Key"), "idem_1")

            let body = try XCTUnwrap(request.bodyData())
            let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(json["ownerId"] as? String, "own_1")
            XCTAssertEqual(json["deviceId"] as? String, "dev_1")
            XCTAssertEqual(json["contentLength"] as? Int, 123)

            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = """
            {
              "uploadId": "upload_1",
              "method": "PUT",
              "url": "https://s3.example.test/object",
              "expiresAt": "2026-07-04T15:00:00Z",
              "requiredHeaders": {
                "x-amz-server-side-encryption": "AES256"
              },
              "objectKey": "owners/own_1/devices/dev_1/recordings/rec_1/points.ndjson.gz"
            }
            """.data(using: .utf8)!
            return (response, data)
        }

        client.requestPresignedUpload(
            PresignUploadRequest(
                ownerId: "own_1",
                deviceId: "dev_1",
                recordingId: "rec_1",
                syncBatchId: "batch_1",
                objectType: "routePoints",
                contentType: "application/x-ndjson",
                contentLength: 123,
                checksumSha256: "checksum"
            ),
            bearerToken: "bearer_token",
            idempotencyKey: IdempotencyKey(rawValue: "idem_1")
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.uploadId, "upload_1")
                XCTAssertEqual(response.method, "PUT")
                XCTAssertEqual(response.requiredHeaders["x-amz-server-side-encryption"], "AES256")
            case .failure(let error):
                XCTFail("Expected success, got \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testRestoreManifestBuildsQueryAndBearerHeader() {
        let client = makeClient()
        let expectation = expectation(description: "manifest completion")

        MockURLProtocol.requestHandler = { request in
            let components = try XCTUnwrap(URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false))
            let query = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value) })
            XCTAssertEqual(components.path, "/v1/restore/manifest")
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Accept"), "application/json")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer bearer_token")
            XCTAssertEqual(query["ownerId"] ?? nil, "own_1")
            XCTAssertEqual(query["deviceId"] ?? nil, "dev_1")
            XCTAssertEqual(query["since"] ?? nil, "2026-07-04T15:00:00Z")

            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            let data = """
            {
              "ownerId": "own_1",
              "generatedAt": "2026-07-04T15:00:00Z",
              "schemaVersion": 1,
              "recordings": []
            }
            """.data(using: .utf8)!
            return (response, data)
        }

        client.requestRestoreManifest(
            ownerId: OwnerID(rawValue: "own_1"),
            deviceId: DeviceID(rawValue: "dev_1"),
            since: Date(timeIntervalSince1970: 1_783_177_200),
            bearerToken: "bearer_token"
        ) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.ownerId, "own_1")
                XCTAssertEqual(response.recordings.count, 0)
            case .failure(let error):
                XCTFail("Expected success, got \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    private func makeClient() -> CloudBackupAPIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        return CloudBackupAPIClient(
            configuration: CloudBackupConfiguration(
                baseURL: URL(string: "https://api.example.test")!,
                requestTimeout: 1
            ),
            session: session
        )
    }
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: CloudBackupAPIError.missingData)
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private extension URLRequest {
    func bodyData() -> Data? {
        if let httpBody = httpBody {
            return httpBody
        }

        guard let stream = httpBodyStream else {
            return nil
        }

        stream.open()
        defer { stream.close() }

        var data = Data()
        let bufferSize = 1_024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while stream.hasBytesAvailable {
            let readCount = stream.read(buffer, maxLength: bufferSize)
            if readCount > 0 {
                data.append(buffer, count: readCount)
            } else {
                break
            }
        }

        return data
    }
}
