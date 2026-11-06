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

    @MainActor
    private func launch(language: String, locale: String) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(\(language))", "-AppleLocale", locale]
        app.launch()
        return app
    }
}
