//
//  FriendsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

class FriendsTabCoordinator: RunningBasicCoordinator {
    override func start() {
        let controller = UIViewController()
        controller.title = "Friends"

        navigationController.pushViewController(controller, animated: false)
    }
}
