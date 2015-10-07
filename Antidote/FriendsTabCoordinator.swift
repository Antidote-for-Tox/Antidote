//
//  FriendsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class FriendsTabCoordinator {
    let navigationController = UINavigationController()
}

// MARK: CoordinatorProtocol
extension FriendsTabCoordinator : TabCoordinatorProtocol {
    func start() {
        let controller = UIViewController()
        controller.title = "Friends"

        navigationController.pushViewController(controller, animated: false)
    }
}
