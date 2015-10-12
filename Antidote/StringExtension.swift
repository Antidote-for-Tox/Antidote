//
//  StringExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

extension String {
    init(localized: String, _ arguments: CVarArgType...) {
        let format = NSLocalizedString(localized, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
        self.init(format: format, arguments: arguments)
    }

    init(localized: String, comment: String, _ arguments: CVarArgType...) {
        let format = NSLocalizedString(localized, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: comment)
        self.init(format: format, arguments: arguments)
    }
}
