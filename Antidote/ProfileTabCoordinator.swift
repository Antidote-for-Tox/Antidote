//
//  ProfileTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

protocol ProfileTabCoordinatorDelegate: class {
    func profileTabCoordinatorDelegateLogout(coordinator: ProfileTabCoordinator)
}

class ProfileTabCoordinator: RunningBasicCoordinator {
    weak var delegate: ProfileTabCoordinatorDelegate?

    override func start() {
        let controller = ProfileMainController(theme: theme)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: false)
    }
}

extension ProfileTabCoordinator: ProfileMainControllerDelegate {
    func profileMainControllerLogout(controller: ProfileMainController) {
        delegate?.profileTabCoordinatorDelegateLogout(self)
    }
}
