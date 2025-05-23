//
//  HomeMapViewUITests.swift
//  iosAppUITests
//
//  Created by Simon, Emma on 3/13/24.
//  Copyright © 2024 MBTA. All rights reserved.
//

import CoreLocation
import XCTest

final class HomeMapViewUITests: XCTestCase {
    let app = XCUIApplication()

    override func setUp() {
        executionTimeAllowance = 180
    }

    override func setUpWithError() throws {
        app.resetAuthorizationStatus(for: .location)
        app.launchArguments = ["--default-mocks"]
        XCUIDevice.shared.location = XCUILocation(location: .init(latitude: 42.356395, longitude: -71.062424))
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    // Test is skipped for now due to issues running in XCode Cloud
    func testRecentersToUserLocation() throws {
        app.activate()
        app.launch()

        acceptLocationPermissionAlert(timeout: 10)

        let map = app.otherElements.matching(identifier: "transitMap").element
        XCTAssert(map.waitForExistence(timeout: 30))

        let recenterButton = app.images.matching(identifier: "mapRecenterButton").element
        XCTAssertFalse(recenterButton.exists)

        map.swipeDown()
        XCTAssert(recenterButton.waitForExistence(timeout: 3))

        recenterButton.tap()
        XCTAssertFalse(recenterButton.exists)
    }

    func testNoRecenterWithNoLocation() throws {
        app.activate()
        app.launch()

        denyLocationPermissionAlert(timeout: 10)

        let map = app.otherElements.matching(identifier: "transitMap").element
        XCTAssert(map.waitForExistence(timeout: 30))

        let recenterButton = app.images.matching(identifier: "mapRecenterButton").element
        XCTAssertFalse(recenterButton.exists)

        map.swipeDown()
        XCTAssertFalse(recenterButton.exists)
    }

    func testLocationServicesButtonWithNoLocation() throws {
        app.activate()
        app.launch()

        denyLocationPermissionAlert(timeout: 10)
        let map = app.otherElements.matching(identifier: "transitMap").element
        XCTAssert(map.waitForExistence(timeout: 30))

        let locationServicesButton = app.buttons.matching(identifier: "locationServicesButton").element
        XCTAssert(locationServicesButton.exists)

        locationServicesButton.tap()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let alert = app.alerts.firstMatch
        XCTAssert(alert.waitForExistence(timeout: 10))
        XCTAssert(alert.labelContains(text: "turned on"))
    }
}

extension XCUIElement {
    func labelContains(text: String) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        return staticTexts.matching(predicate).firstMatch.exists
    }
}

extension XCTestCase {
    private func tapLocationAlertButton(label: String, timeout: TimeInterval) {
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")

        let alert = springboard.alerts.firstMatch
        XCTAssert(alert.waitForExistence(timeout: timeout))
        XCTAssert(alert.labelContains(text: "use your location?"))

        let button = alert.buttons[label]
        XCTAssert(button.waitForExistence(timeout: timeout))
        button.tap()
    }

    func acceptLocationPermissionAlert(timeout: TimeInterval) {
        tapLocationAlertButton(label: "Allow Once", timeout: timeout)
    }

    func denyLocationPermissionAlert(timeout: TimeInterval) {
        // Note that this uses a fancy ’ (U+2019) apostrophe rather than a ' (U+0027)
        tapLocationAlertButton(label: "Don’t Allow", timeout: timeout)
    }
}
