//
//  ProfileTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class ProfileTabCoordinator {
    let navigationController = UINavigationController()
}

// MARK: CoordinatorProtocol
extension ProfileTabCoordinator : TabCoordinatorProtocol {
    func start() {
        let controller = UIViewController()
        controller.title = "Profile"

        navigationController.pushViewController(controller, animated: false)
    }
}
