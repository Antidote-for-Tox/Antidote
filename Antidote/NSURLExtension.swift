//
//  NSURLExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 29.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import MobileCoreServices

extension NSURL {
    func isToxURL() -> Bool {
        var uniformTypeIdentifier: AnyObject?
        _ = try? getResourceValue(&uniformTypeIdentifier, forKey: NSURLTypeIdentifierKey)

        guard let identifier = uniformTypeIdentifier as? String else {
            return false
        }

        return UTTypeConformsTo(identifier, kUTTypeData)
    }
}
