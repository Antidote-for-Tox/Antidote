//
//  ThemeTest.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import XCTest

class ThemeTest: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testParsingFile() {
        let string =
            "version: 1\n" +
            "colors:\n" +
            "  first: \"AABBCC\"\n" +
            "  second: \"55667788\"\n" +
            "values:\n" +
            "  login-background: first\n" +
            "  login-tox-logo: second\n" +
            "  login-button-text: first\n" +
            "  login-button-background: second\n" +
            "  login-description-label: first\n" +
            "  login-form-background: second\n" +
            "  login-form-text: first\n" +
            "  login-link-color: second\n" +

            "  translucent-background: first\n" +

            "  normal-background: second\n" +
            "  normal-text: first\n" +
            "  link-text: second\n" +
            "  connecting-background: first\n" +
            "  connecting-text: second\n" +
            "  separators-and-borders: first\n" +
            "  offline-status: second\n" +
            "  online-status: first\n" +
            "  away-status: second\n" +
            "  busy-status: first\n" +
            "  status-background: second\n" +
            "  friend-cell-status: first\n" +
            "  chat-list-cell-message: second\n" +
            "  chat-list-cell-unread-background: first\n" +
            "  chat-input-background: second\n" +
            "  chat-incoming-bubble: first\n" +
            "  chat-outgoing-bubble: second\n" +
            "  tab-badge-background: first\n" +
            "  tab-badge-text: second\n" +
            "  tab-item-active: first\n" +
            "  tab-item-inactive: second\n" +
            "  notification-background: first\n" +
            "  notification-text: second\n" +
            "  settings-background: first\n" +
            "  call-text-color: second\n" +
            "  call-decline-button-background: first\n" +
            "  call-answer-button-background: second\n" +
            "  call-control-background: first\n" +
            "  call-control-selected-background: second\n" +
            "  call-button-icon-color: first\n" +
            "  call-button-selected-icon-color: second\n" +
            "  call-video-preview-background: first\n"

        let first = UIColor(red: 170.0 / 255.0, green: 187.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        let second = UIColor(red: 85.0 / 255.0, green: 102.0 / 255.0, blue: 119.0 / 255.0, alpha: 136.0 / 255.0)

        do {
            let theme = try Theme(yamlString: string)

            XCTAssertEqual(first, theme.colorForType(.LoginBackground))
            XCTAssertEqual(second, theme.colorForType(.LoginToxLogo))
            XCTAssertEqual(first, theme.colorForType(.LoginButtonText))
            XCTAssertEqual(second, theme.colorForType(.LoginButtonBackground))
            XCTAssertEqual(first, theme.colorForType(.LoginDescriptionLabel))
            XCTAssertEqual(second, theme.colorForType(.LoginFormBackground))
            XCTAssertEqual(first, theme.colorForType(.LoginFormText))
            XCTAssertEqual(second, theme.colorForType(.LoginLinkColor))

            XCTAssertEqual(first, theme.colorForType(.TranslucentBackground))

            XCTAssertEqual(second, theme.colorForType(.NormalBackground))
            XCTAssertEqual(first, theme.colorForType(.NormalText))
            XCTAssertEqual(second, theme.colorForType(.LinkText))
            XCTAssertEqual(first, theme.colorForType(.ConnectingBackground))
            XCTAssertEqual(second, theme.colorForType(.ConnectingText))
            XCTAssertEqual(first, theme.colorForType(.SeparatorsAndBorders))
            XCTAssertEqual(second, theme.colorForType(.OfflineStatus))
            XCTAssertEqual(first, theme.colorForType(.OnlineStatus))
            XCTAssertEqual(second, theme.colorForType(.AwayStatus))
            XCTAssertEqual(first, theme.colorForType(.BusyStatus))
            XCTAssertEqual(second, theme.colorForType(.StatusBackground))
            XCTAssertEqual(first, theme.colorForType(.FriendCellStatus))
            XCTAssertEqual(second, theme.colorForType(.ChatListCellMessage))
            XCTAssertEqual(first, theme.colorForType(.ChatListCellUnreadBackground))
            XCTAssertEqual(second, theme.colorForType(.ChatInputBackground))
            XCTAssertEqual(first, theme.colorForType(.ChatIncomingBubble))
            XCTAssertEqual(second, theme.colorForType(.ChatOutgoingBubble))
            XCTAssertEqual(first, theme.colorForType(.TabBadgeBackground))
            XCTAssertEqual(second, theme.colorForType(.TabBadgeText))
            XCTAssertEqual(first, theme.colorForType(.TabItemActive))
            XCTAssertEqual(second, theme.colorForType(.TabItemInactive))
            XCTAssertEqual(first, theme.colorForType(.NotificationBackground))
            XCTAssertEqual(second, theme.colorForType(.NotificationText))
            XCTAssertEqual(first, theme.colorForType(.SettingsBackground))
            XCTAssertEqual(second, theme.colorForType(.CallTextColor))
            XCTAssertEqual(first, theme.colorForType(.CallDeclineButtonBackground))
            XCTAssertEqual(second, theme.colorForType(.CallAnswerButtonBackground))
            XCTAssertEqual(first, theme.colorForType(.CallControlBackground))
            XCTAssertEqual(second, theme.colorForType(.CallControlSelectedBackground))
            XCTAssertEqual(first, theme.colorForType(.CallButtonIconColor))
            XCTAssertEqual(second, theme.colorForType(.CallButtonSelectedIconColor))
            XCTAssertEqual(first, theme.colorForType(.CallVideoPreviewBackground))
        }
        catch let error as ErrorTheme {
            XCTFail(error.debugDescription())
        }
        catch {
            XCTFail("Theme init failed for unknown reason")
        }
    }

    func testVersionToHight() {
        let string =
            "version: 2\n" +
            "colors:\n" +
            "  first: \"AABBCC\"\n" +
            "values:\n" +
            "  login-background: first\n"

        var didThrow = false

        do {
            let _ = try Theme(yamlString: string)
        }
        catch ErrorTheme.WrongVersion(let description) {
            didThrow = description == String(localized: "theme_error_version_too_high")
        }
        catch {
            didThrow = false
        }

        XCTAssertTrue(didThrow)
    }

    func testVersionToLow() {
        let string =
            "version: 0\n" +
            "colors:\n" +
            "  first: \"AABBCC\"\n" +
            "values:\n" +
            "  login-background: first\n"

        var didThrow = false

        do {
            let _ = try Theme(yamlString: string)
        }
        catch ErrorTheme.WrongVersion(let description) {
            didThrow = description == String(localized: "theme_error_version_too_low")
        }
        catch {
            didThrow = false
        }

        XCTAssertTrue(didThrow)
    }
}
