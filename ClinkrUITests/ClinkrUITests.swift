import XCTest

final class ClinkrUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunchShowsTitle() throws {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)"]
        app.launch()

        XCTAssertTrue(app.navigationBars["Your nights"].waitForExistence(timeout: 5))
    }
}
