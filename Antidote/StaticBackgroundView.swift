//
//  StaticBackgroundView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

/**
    View with static background color. Is used to prevent views inside UITableViewCell from blinking on tap.
 */
class StaticBackgroundView: UIView {
    override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {}
    }

    func setStaticBackgroundColor(color: UIColor?) {
        super.backgroundColor = color
    }
}
