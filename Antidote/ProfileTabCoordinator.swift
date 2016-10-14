// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import AudioToolbox

protocol ProfileTabCoordinatorDelegate: class {
    func profileTabCoordinatorDelegateLogout(coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDeleteProfile(coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDidChangeUserStatus(coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDidChangeAvatar(coordinator: ProfileTabCoordinator)
    func profileTabCoordinatorDelegateDidChangeUserName(coordinator: ProfileTabCoordinator)
}

class ProfileTabCoordinator: ActiveSessionNavigationCoordinator {
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
        showTextEditController(title: String(localized: "name"), defaultValue: toxManager.user.userName() ?? "") {
            [unowned self] newName -> Void in

            do {
                try self.toxManager.user.setUserName(newName)
                self.delegate?.profileTabCoordinatorDelegateDidChangeUserName(self)
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
        showTextEditController(title: String(localized: "status_message"), defaultValue: toxManager.user.userStatusMessage() ?? "") {
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

extension ProfileTabCoordinator: ChangePasswordControllerDelegate {
    func changePasswordControllerDidFinishPresenting(controller: ChangePasswordController) {
        navigationController.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ProfileTabCoordinator: ProfileDetailsControllerDelegate {
    func profileDetailsControllerSetPin(controller: ProfileDetailsController) {
        let controller = EnterPinController(theme: theme, state: .SetPin)
        controller.topText = String(localized: "pin_set")
        controller.delegate = self

        let toPresent = PortraitNavigationController(rootViewController: controller)
        toPresent.navigationBarHidden = true
        navigationController.presentViewController(toPresent, animated: true, completion: nil)
    }

    func profileDetailsControllerChangeLockTimeout(controller: ProfileDetailsController) {
        let controller = ChangePinTimeoutController(theme: theme, submanagerObjects: toxManager.objects)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }

    func profileDetailsControllerChangePassword(controller: ProfileDetailsController) {
        let controller = ChangePasswordController(theme: theme, toxManager: toxManager)
        controller.delegate = self

        let toPresent = UINavigationController(rootViewController: controller)
        navigationController.presentViewController(toPresent, animated: true, completion: nil)
    }

    func profileDetailsControllerDeleteProfile(controller: ProfileDetailsController) {
        delegate?.profileTabCoordinatorDelegateDeleteProfile(self)
    }
}

extension ProfileTabCoordinator: EnterPinControllerDelegate {
    func enterPinController(controller: EnterPinController, successWithPin pin: String) {
        switch controller.state {
            case .ValidatePin:
                let settings = toxManager.objects.getProfileSettings()
                settings.unlockPinCode = pin
                toxManager.objects.saveProfileSettings(settings)

                navigationController.dismissViewControllerAnimated(true, completion: nil)
            case .SetPin:
                guard let presentedNavigation = controller.navigationController else {
                    fatalError("wrong state")
                }

                let validate = EnterPinController(theme: theme, state: .ValidatePin(validPin: pin))
                validate.topText = String(localized: "pin_confirm")
                validate.delegate = self

                presentedNavigation.viewControllers = [validate]
        }
    }

    func enterPinControllerFailure(controller: EnterPinController) {
        guard let presentedNavigation = controller.navigationController else {
            fatalError("wrong state")
        }

        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))

        let setPin = EnterPinController(theme: theme, state: .SetPin)
        setPin.topText = String(localized: "pin_do_not_match")
        setPin.delegate = self

        presentedNavigation.viewControllers = [setPin]
    }
}

extension ProfileTabCoordinator: ChangePinTimeoutControllerDelegate {
    func changePinTimeoutControllerDone(controller: ChangePinTimeoutController) {
        navigationController.popViewControllerAnimated(true)
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
}
