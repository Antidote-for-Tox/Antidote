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
    func profileTabCoordinatorDelegateDidChangeUserStatus(coordinator: ProfileTabCoordinator)
}

class ProfileTabCoordinator: RunningNavigationCoordinator {
    weak var delegate: ProfileTabCoordinatorDelegate?

    private let toxManager: OCTManager

    init(theme: Theme, toxManager: OCTManager) {
        self.toxManager = toxManager

        super.init(theme: theme)
    }

    override func startWithOptions(options: CoordinatorOptions?) {
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

            do {
                try self.toxManager.user.setUserName(newName)
            }
            catch let error as NSError {
                handleErrorWithType(.ToxSetInfoCodeName, error: error)
                return false
            }

            return true
        }
    }

    func profileMainControllerChangeUserStatus(controller: ProfileMainController) {
        let controller = ChangeUserStatusController(theme: theme, selectedStatus: toxManager.user.userStatus)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func profileMainControllerChangeStatusMessage(controller: ProfileMainController) {
        showTextEditController(title: String(localized: "status_message"), defaultValue: toxManager.user.userStatusMessage()) {
            newStatusMessage -> Bool in

            do {
                try self.toxManager.user.setUserStatusMessage(newStatusMessage)
            }
            catch let error as NSError {
                handleErrorWithType(.ToxSetInfoCodeStatusMessage, error: error)
                return false
            }

            return true
        }
    }

    func profileMainController(controller: ProfileMainController, showQRCodeWithText text: String) {
        let controller = QRViewerController(theme: theme, text: text)
        controller.delegate = self

        let toPresent = UINavigationController(rootViewController: controller)

        navigationController.presentViewController(toPresent, animated: true, completion: nil)
    }

    func profileMainControllerShowProfileDetails(controller: ProfileMainController) {
        let controller = ProfileDetailsController(theme: theme, toxManager: toxManager)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

extension ProfileTabCoordinator: ChangeUserStatusControllerDelegate {
    func changeUserStatusController(controller: ChangeUserStatusController, selectedStatus: OCTToxUserStatus) {
        toxManager.user.userStatus = selectedStatus
        navigationController.popViewControllerAnimated(true)

        delegate?.profileTabCoordinatorDelegateDidChangeUserStatus(self)
    }
}

extension ProfileTabCoordinator: QRViewerControllerDelegate {
    func qrViewerControllerDidFinishPresenting() {
        navigationController.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ProfileTabCoordinator: ProfileDetailsControllerDelegate {
    func profileDetailsControllerChangePassword(controller: ProfileDetailsController) {

    }

    func profileDetailsControllerDeleteProfile(controller: ProfileDetailsController) {

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
