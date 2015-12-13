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

    let toxManager: OCTManager

    init(theme: Theme, toxManager: OCTManager) {
        self.toxManager = toxManager

        super.init(theme: theme)
    }

    override func start() {
        let controller = ProfileMainController(theme: theme, submanagerUser: toxManager.user)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: false)
    }
}

extension OCTToxErrorSetInfoCode: ErrorType {

}

extension ProfileTabCoordinator: ProfileMainControllerDelegate {
    func profileMainControllerLogout(controller: ProfileMainController) {
        delegate?.profileTabCoordinatorDelegateLogout(self)
    }

    func profileMainControllerChangeUserName(controller: ProfileMainController) {
        showTextEditController(title: String(localized: "name"), defaultValue: toxManager.user.userName()) {
            newName -> Bool in

            if (try? self.toxManager.user.setUserName(newName)) != nil {
                return true
            }
            return false
        }
    }

    func profileMainControllerChangeStatusMessage(controller: ProfileMainController) {
        showTextEditController(title: String(localized: "status_message"), defaultValue: toxManager.user.userStatusMessage()) {
            newStatusMessage -> Bool in

            if (try? self.toxManager.user.setUserStatusMessage(newStatusMessage)) != nil {
                return true
            }
            return false
        }
    }

    func profileMainController(controller: ProfileMainController, showQRCodeWithText text: String) {

    }

    func profileMainControllerShowProfileDetails(controller: ProfileMainController) {

    }
}

private extension ProfileTabCoordinator {
    /**
        - Parameters:
          - setValueClosure: return true if to pop to previous controller, false otherwise
     */
    func showTextEditController(title title: String, defaultValue: String, setValueClosure: String -> Bool) {
        let controller = TextEditController(theme: theme, title: title, defaultValue: defaultValue) {
            [unowned self] newName -> Void in

            if setValueClosure(newName) {
                self.navigationController.popViewControllerAnimated(true)
            }
        }

        navigationController.pushViewController(controller, animated: true)
    }
}
