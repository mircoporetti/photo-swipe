import XCTest

final class PhotoSwipeUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testAppShowsAccessRequestOrPhotos() throws {
        let grantButton = app.buttons["grantAccessButton"]
        let keepButton = app.buttons["keepButton"]
        let allDone = app.staticTexts["allDoneText"]

        let hasGrant = grantButton.waitForExistence(timeout: 5)
        let hasKeep = keepButton.waitForExistence(timeout: 3)
        let hasDone = allDone.waitForExistence(timeout: 2)

        XCTAssertTrue(hasGrant || hasKeep || hasDone)
    }

    @MainActor
    func testKeepPhotoViaButton() throws {
        guard waitForPhotosToLoad() else {
            throw XCTSkip("Photo library not authorized or empty")
        }

        let keepButton = app.buttons["keepButton"]
        keepButton.tap()
        sleep(1)

        let trashCount = app.buttons["trashCountButton"]
        XCTAssertFalse(trashCount.exists, "Keeping a photo should not add to the delete queue")

        let allDone = app.staticTexts["allDoneText"]
        XCTAssertTrue(keepButton.exists || allDone.exists)
    }

    @MainActor
    func testDeletePhotoViaButton() throws {
        guard waitForPhotosToLoad() else {
            throw XCTSkip("Photo library not authorized or empty")
        }

        let deleteButton = app.buttons["deleteButton"]
        deleteButton.tap()
        sleep(1)

        let trashCount = app.buttons["trashCountButton"]
        XCTAssertTrue(trashCount.waitForExistence(timeout: 3))
    }

    @MainActor
    func testSwipeRightToKeepPhoto() throws {
        guard waitForPhotosToLoad() else {
            throw XCTSkip("Photo library not authorized or empty")
        }

        let firstImage = app.images.firstMatch
        XCTAssertTrue(firstImage.waitForExistence(timeout: 5))

        firstImage.swipeRight()
        sleep(1)

        let trashCount = app.buttons["trashCountButton"]
        XCTAssertFalse(trashCount.exists, "Keeping a photo should not add to the delete queue")

        let keepButton = app.buttons["keepButton"]
        let allDone = app.staticTexts["allDoneText"]
        XCTAssertTrue(keepButton.exists || allDone.exists)
    }

    @MainActor
    func testSwipeLeftToDeletePhoto() throws {
        guard waitForPhotosToLoad() else {
            throw XCTSkip("Photo library not authorized or empty")
        }

        let firstImage = app.images.firstMatch
        XCTAssertTrue(firstImage.waitForExistence(timeout: 5))

        firstImage.swipeLeft()
        sleep(1)

        let trashCount = app.buttons["trashCountButton"]
        XCTAssertTrue(trashCount.waitForExistence(timeout: 3))
    }

    @MainActor
    func testUndoAfterDelete() throws {
        guard waitForPhotosToLoad() else {
            throw XCTSkip("Photo library not authorized or empty")
        }

        app.buttons["deleteButton"].tap()
        sleep(1)

        let trashCount = app.buttons["trashCountButton"]
        XCTAssertTrue(trashCount.waitForExistence(timeout: 3))

        app.buttons["undoButton"].tap()
        sleep(1)

        XCTAssertFalse(trashCount.exists)
    }

    @MainActor
    func testDeleteReviewSheetOpens() throws {
        guard waitForPhotosToLoad() else {
            throw XCTSkip("Photo library not authorized or empty")
        }

        app.buttons["deleteButton"].tap()
        sleep(1)

        let trashCount = app.buttons["trashCountButton"]
        XCTAssertTrue(trashCount.waitForExistence(timeout: 3))
        trashCount.tap()

        let navTitle = app.navigationBars["Review Deletions"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3))

        app.buttons["reviewDoneButton"].tap()
        sleep(1)
        XCTAssertFalse(navTitle.exists)
    }

    @MainActor
    func testDeleteReviewSheetRestorePhoto() throws {
        guard waitForPhotosToLoad() else {
            throw XCTSkip("Photo library not authorized or empty")
        }

        app.buttons["deleteButton"].tap()
        sleep(1)

        let trashCount = app.buttons["trashCountButton"]
        XCTAssertTrue(trashCount.waitForExistence(timeout: 3))
        trashCount.tap()

        let navTitle = app.navigationBars["Review Deletions"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3))

        let restoreButton = app.buttons["restoreButton"].firstMatch
        XCTAssertTrue(restoreButton.waitForExistence(timeout: 5))
        restoreButton.tap()
        sleep(1)

        app.buttons["reviewDoneButton"].tap()
        sleep(1)
        XCTAssertFalse(trashCount.exists)
    }

    @MainActor
    func testDeleteReviewSheetConfirmDelete() throws {
        guard waitForPhotosToLoad() else {
            throw XCTSkip("Photo library not authorized or empty")
        }

        app.buttons["deleteButton"].tap()
        sleep(1)

        let trashCount = app.buttons["trashCountButton"]
        XCTAssertTrue(trashCount.waitForExistence(timeout: 3))
        trashCount.tap()

        let navTitle = app.navigationBars["Review Deletions"]
        XCTAssertTrue(navTitle.waitForExistence(timeout: 3))

        let confirmDelete = app.buttons["confirmDeleteButton"]
        XCTAssertTrue(confirmDelete.waitForExistence(timeout: 3))
        confirmDelete.tap()

        sleep(2)
    }

    private func waitForPhotosToLoad() -> Bool {
        return app.buttons["keepButton"].waitForExistence(timeout: 10)
    }
}
