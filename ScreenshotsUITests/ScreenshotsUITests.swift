//
//  ScreenshotsUITests.swift
//  ScreenshotsUITests
//
//  Created by Dmytro Vorobiov on 30/10/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import XCTest

private struct Constants {
    static let SnapshotConversation = "01_Conversation"
    static let SnapshotContactList = "02_ContactList"
    static let SnapshotPin = "03_Pin"
}

class ScreenshotsUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        app.launchArguments.append("FASTLANE_SNAPSHOT")
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        // I have no idea why it doesn't work without delay here.
        sleep(1)

        createAccount()

        switch InterfaceIdiom.current() {
            case .iPhone:
                iPhonePart()
            case .iPad:
                iPadPart()
        }
    }

    func createAccount() {
        let app = XCUIApplication()

        XCUIDevice.sharedDevice().orientation = .Portrait

        app.buttons[localizedString("create_account")].tap()

        app.textFields[localizedString("create_account_username_placeholder")].tap()
        app.textFields[localizedString("create_account_username_placeholder")].typeText("user")

        app.textFields[localizedString("create_account_profile_placeholder")].tap()
        app.textFields[localizedString("create_account_profile_placeholder")].typeText("iPhone")

        app.keyboards.buttons["Next"].tap()

        app.secureTextFields[localizedString("password")].tap()
        app.secureTextFields[localizedString("password")].typeText("w")

        app.secureTextFields[localizedString("repeat_password")].tap()
        app.secureTextFields[localizedString("repeat_password")].typeText("w")

        app.keyboards.buttons["Go"].tap()

        addUIInterruptionMonitorWithDescription("Notifications alert") { (alert) -> Bool in
            let button = alert.buttons["OK"]
            if button.exists {
                button.tap()
                return true
            }
            return false
        }

    }

    func iPhonePart() {
        let app = XCUIApplication()

        // need to interact with the app for the handler to fire
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Button).element.tap()
        
        snapshot(Constants.SnapshotConversation)

        XCUIApplication().tables.staticTexts[String(localized: "app_store_screenshot_conversation_7")].tap()
        
        snapshot(Constants.SnapshotContactList)
        
        app.navigationBars[localizedString("chats_title")].buttons[localizedString("chats_title")].tap()
        
        let element = XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1)
        element.childrenMatchingType(.Other).elementBoundByIndex(4).childrenMatchingType(.Button).element.tap()
        
        pinPart()
    }

    func iPadPart() {
        let app = XCUIApplication()

        app.tables.staticTexts[String(localized: "app_store_screenshot_conversation_7")].tap()

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.TextView).element.tap()
        
        XCUIDevice.sharedDevice().orientation = .LandscapeRight

        snapshot(Constants.SnapshotConversation)

        app.navigationBars["Antidote.PrimaryIpad"].childrenMatchingType(.Other).element.childrenMatchingType(.Button).element.tap()
        
        pinPart()
    }

    func pinPart() {
        let app = XCUIApplication()

        app.tables.staticTexts[localizedString("profile_details")].tap()
        app.tables.switches[localizedString(localizedString("pin_enabled"))].tap()
        
        let button = app.buttons["1"]
        button.tap()
        button.tap()
        button.tap()

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            snapshot("03_Pin")
        }

        app.buttons["7"].pressForDuration(5.0)
    }

    func localizedString(key:String) -> String {
        let path = NSBundle(forClass: self.dynamicType).pathForResource(deviceLanguage, ofType: "lproj")!
        let localizationBundle = NSBundle(path: path)!
        return NSLocalizedString(key, bundle:localizationBundle, comment: "")
    }
}
