//
//  ChatEditable.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/05/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

/**
    Chat cell can confirm to this protocol to support editing with UIMenuController.
 */
protocol ChatEditable {
    /**
        Return true to show menu for given cell, false otherwise.
     */
    func shouldShowMenu() -> Bool

    /**
        Target rect in view to show menu from.

        - Returns: rect to show menu from.
     */
    func menuTargetRect() -> CGRect

    /**
        Methods fired when menu is going to be shown/hide.
        If you override this methods, you must call super at some point in your implementation.
     */
    func willShowMenu()
    func willHideMenu()
}
