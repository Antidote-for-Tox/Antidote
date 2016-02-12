//
//  PortraitNavigationController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 13/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class PortraitNavigationController: UINavigationController {
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
}
