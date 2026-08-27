//
//  ColorExtensionTests.swift
//  UIFoundationTests
//
//  Created by Porter McGary on 8/27/26.
//

import XCTest
import SwiftUI
@testable import UIFoundation

final class ColorExtensionTests: XCTestCase {

    // MARK: Parsing

    func testHex_ParsesSixDigits() throws {
        let color = try XCTUnwrap(Color(hex: "FF8000"))

        let components = try XCTUnwrap(NativeColor(color).rgbaComponents)
        XCTAssertEqual(components.red, 1, accuracy: 0.005)
        XCTAssertEqual(components.green, 0.5019, accuracy: 0.005)
        XCTAssertEqual(components.blue, 0, accuracy: 0.005)
        XCTAssertEqual(components.alpha, 1, accuracy: 0.005)
    }

    func testHex_ParsesEightDigitsWithAlpha() throws {
        let color = try XCTUnwrap(Color(hex: "FF000080"))

        let components = try XCTUnwrap(NativeColor(color).rgbaComponents)
        XCTAssertEqual(components.red, 1, accuracy: 0.005)
        XCTAssertEqual(components.alpha, 0.5019, accuracy: 0.005)
    }

    /// Three-digit shorthand is the most common form in a design handoff, and used to be the
    /// failure case — the invalid-length branch was missing a `return`, so it fell through and
    /// initialized a second time from components still at zero, producing black.
    func testHex_ParsesThreeDigitShorthandAsDoubledNibbles() throws {
        let shorthand = try XCTUnwrap(Color(hex: "#F90"))
        let longhand = try XCTUnwrap(Color(hex: "#FF9900"))

        XCTAssertEqual(NativeColor(shorthand), NativeColor(longhand))
    }

    func testHex_ParsesFourDigitShorthandWithAlpha() throws {
        let shorthand = try XCTUnwrap(Color(hex: "#F908"))
        let longhand = try XCTUnwrap(Color(hex: "#FF990088"))

        XCTAssertEqual(NativeColor(shorthand), NativeColor(longhand))
    }

    func testHex_AcceptsALeadingHashAndSurroundingWhitespace() throws {
        let bare = try XCTUnwrap(Color(hex: "00FF00"))
        let decorated = try XCTUnwrap(Color(hex: "  #00FF00\n"))

        XCTAssertEqual(NativeColor(bare), NativeColor(decorated))
    }

    func testHex_IsCaseInsensitive() throws {
        let upper = try XCTUnwrap(Color(hex: "AABBCC"))
        let lower = try XCTUnwrap(Color(hex: "aabbcc"))

        XCTAssertEqual(NativeColor(upper), NativeColor(lower))
    }

    // MARK: Rejecting

    /// `Scanner.scanHexInt64` stops at the first non-hex character and still reports success, so
    /// `"FFZZZZ"` parsed as `0xFF` and was laid out as six digits — a silently wrong colour.
    func testHex_RejectsAStringThatIsOnlyPartlyHex() {
        XCTAssertNil(Color(hex: "FFZZZZ"))
        XCTAssertNil(Color(hex: "12345G"))
    }

    func testHex_RejectsUnsupportedLengths() {
        XCTAssertNil(Color(hex: ""))
        XCTAssertNil(Color(hex: "FF"))
        XCTAssertNil(Color(hex: "FFFFF"))
        XCTAssertNil(Color(hex: "FFFFFFFFF"))
    }

    // MARK: Round trip

    func testHexValue_RoundTripsAnOpaqueColour() throws {
        let color = try XCTUnwrap(Color(hex: "1D5C6E"))

        XCTAssertEqual(color.hexValue, "1D5C6E")
    }

    func testHexValue_RoundTripsAColourWithAlpha() throws {
        let color = try XCTUnwrap(Color(hex: "1D5C6E80"))

        XCTAssertEqual(color.hexValue, "1D5C6E80")
    }

    /// The property used to be `fatalError` on every platform but iOS, while the package declares
    /// six. This test running at all on macOS is the assertion.
    func testHexValue_IsAvailableOnEveryPlatform() throws {
        XCTAssertEqual(Color(red: 1, green: 1, blue: 1).hexValue, "FFFFFF")
    }

    func testHexValue_HandlesAGreyscaleColour() {
        XCTAssertNotNil(Color(white: 0.5).hexValue, "greyscale has fewer components than RGB")
    }

    // MARK: Mixing

    func testMix_HalfwayBetweenBlackAndWhiteIsGrey() throws {
        let mixed = NativeColor.black.mix(with: .white, amount: 0.5)

        let components = try XCTUnwrap(mixed.rgbaComponents)
        XCTAssertEqual(components.red, 0.5, accuracy: 0.01)
        XCTAssertEqual(components.green, 0.5, accuracy: 0.01)
        XCTAssertEqual(components.blue, 0.5, accuracy: 0.01)
    }

    func testMix_KeepsTheReceiversAlpha() throws {
        let translucent = NativeColor(red: 0, green: 0, blue: 0, alpha: 0.25)

        let components = try XCTUnwrap(translucent.mix(with: .white, amount: 1).rgbaComponents)
        XCTAssertEqual(components.alpha, 0.25, accuracy: 0.01)
    }

    func testMix_ClampsAmountOutsideZeroToOne() throws {
        let over = try XCTUnwrap(NativeColor.black.mix(with: .white, amount: 5).rgbaComponents)
        let under = try XCTUnwrap(NativeColor.black.mix(with: .white, amount: -5).rgbaComponents)

        XCTAssertEqual(over.red, 1, accuracy: 0.01)
        XCTAssertEqual(under.red, 0, accuracy: 0.01)
    }

    func testLighterAndDarker_MoveInOppositeDirections() throws {
        let base = NativeColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)

        let lighter = try XCTUnwrap(base.lighter().rgbaComponents)
        let darker = try XCTUnwrap(base.darker().rgbaComponents)

        XCTAssertGreaterThan(lighter.red, 0.5)
        XCTAssertLessThan(darker.red, 0.5)
    }
}
