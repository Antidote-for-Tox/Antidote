//
//  UIViewControllerExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

extension UIViewController {
    func loadViewWithBackgroundColor(backgroundColor: UIColor) {
        let frame = CGRect(origin: CGPointZero, size: UIScreen.mainScreen().bounds.size)

        view = UIView(frame: frame)
        view.backgroundColor = backgroundColor
    }
}
