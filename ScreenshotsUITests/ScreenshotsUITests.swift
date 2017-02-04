// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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

        XCUIDevice.shared().orientation = .portrait

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

        addUIInterruptionMonitor(withDescription: "Notifications alert") { (alert) -> Bool in
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
        app.tapTabBarElement(element: .Chats)
        
        snapshot(Constants.SnapshotContactList)

        app.tables.staticTexts[localizedString("app_store_screenshot_conversation_7")].tap()
        
        snapshot(Constants.SnapshotConversation)

        app.navigationBars[localizedString("chats_title")].buttons.element(boundBy: 0).tap()
        
        app.tapTabBarElement(element: .Profile)
        
        pinPart()
    }

    func iPadPart() {
        let app = XCUIApplication()

        app.tables.staticTexts[localizedString("app_store_screenshot_conversation_7")].tap()

        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 0).children(matching: .textView).element.tap()
        
        XCUIDevice.shared().orientation = .landscapeRight

        snapshot(Constants.SnapshotConversation)

        app.navigationBars["Antidote.PrimaryIpad"].children(matching: .other).element.children(matching: .button).element.tap()
        
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

        let delayTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            snapshot("03_Pin")
        }

        app.buttons["7"].press(forDuration: 5.0)
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
        let button = children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: element.index).children(matching: .button).element

        button.tap()
    }
}

func localizedString(_ key: String) -> String {
    class LocalizableDummy {}

    let bundle = Bundle(for: type(of: LocalizableDummy()))

    var language = deviceLanguage

    switch language {
        case "en-US":
            language = "en"
        default:
            break
    }

    let path = bundle.path(forResource: language, ofType: "lproj")!

    let localizationBundle = Bundle(path: path)!
    return NSLocalizedString(key, bundle:localizationBundle, comment: "")
}

