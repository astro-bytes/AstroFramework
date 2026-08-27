//
//  BundleExtensionTests.swift
//  UtilityFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import XCTest
@testable import UtilityFoundation

final class BundleExtensionTests: XCTestCase {

    /// The accessors used to force-cast the info dictionary lookup, so any bundle without the key
    /// trapped. A test bundle is exactly such a bundle, which makes reading one here the whole
    /// assertion — this crashed the runner before rather than failing.
    func testVersionsOfABundleWithoutVersionKeysAreNilRatherThanATrap() {
        let bundle = Bundle(for: type(of: self))

        XCTAssertNil(bundle.appVersion)
        XCTAssertNil(bundle.buildVersion)
        XCTAssertNil(bundle.fullAppVersion)
    }

    func testVersionsAreReadFromTheInfoDictionary() throws {
        // The test runner is a real bundle that declares both keys.
        let bundle = Bundle.main
        let version = try XCTUnwrap(bundle.appVersion, "the host bundle declares no version")
        let build = try XCTUnwrap(bundle.buildVersion, "the host bundle declares no build")

        XCTAssertFalse(version.isEmpty)
        XCTAssertFalse(build.isEmpty)
        XCTAssertEqual(bundle.fullAppVersion, "\(version) (\(build))")
    }

    /// The composed string needs both halves, so a bundle carrying only one reports nothing rather
    /// than something like `"1.4.2 ()"`.
    func testFullVersionNeedsBothKeys() {
        let bundleWithNeither = Bundle(for: type(of: self))

        XCTAssertNil(bundleWithNeither.fullAppVersion)
    }
}
