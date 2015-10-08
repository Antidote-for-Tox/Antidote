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
            "  login-button-text: second\n"

        let first = UIColor(red: 170.0 / 255.0, green: 187.0 / 255.0, blue: 204.0 / 255.0, alpha: 1.0)
        let second = UIColor(red: 85.0 / 255.0, green: 102.0 / 255.0, blue: 119.0 / 255.0, alpha: 136.0 / 255.0)

        let theme = try? Theme(yamlString: string)

        XCTAssertNotNil(theme)

        XCTAssertEqual(first, theme?.colorForType(.LoginBackground))
        XCTAssertEqual(second, theme?.colorForType(.LoginButtonText))
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
        catch ErrorTheme.VersionTooHigh {
            didThrow = true
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
        catch ErrorTheme.VersionTooLow {
            didThrow = true
        }
        catch {
            didThrow = false
        }

        XCTAssertTrue(didThrow)
    }
}
