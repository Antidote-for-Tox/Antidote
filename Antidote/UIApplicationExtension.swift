//
//  UIApplicationExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

extension UIApplication {
    class var isActive: Bool {
        get {
            switch sharedApplication().applicationState {
                case .Active:
                    return true
                case .Inactive:
                    return false
                case .Background:
                    return false
            }
        }
    }
}
