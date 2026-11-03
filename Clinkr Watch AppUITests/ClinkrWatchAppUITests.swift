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

        goToPage(with: app.buttons["Beer"])
        app.buttons["Beer"].tap()
        tapUndo()
        XCTAssertFalse(app.buttons["Undo"].exists, "Undo closes the toast")

        for _ in 1...4 {
            app.buttons["Beer"].tap()
        }
        XCTAssertFalse(app.staticTexts["Water break?"].exists, "The nudge waits for the toast's 5 seconds")
        XCTAssertTrue(app.staticTexts["Water break?"].waitForExistence(timeout: 10))
        // A tap while it's still sliding in lands where the button was.
        Thread.sleep(forTimeInterval: 1)
        app.buttons["Had one"].tap()
        XCTAssertTrue(waitToDisappear(app.staticTexts["Water break?"]))

        goToPage(with: app.buttons["End night"])
        app.buttons["End night"].tap()
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        tapUndo()
        XCTAssertTrue(app.buttons["End night"].waitForExistence(timeout: 5), "Undo brings the night back")

        app.buttons["End night"].tap()
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        XCTAssertTrue(waitToDisappear(nightSaved), "The message closes by itself")
    }

    /// The simulator keeps saved nights between runs, so each run starts from an empty Tonight.
    private func endAnyNightLeftOver() {
        guard goToPage(with: app.buttons["End night"], attempts: 2) else { return }
        app.buttons["End night"].tap()
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        XCTAssertTrue(waitToDisappear(nightSaved))
    }

    @discardableResult
    private func goToPage(with element: XCUIElement, attempts: Int = 3) -> Bool {
        for _ in 0..<attempts where !element.isHittable {
            app.swipeUp()
            _ = element.waitForExistence(timeout: 1)
        }
        if element.isHittable { return true }
        for _ in 0..<attempts where !element.isHittable {
            app.swipeDown()
            _ = element.waitForExistence(timeout: 1)
        }
        return element.isHittable
    }

    private func tapUndo() {
        XCTAssertTrue(app.buttons["Undo"].waitForExistence(timeout: 5))
        app.buttons["Undo"].tap()
    }

    private func waitToDisappear(_ element: XCUIElement) -> Bool {
        let gone = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)
        return XCTWaiter.wait(for: [gone], timeout: 10) == .completed
    }
}
