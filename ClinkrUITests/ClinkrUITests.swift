import XCTest

final class ClinkrUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchesInSpanish() throws {
        XCTAssertTrue(
            launch(language: "es-AR", locale: "es_AR").navigationBars["Tus noches"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testLaunchesInEnglish() throws {
        XCTAssertTrue(
            launch(language: "en", locale: "en_US").navigationBars["Your nights"].waitForExistence(timeout: 5))
    }

    /// The newest sample night starts 6 hours ago, so its month leads the list.
    @MainActor
    func testSampleNightsAreGroupedByMonthInSpanish() throws {
        let app = launch(language: "es-AR", locale: "es_AR", sampleNights: true)
        let newestMonth = Date.now.addingTimeInterval(-6 * 3600)
            .formatted(Date.FormatStyle(locale: Locale(identifier: "es_AR")).month(.wide))
        XCTAssertTrue(app.staticTexts[newestMonth.uppercased()].waitForExistence(timeout: 5))
        XCTAssertTrue(night(containing: "Noche del ", in: app).exists)
    }

    @MainActor
    func testSampleNightsAreGroupedByMonthInEnglish() throws {
        let app = launch(language: "en", locale: "en_US", sampleNights: true)
        let newestMonth = Date.now.addingTimeInterval(-6 * 3600)
            .formatted(Date.FormatStyle(locale: Locale(identifier: "en_US")).month(.wide))
        XCTAssertTrue(app.staticTexts[newestMonth.uppercased()].waitForExistence(timeout: 5))
        XCTAssertTrue(night(containing: " night, ", in: app).exists)
    }

    @MainActor
    func testSwipingANightDeletesIt() throws {
        let app = launch(language: "en", locale: "en_US", sampleNights: true)
        let first = night(containing: " night, ", in: app)
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        let label = first.label

        first.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts[label].waitForNonExistence(timeout: 5))
    }

    /// The newest sample night: beer, beer, water, cocktail, shot, shot, beer over 4 hours.
    @MainActor
    func testRecapShowsTheNightsNumbersToVoiceOver() throws {
        let app = launch(language: "en", locale: "en_US", sampleNights: true)
        night(containing: " night, ", in: app).tap()

        XCTAssertTrue(app.staticTexts["How the night went"].waitForExistence(timeout: 5))
        XCTAssertEqual(stat("Drinks", in: app).value as? String, "6")
        XCTAssertEqual(stat("Waters", in: app).value as? String, "1")
        XCTAssertEqual(stat("Out for", in: app).value as? String, "4 hours")
        XCTAssertEqual(stat("Pace", in: app).value as? String, "1.5 per hour")
        let timeline = app.descendants(matching: .any)["Timeline"]
        XCTAssertTrue((timeline.value as? String)?.hasPrefix("6 drinks, 1 water, ") == true)
    }

    @MainActor
    func testRecapShowsSpanishNumbers() throws {
        let app = launch(language: "es-AR", locale: "es_AR", sampleNights: true)
        night(containing: "Noche del ", in: app).tap()

        XCTAssertTrue(app.staticTexts["Cómo fue la noche"].waitForExistence(timeout: 5))
        XCTAssertEqual(stat("Ritmo", in: app).value as? String, "1,5 por hora")
    }

    @MainActor
    func testRenamingANightKeepsTheNewName() throws {
        let app = launch(language: "en", locale: "en_US", sampleNights: true)
        night(containing: " night, ", in: app).tap()

        let name = app.buttons.matching(NSPredicate(format: "label ENDSWITH %@", " night")).firstMatch
        XCTAssertTrue(name.waitForExistence(timeout: 5))
        name.tap()
        let field = app.alerts.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 30) + "Karaoke")
        app.alerts.buttons["Save"].tap()

        XCTAssertTrue(app.buttons["Karaoke"].waitForExistence(timeout: 5))
        app.buttons["BackButton"].tap()
        XCTAssertTrue(night(containing: "Karaoke", in: app).waitForExistence(timeout: 5))
    }

    @MainActor
    private func stat(_ label: String, in app: XCUIApplication) -> XCUIElement {
        app.otherElements[label]
    }

    /// The first night row. Each row reads as one element, like "7, Sat, Saturday night, 6 drinks".
    @MainActor
    private func night(containing text: String, in app: XCUIApplication) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    @MainActor
    private func launch(language: String, locale: String, sampleNights: Bool = false) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        if sampleNights {
            app.launchArguments.append("-SampleNights")
        }
        app.launch()
        return app
    }
}
