//
//  ActiveSessionNavigationCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 15/11/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class ActiveSessionNavigationCoordinator {
    let theme: Theme
    let navigationController: UINavigationController

    init(theme: Theme) {
        self.theme = theme
        self.navigationController = UINavigationController()
    }

    init(theme: Theme, navigationController: UINavigationController) {
        self.theme = theme
        self.navigationController = navigationController
    }

    func startWithOptions(options: CoordinatorOptions?) {
        preconditionFailure("This method must be overridden")
    }
}
