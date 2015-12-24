//
//  UINavigationControllerExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 06/11/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

extension UINavigationController {
    convenience init(statusNavigationBarWithTheme theme: Theme) {
        self.init(navigationBarClass: NSClassFromString("Antidote.StatusNavigationBar"), toolbarClass: nil)

        let bar = navigationBar as! StatusNavigationBar
        bar.configureWithTheme(theme, navigationController: self)
        bar.tintColor = theme.colorForType(.LinkText)
    }
}
