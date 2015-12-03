//
//  UITableViewCellExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 03/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var staticReuseIdentifier: String {
        get {
            return NSStringFromClass(self)
        }
    }
}
