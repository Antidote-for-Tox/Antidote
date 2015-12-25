//
//  ViewPassingGestures.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class ViewPassingGestures: UIView {
    override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
        for subview in subviews {
            let converted = convertPoint(point, toView: subview)

            if subview.hitTest(converted, withEvent: event) != nil {
                return true
            }
        }

        return false
    }
}
