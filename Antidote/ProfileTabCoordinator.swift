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

class ProfileTabCoordinator {
    weak var delegate: ProfileTabCoordinatorDelegate?

    let theme: Theme
    let navigationController = UINavigationController()

    init(theme: Theme) {
        self.theme = theme
    }
}

extension ProfileTabCoordinator: ProfileMainControllerDelegate {
    func profileMainControllerLogout(controller: ProfileMainController) {
        delegate?.profileTabCoordinatorDelegateLogout(self)
    }
}

// MARK: CoordinatorProtocol
extension ProfileTabCoordinator : TabCoordinatorProtocol {
    func start() {
        let controller = ProfileMainController(theme: theme)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: false)
    }
}
