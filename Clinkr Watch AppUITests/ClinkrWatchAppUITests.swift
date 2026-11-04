import XCTest

/// The main flow on the real screens, covering the timing that lives in `ContentView`, which unit tests can't reach.
@MainActor
final class ClinkrWatchAppUITests: XCTestCase {
    private let app = XCUIApplication()
    /// It's also the button that closes the message, so it isn't found as plain text.
    private var nightSaved: XCUIElement { app.buttons["Night saved. Get home safe."] }

    func testAddUndoNudgeAndEndNight() throws {
        continueAfterFailure = false
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        endAnyNightLeftOver()

        swipeUp(to: app.buttons["Beer"])
        tapUntilToastShows(app.buttons["Beer"])
        tapOnceStill(app.buttons["Undo"])
        XCTAssertTrue(waitToDisappear(app.buttons["Undo"]), "Undo closes the toast")

        for _ in 1...4 {
            app.buttons["Beer"].tap()
        }
        XCTAssertFalse(app.staticTexts["Water break?"].exists, "The nudge waits for the toast's 5 seconds")
        XCTAssertTrue(app.staticTexts["Water break?"].waitForExistence(timeout: 10))
        tapOnceStill(app.buttons["Had one"])
        XCTAssertTrue(waitToDisappear(app.staticTexts["Water break?"]))

        swipeUp(to: app.buttons["End night"])
        tapOnceStill(app.buttons["End night"])
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        tapOnceStill(app.buttons["Undo"])
        XCTAssertTrue(waitToDisappear(nightSaved), "Undo closes the message")

        tapOnceStill(app.buttons["End night"])
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        XCTAssertTrue(waitToDisappear(nightSaved), "The message closes by itself")
    }

    /// The simulator keeps saved nights between runs, so each run starts from an empty Tonight.
    private func endAnyNightLeftOver() {
        let emptyTonight = app.descendants(matching: .any)["Swipe up to start the night"]
        guard !emptyTonight.waitForExistence(timeout: 3) else { return }
        swipeUp(to: app.buttons["End night"])
        tapOnceStill(app.buttons["End night"])
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        XCTAssertTrue(waitToDisappear(nightSaved))
        // Swiping here scrolled Add's list, leaving Beer under the clock, so start again from the top.
        app.terminate()
        app.launch()
    }

    /// The pages run Tonight, Add, Night, so going forward is always up.
    private func swipeUp(to element: XCUIElement) {
        for _ in 0..<3 where !element.isHittable {
            app.swipeUp()
            _ = element.waitForExistence(timeout: 1)
        }
        XCTAssertTrue(element.isHittable)
    }

    /// On a simulator that just started, the first tap after launch can get lost.
    private func tapUntilToastShows(_ button: XCUIElement) {
        for _ in 1...3 {
            tapOnceStill(button)
            if app.buttons["Undo"].waitForExistence(timeout: 3) { return }
        }
        XCTFail("The toast never showed after tapping \(button)")
    }

    /// A tap while a screen is still sliding in lands where the button was.
    private func tapOnceStill(_ element: XCUIElement) {
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        var lastFrame = element.frame
        for _ in 0..<6 {
            Thread.sleep(forTimeInterval: 0.25)
            let frame = element.frame
            if frame == lastFrame { break }
            lastFrame = frame
        }
        element.tap()
    }

    private func waitToDisappear(_ element: XCUIElement) -> Bool {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        return XCTWaiter.wait(for: [gone], timeout: 10) == .completed
    }
}
