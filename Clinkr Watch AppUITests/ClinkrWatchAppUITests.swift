import XCTest

/// The main flows on the real screens, covering the timing that lives in `ContentView`, which unit tests can't reach.
@MainActor
final class ClinkrWatchAppUITests: XCTestCase {
    private let app = XCUIApplication()
    /// It's also the button that closes the message, so it isn't found as plain text.
    private var nightSaved: XCUIElement { app.buttons["Night saved. Get home safe."] }
    private var waterBreak: XCUIElement { app.staticTexts["Water break?"] }

    func testAddUndoNudgeAndEndNight() throws {
        launch()
        endAnyNightLeftOver()

        swipeUp(to: app.buttons["Beer"])
        tapUntilToastShows(app.buttons["Beer"])
        tapOnceStill(app.buttons["Undo"])
        XCTAssertTrue(waitToDisappear(app.buttons["Undo"]), "Undo closes the toast")

        for _ in 1...4 {
            app.buttons["Beer"].tap()
        }
        XCTAssertFalse(waterBreak.exists, "The nudge waits for the toast")
        XCTAssertTrue(waterBreak.waitForExistence(timeout: toastWait))
        tapOnceStill(app.buttons["Had one"])
        XCTAssertTrue(waitToDisappear(waterBreak))

        swipeUp(to: app.buttons["End night"])
        tapOnceStill(app.buttons["End night"])
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        tapOnceStill(app.buttons["Undo"])
        XCTAssertTrue(waitToDisappear(nightSaved), "Undo closes the message")

        tapOnceStill(app.buttons["End night"])
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        XCTAssertTrue(waitToDisappear(nightSaved), "The message closes by itself")
    }

    /// Double tap can't be performed in the simulator, but it presses this same button.
    func testTappingTheRingAddsTheLastDrinkAgain() throws {
        launch()
        endAnyNightLeftOver()

        swipeUp(to: app.buttons["Beer"])
        tapUntilToastShows(app.buttons["Beer"])
        app.swipeDown()
        let ring = app.buttons.matching(NSPredicate(format: "label CONTAINS '1 drink'")).firstMatch
        tapOnceStill(ring)

        let twoDrinks = app.buttons.matching(NSPredicate(format: "label CONTAINS '2 drinks'")).firstMatch
        XCTAssertTrue(twoDrinks.waitForExistence(timeout: 5), "The ring counts the drink again")
        let toast = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS \"That's 2.\""))
        XCTAssertTrue(toast.firstMatch.waitForExistence(timeout: 5), "The toast offers to undo it")
    }

    func testRemovingADrinkCallsOffTheWaitingNudge() throws {
        launch()
        endAnyNightLeftOver()

        swipeUp(to: app.buttons["Beer"])
        tapUntilToastShows(app.buttons["Beer"])
        for _ in 1...3 {
            app.buttons["Beer"].tap()
        }
        swipeUp(to: app.buttons["End night"])
        // The second row, so the newest stays the one Undo would take back.
        let rows = app.descendants(matching: .any).matching(NSPredicate(format: "label BEGINSWITH 'Beer,'"))
        rows.element(boundBy: 1).swipeLeft()
        tapOnceStill(app.buttons["Remove"])

        XCTAssertFalse(waterBreak.waitForExistence(timeout: toastWait), "Three drinks no longer call for water")
    }

    func testAFailedSaveShowsOnScreen() throws {
        // Nothing can be written under /dev/null, so every save fails.
        launch(nightsFile: "/dev/null/nights.json")
        let notSaved = app.descendants(matching: .any).matching(NSPredicate(format: "label CONTAINS 'Not saved'"))

        swipeUp(to: app.buttons["Beer"])
        tapUntilToastShows(app.buttons["Beer"])
        app.swipeDown()
        XCTAssertTrue(notSaved.firstMatch.waitForExistence(timeout: 5), "Tonight's caption says so")

        swipeUp(to: app.buttons["End night"])
        tapOnceStill(app.buttons["End night"])
        let failedMessage = app.buttons["Not saved. Get home safe."]
        XCTAssertTrue(failedMessage.waitForExistence(timeout: 5))
        XCTAssertFalse(nightSaved.exists)
        tapOnceStill(failedMessage)
        XCTAssertTrue(waitToDisappear(failedMessage), "Tapping the message closes it")

        let emptyTonight = notSaved.matching(NSPredicate(format: "label CONTAINS 'Swipe up to start the night'"))
        XCTAssertTrue(emptyTonight.firstMatch.waitForExistence(timeout: 5), "The empty Tonight keeps its hint")
    }

    /// The other tests run in English, so this one checks the Spanish the app is written in.
    func testLaunchesInSpanish() throws {
        continueAfterFailure = false
        app.launchArguments = ["-AppleLanguages", "(es-AR)", "-AppleLocale", "es_AR"]
        app.launch()

        swipeUp(to: app.buttons["Birra"])
        XCTAssertTrue(app.buttons["Trago"].exists)
    }

    /// Long enough for any wait on the toast to end, even on a slow test machine.
    private let toastWait: TimeInterval = 30

    private func launch(nightsFile: String? = nil) {
        continueAfterFailure = false
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchEnvironment["UNDO_SECONDS"] = "15"
        app.launchEnvironment["NIGHTS_FILE"] = nightsFile
        app.launch()
    }

    /// The simulator keeps saved nights between runs, so each run starts from an empty Tonight.
    private func endAnyNightLeftOver() {
        let emptyTonight = app.descendants(matching: .any)["Swipe up to start the night"]
        guard !emptyTonight.waitForExistence(timeout: 10) else { return }
        swipeUp(to: app.buttons["End night"])
        tapOnceStill(app.buttons["End night"])
        XCTAssertTrue(nightSaved.waitForExistence(timeout: 5))
        // Swiping here scrolled Add's list, leaving Beer under the clock, so start again from the top.
        app.terminate()
        app.launch()
    }

    /// The pages run Tonight, Add, Night, so going forward is always up.
    private func swipeUp(to element: XCUIElement) {
        for _ in 0..<4 where !element.isHittable {
            app.swipeUp()
            _ = element.waitForExistence(timeout: 1)
        }
        XCTAssertTrue(element.isHittable)
    }

    /// On a simulator that just started, the first tap after launch can get lost.
    private func tapUntilToastShows(_ button: XCUIElement) {
        for _ in 1...3 {
            tapOnceStill(button)
            if app.buttons["Undo"].waitForExistence(timeout: 8) { return }
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
        return XCTWaiter.wait(for: [gone], timeout: toastWait) == .completed
    }
}
