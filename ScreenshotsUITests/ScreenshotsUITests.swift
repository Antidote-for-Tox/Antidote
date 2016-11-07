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
        app.launchArguments.append("UI_TESTING")
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
        app.tapTabBarElement(.Chats)
        
        snapshot(Constants.SnapshotConversation)

        app.tables.staticTexts[localizedString("app_store_screenshot_conversation_7")].tap()
        
        snapshot(Constants.SnapshotContactList)
        
        app.navigationBars[localizedString("chats_title")].buttons[localizedString("chats_title")].tap()
        
        app.tapTabBarElement(.Profile)
        
        pinPart()
    }

    func iPadPart() {
        let app = XCUIApplication()

        app.tables.staticTexts[localizedString("app_store_screenshot_conversation_7")].tap()

        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.TextView).element.tap()
        
        XCUIDevice.sharedDevice().orientation = .LandscapeRight

        snapshot(Constants.SnapshotConversation)

        app.navigationBars["Antidote.PrimaryIpad"].childrenMatchingType(.Other).element.childrenMatchingType(.Button).element.tap()
        
        pinPart()
    }

    func pinPart() {
        let app = XCUIApplication()

        app.tables.staticTexts[localizedString("profile_details")].tap()
        app.tables.switches[localizedString("pin_enabled")].tap()
        
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
}

extension XCUIApplication {
    enum TabBarElement {
        case Contacts
        case Chats
        case Settings
        case Profile

        var index: UInt {
            switch self {
                case .Contacts:
                    return 1
                case .Chats:
                    return 2
                case .Settings:
                    return 3
                case .Profile:
                    return 4
            }
        }
    }

    func tapTabBarElement(element: TabBarElement) {
        // TODO refactor me pls
        let button = childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(element.index).childrenMatchingType(.Button).element

        button.tap()
    }
}

func localizedString(key: String) -> String {
    class LocalizableDummy {}

    let bundle = NSBundle(forClass: LocalizableDummy().dynamicType)

    var language = deviceLanguage

    switch language {
        case "en-US":
            language = "en"
        default:
            break
    }

    let path = bundle.pathForResource(language, ofType: "lproj")!

    let localizationBundle = NSBundle(path: path)!
    return NSLocalizedString(key, bundle:localizationBundle, comment: "")
}
