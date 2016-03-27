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
    func profileTabCoordinatorDelegateDeleteProfile(coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDidChangeUserStatus(coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDidChangeAvatar(coordinator: ProfileTabCoordinator)
}

class ProfileTabCoordinator: RunningNavigationCoordinator {
    weak var delegate: ProfileTabCoordinatorDelegate?

    private weak var toxManager: OCTManager!

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
            newName -> Void in

            do {
                try self.toxManager.user.setUserName(newName)
            }
            catch let error as NSError {
                handleErrorWithType(.ToxSetInfoCodeName, error: error)
            }
        }
    }

    func profileMainControllerChangeUserStatus(controller: ProfileMainController) {
        let controller = ChangeUserStatusController(theme: theme, selectedStatus: toxManager.user.userStatus)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func profileMainControllerChangeStatusMessage(controller: ProfileMainController) {
        showTextEditController(title: String(localized: "status_message"), defaultValue: toxManager.user.userStatusMessage()) {
            newStatusMessage -> Void in

            do {
                try self.toxManager.user.setUserStatusMessage(newStatusMessage)
            }
            catch let error as NSError {
                handleErrorWithType(.ToxSetInfoCodeStatusMessage, error: error)
            }
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

    func profileMainControllerDidChangeAvatar(controller: ProfileMainController) {
        delegate?.profileTabCoordinatorDelegateDidChangeAvatar(self)
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

extension ProfileTabCoordinator: PasswordControllerDelegate {
    func passwordControllerDidFinishPresenting(controller: PasswordController) {
        navigationController.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ProfileTabCoordinator: ProfileDetailsControllerDelegate {
    func profileDetailsControllerSetPassword(controller: ProfileDetailsController) {
        showPasswordController(.SetNewPassword)
    }

    func profileDetailsControllerChangePassword(controller: ProfileDetailsController) {
        showPasswordController(.SetNewPassword)
    }

    func profileDetailsControllerDeletePassword(controller: ProfileDetailsController) {
        showPasswordController(.DeletePassword)
    }

    func profileDetailsControllerDeleteProfile(controller: ProfileDetailsController) {
        delegate?.profileTabCoordinatorDelegateDeleteProfile(self)
    }
}

private extension ProfileTabCoordinator {
    func showTextEditController(title title: String, defaultValue: String, setValueClosure: String -> Void) {
        let controller = TextEditController(theme: theme, title: title, defaultValue: defaultValue, changeTextHandler: {
            newName -> Void in

            setValueClosure(newName)
        }, userFinishedEditing: { [unowned self] in
            self.navigationController.popViewControllerAnimated(true)
        })

        navigationController.pushViewController(controller, animated: true)
    }

    func showPasswordController(type: PasswordController.ControllerType) {
        let controller = PasswordController(theme: theme, type: type, toxManager: toxManager)
        controller.delegate = self

        let toPresent = UINavigationController(rootViewController: controller)
        navigationController.presentViewController(toPresent, animated: true, completion: nil)
    }
}
