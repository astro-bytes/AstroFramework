//
//  ErrorAlertViewModifierTests.swift
//  UIFoundationTests
//
//  Created by Porter McGary on 1/19/24.
//

import XCTest
import SwiftUI
@testable import UIFoundation

/// `ViewModifier` is main-actor isolated, so building one is too.
@MainActor
final class ErrorAlertViewModifierTests: XCTestCase {

    // MARK: Presentation binding

    func testIsPresentedFollowsWhetherThereIsAnError() {
        XCTAssertFalse(modifier(for: nil).isPresented.wrappedValue)
        XCTAssertTrue(modifier(for: CoreFailure()).isPresented.wrappedValue)
    }

    func testDismissingClearsTheError() {
        var error: (any Error)? = CoreFailure()
        let binding = Binding<(any Error)?> { error } set: { error = $0 }
        let modifier = ErrorAlertViewModifier(error: binding)

        modifier.isPresented.wrappedValue = false

        XCTAssertNil(error)
    }

    /// Setting `isPresented` to `true` is the alert reporting what it already did; it must not
    /// invent an error to match.
    func testSettingIsPresentedTrueDoesNotFabricateAnError() {
        var error: (any Error)?
        let binding = Binding<(any Error)?> { error } set: { error = $0 }
        let modifier = ErrorAlertViewModifier(error: binding)

        modifier.isPresented.wrappedValue = true

        XCTAssertNil(error)
    }

    // MARK: Title

    func testTitleComesFromADisplayableError() {
        XCTAssertEqual(modifier(for: DisplayFailure(title: "Cannot Save")).title, "Cannot Save")
    }

    func testAPlainErrorGetsAGenericTitle() {
        XCTAssertEqual(modifier(for: CoreFailure()).title, "Error")
    }

    // MARK: Message

    func testMessageComesFromADisplayableError() {
        let error = DisplayFailure(title: "Cannot Save", message: "The draft is still open elsewhere.")

        XCTAssertEqual(modifier(for: error).body, "The draft is still open elsewhere.")
    }

    func testADisplayableErrorMayHaveNoMessage() {
        XCTAssertNil(modifier(for: DisplayFailure(title: "Cannot Save", message: nil)).body)
    }

    func testALocalizedErrorFallsBackToItsRecoverySuggestion() {
        XCTAssertEqual(modifier(for: LocalizedFailure()).body, "Try again in a moment.")
    }

    func testAPlainErrorGetsAGenericMessage() {
        XCTAssertEqual(modifier(for: CoreFailure()).body, "Sorry, something went wrong. Please try again later.")
    }

    // MARK: Dismissible and reportable

    func testAPlainErrorIsDismissible() {
        XCTAssertTrue(modifier(for: CoreFailure()).dismissible)
    }

    func testADisplayableErrorChoosesWhetherItIsDismissible() {
        XCTAssertFalse(modifier(for: DisplayFailure(title: "Stuck", dismissible: false)).dismissible)
    }

    /// `DisplayableError` defaults: dismissible, not reportable.
    func testDisplayableErrorDefaults() {
        let error = DefaultedFailure()

        XCTAssertTrue(error.dismissible)
        XCTAssertFalse(error.reportable)
    }

    /// Without a handler in the environment there is nothing a Report button could do, so a plain
    /// error is not reportable.
    func testAPlainErrorIsNotReportableWithoutAHandler() {
        XCTAssertFalse(modifier(for: CoreFailure()).reportable)
    }

    func testADisplayableErrorChoosesWhetherItIsReportable() {
        XCTAssertTrue(modifier(for: DisplayFailure(title: "Stuck", reportable: true)).reportable)
    }

    // MARK: Building the view

    /// The modifier applies its alert unconditionally now. Branching the body on `if let error`
    /// gave the two states structurally different views, which changed the view's identity on
    /// every present and dismiss.
    func testTheModifierBuildsAViewInBothStates() {
        XCTAssertNoThrow(_ = Text("body").errorAlert(error: .constant(nil)))
        XCTAssertNoThrow(_ = Text("body").errorAlert(error: .constant(CoreFailure())))
    }

    // MARK: Helpers

    private func modifier(for error: (any Error)?) -> ErrorAlertViewModifier {
        ErrorAlertViewModifier(error: .constant(error))
    }
}

// MARK: - Test errors

private struct CoreFailure: Error {}

private struct LocalizedFailure: LocalizedError {
    var recoverySuggestion: String? { "Try again in a moment." }
}

private struct DisplayFailure: DisplayableError {
    var title: String
    var message: String? = nil
    var dismissible: Bool = true
    var reportable: Bool = false
}

/// Conforms to nothing beyond the requirements, to pin the protocol's own defaults.
private struct DefaultedFailure: DisplayableError {
    var title: String { "Defaulted" }
    var message: String? { nil }
}
