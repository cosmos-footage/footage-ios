//
//  LocalPreferencesRepositoriesTests.swift
//  FootageTests
//
//  Created by Codex on 2026/07/05.
//

import XCTest
@testable import footage

final class LocalPreferencesRepositoriesTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUpWithError() throws {
        try super.setUpWithError()
        suiteName = "FootageTests.\(UUID().uuidString)"
        defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        try super.tearDownWithError()
    }

    func testUserProfileRepositoryPersistsDisplayNameAndImageData() {
        let repository = UserDefaultsUserProfileRepository(defaults: defaults)
        let imageData = Data([0x01, 0x02, 0x03])

        repository.saveDisplayName("Footage User")
        repository.saveProfileImageData(imageData)

        let snapshot = repository.loadProfile()
        XCTAssertEqual(snapshot.displayName, "Footage User")
        XCTAssertEqual(snapshot.profileImageData, imageData)
    }

    func testUserProfileRepositoryCanClearValues() {
        let repository = UserDefaultsUserProfileRepository(defaults: defaults)
        repository.saveDisplayName("Footage User")
        repository.saveProfileImageData(Data([0x01]))

        repository.saveDisplayName(nil)
        repository.saveProfileImageData(nil)

        let snapshot = repository.loadProfile()
        XCTAssertNil(snapshot.displayName)
        XCTAssertNil(snapshot.profileImageData)
    }
}
