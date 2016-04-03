//
//  SnapshotBaseTest.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import XCTest

class SnapshotBaseTest: FBSnapshotTestCase {
    var theme: Theme!

    var image: UIImage {
        get {
            let bundle = NSBundle(forClass: self.dynamicType)
            return UIImage(named: "icon", inBundle:bundle, compatibleWithTraitCollection: nil)!
        }
    }

    override func setUp() {
        super.setUp()

        let filepath = NSBundle.mainBundle().pathForResource("default-theme", ofType: "yaml")!
        let yamlString = try! NSString(contentsOfFile:filepath, encoding:NSUTF8StringEncoding) as String

        theme = try! Theme(yamlString: yamlString)
    }
}
