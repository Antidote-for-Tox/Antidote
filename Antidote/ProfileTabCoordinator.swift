// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import AudioToolbox

protocol ProfileTabCoordinatorDelegate: class {
    func profileTabCoordinatorDelegateLogout(_ coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDeleteProfile(_ coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDidChangeUserStatus(_ coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDidChangeAvatar(_ coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDidChangeUserName(_ coordinator: ProfileTabCoordinator)
}

class ProfileTabCoordinator: ActiveSessionNavigationCoordinator {
    weak var delegate: ProfileTabCoordinatorDelegate?

    fileprivate weak var toxManager: OCTManager!

    init(theme: Theme, toxManager: OCTManager) {
        self.toxManager = toxManager

        super.init(theme: theme)
    }

    override func startWithOptions(_ options: CoordinatorOptions?) {
        let controller = ProfileMainController(theme: theme, submanagerUser: toxManager.user)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: false)
    }
}

extension OCTToxErrorSetInfoCode: Error {

}

extension ProfileTabCoordinator: ProfileMainControllerDelegate {
    func profileMainControllerLogout(_ controller: ProfileMainController) {
        delegate?.profileTabCoordinatorDelegateLogout(self)
    }

    func profileMainControllerChangeUserName(_ controller: ProfileMainController) {
        showTextEditController(title: String(localized: "name"), defaultValue: toxManager.user.userName() ?? "") {
            [unowned self] newName -> Void in

            do {
                try self.toxManager.user.setUserName(newName)
                self.delegate?.profileTabCoordinatorDelegateDidChangeUserName(self)
            }
            catch let error as NSError {
                handleErrorWithType(.toxSetInfoCodeName, error: error)
            }
        }
    }

    func profileMainControllerChangeUserStatus(_ controller: ProfileMainController) {
        let controller = ChangeUserStatusController(theme: theme, selectedStatus: toxManager.user.userStatus)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func profileMainControllerChangeStatusMessage(_ controller: ProfileMainController) {
        showTextEditController(title: String(localized: "status_message"), defaultValue: toxManager.user.userStatusMessage() ?? "") {
            newStatusMessage -> Void in

            do {
                try self.toxManager.user.setUserStatusMessage(newStatusMessage)
            }
            catch let error as NSError {
                handleErrorWithType(.toxSetInfoCodeStatusMessage, error: error)
            }
        }
    }

    func profileMainController(_ controller: ProfileMainController, showQRCodeWithText text: String) {
        let controller = QRViewerController(theme: theme, text: text)
        controller.delegate = self

        let toPresent = UINavigationController(rootViewController: controller)

        navigationController.present(toPresent, animated: true, completion: nil)
    }

    func profileMainControllerShowProfileDetails(_ controller: ProfileMainController) {
        let controller = ProfileDetailsController(theme: theme, toxManager: toxManager)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func profileMainControllerDidChangeAvatar(_ controller: ProfileMainController) {
        delegate?.profileTabCoordinatorDelegateDidChangeAvatar(self)
    }
}

extension ProfileTabCoordinator: ChangeUserStatusControllerDelegate {
    func changeUserStatusController(_ controller: ChangeUserStatusController, selectedStatus: OCTToxUserStatus) {
        toxManager.user.userStatus = selectedStatus
        navigationController.popViewController(animated: true)

        delegate?.profileTabCoordinatorDelegateDidChangeUserStatus(self)
    }
}

extension ProfileTabCoordinator: QRViewerControllerDelegate {
    func qrViewerControllerDidFinishPresenting() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

extension ProfileTabCoordinator: ChangePasswordControllerDelegate {
    func changePasswordControllerDidFinishPresenting(_ controller: ChangePasswordController) {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

extension ProfileTabCoordinator: ProfileDetailsControllerDelegate {
    func profileDetailsControllerSetPin(_ controller: ProfileDetailsController) {
        let controller = EnterPinController(theme: theme, state: .setPin)
        controller.topText = String(localized: "pin_set")
        controller.delegate = self

        let toPresent = PortraitNavigationController(rootViewController: controller)
        toPresent.isNavigationBarHidden = true
        navigationController.present(toPresent, animated: true, completion: nil)
    }

    func profileDetailsControllerChangeLockTimeout(_ controller: ProfileDetailsController) {
        let controller = ChangePinTimeoutController(theme: theme, submanagerObjects: toxManager.objects)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func profileDetailsControllerChangePassword(_ controller: ProfileDetailsController) {
        let controller = ChangePasswordController(theme: theme, toxManager: toxManager)
        controller.delegate = self

        let toPresent = UINavigationController(rootViewController: controller)
        navigationController.present(toPresent, animated: true, completion: nil)
    }

    func profileDetailsControllerDeleteProfile(_ controller: ProfileDetailsController) {
        delegate?.profileTabCoordinatorDelegateDeleteProfile(self)
    }
}

extension ProfileTabCoordinator: EnterPinControllerDelegate {
    func enterPinController(_ controller: EnterPinController, successWithPin pin: String) {
        switch controller.state {
            case .validatePin:
                let settings = toxManager.objects.getProfileSettings()
                settings.unlockPinCode = pin
                toxManager.objects.saveProfileSettings(settings)

                navigationController.dismiss(animated: true, completion: nil)
            case .setPin:
                guard let presentedNavigation = controller.navigationController else {
                    fatalError("wrong state")
                }

                let validate = EnterPinController(theme: theme, state: .validatePin(validPin: pin))
                validate.topText = String(localized: "pin_confirm")
                validate.delegate = self

                presentedNavigation.viewControllers = [validate]
        }
    }

    func enterPinControllerFailure(_ controller: EnterPinController) {
        guard let presentedNavigation = controller.navigationController else {
            fatalError("wrong state")
        }

        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        let setPin = EnterPinController(theme: theme, state: .setPin)
        setPin.topText = String(localized: "pin_do_not_match")
        setPin.delegate = self

        presentedNavigation.viewControllers = [setPin]
    }
}

extension ProfileTabCoordinator: ChangePinTimeoutControllerDelegate {
    func changePinTimeoutControllerDone(_ controller: ChangePinTimeoutController) {
        navigationController.popViewController(animated: true)
    }
}

private extension ProfileTabCoordinator {
    func showTextEditController(title: String, defaultValue: String, setValueClosure: @escaping (String) -> Void) {
        let controller = TextEditController(theme: theme, title: title, defaultValue: defaultValue, changeTextHandler: {
            newName -> Void in

            setValueClosure(newName)
        }, userFinishedEditing: { [unowned self] in
            self.navigationController.popViewController(animated: true)
        })

        navigationController.pushViewController(controller, animated: true)
    }
}
