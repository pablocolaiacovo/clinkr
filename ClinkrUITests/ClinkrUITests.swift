import XCTest

final class ClinkrUITests: XCTestCase {
    /// A cold simulator on CI can take more than 5 seconds to show the first screen.
    private let launchWait: TimeInterval = 15

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchesInSpanish() throws {
        XCTAssertTrue(
            launch(language: "es-AR", locale: "es_AR").navigationBars["Tus noches"].waitForExistence(
                timeout: launchWait))
    }

    @MainActor
    func testLaunchesInEnglish() throws {
        XCTAssertTrue(
            launch(language: "en", locale: "en_US").navigationBars["Your nights"].waitForExistence(timeout: launchWait))
    }

    /// The newest sample night starts 6 hours ago, so its month leads the list.
    @MainActor
    func testSampleNightsAreGroupedByMonthInSpanish() throws {
        let app = launch(language: "es-AR", locale: "es_AR", sampleNights: true)
        let newestMonth = Date.now.addingTimeInterval(-6 * 3600)
            .formatted(Date.FormatStyle(locale: Locale(identifier: "es_AR")).month(.wide))
        XCTAssertTrue(app.staticTexts[newestMonth.uppercased()].waitForExistence(timeout: launchWait))
        XCTAssertTrue(night(containing: "Noche del ", in: app).exists)
    }

    @MainActor
    func testSampleNightsAreGroupedByMonthInEnglish() throws {
        let app = launch(language: "en", locale: "en_US", sampleNights: true)
        let newestMonth = Date.now.addingTimeInterval(-6 * 3600)
            .formatted(Date.FormatStyle(locale: Locale(identifier: "en_US")).month(.wide))
        XCTAssertTrue(app.staticTexts[newestMonth.uppercased()].waitForExistence(timeout: launchWait))
        XCTAssertTrue(night(containing: " night, ", in: app).exists)
    }

    @MainActor
    func testSwipingANightDeletesIt() throws {
        let app = launch(language: "en", locale: "en_US", sampleNights: true)
        let first = night(containing: " night, ", in: app)
        XCTAssertTrue(first.waitForExistence(timeout: launchWait))
        let label = first.label

        first.swipeLeft()
        app.buttons["Delete"].tap()

        XCTAssertTrue(app.staticTexts[label].waitForNonExistence(timeout: 5))
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
