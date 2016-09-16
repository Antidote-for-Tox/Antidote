//
//  PinAuthorizationCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02/09/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import AudioToolbox
import LocalAuthentication

class PinAuthorizationCoordinator: NSObject {
    private let theme: Theme
    private let window: UIWindow

    private weak var submanagerObjects: OCTSubmanagerObjects!

    private var isCheckingTouchID: Bool = false
    
    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.submanagerObjects = submanagerObjects

        super.init()

        // Showing window on top of all other windows.
        window.windowLevel = UIWindowLevelStatusBar + 1000
        window.backgroundColor = .redColor()

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PinAuthorizationCoordinator.appWillResignActiveNotification),
                                                         name: UIApplicationWillResignActiveNotification,
                                                         object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(PinAuthorizationCoordinator.appDidBecomeActiveNotification),
                                                         name: UIApplicationDidBecomeActiveNotification,
                                                         object: nil)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func appWillResignActiveNotification() {
        lockIfNeeded()
    }

    func appDidBecomeActiveNotification() {
        challengeUserToAuthorizeIfNeeded()
    }
}

extension PinAuthorizationCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        lockIfNeeded()
        challengeUserToAuthorizeIfNeeded()
    }
}

extension PinAuthorizationCoordinator: EnterPinControllerDelegate {
    func enterPinController(controller: EnterPinController, successWithPin pin: String) {
        window.hidden = true
    }

    func enterPinControllerFailure(controller: EnterPinController) {
        controller.resetEnteredPin()
        controller.topText = String(localized: "pin_incorrect")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}

private extension PinAuthorizationCoordinator {
    func lockIfNeeded() {
        let settings = submanagerObjects.getProfileSettings()

        guard settings.unlockPinCode != nil else {
            return
        }

        let storyboard = UIStoryboard(name: "LaunchPlaceholderBoard", bundle: NSBundle.mainBundle())
        window.rootViewController = storyboard.instantiateViewControllerWithIdentifier("LaunchPlaceholderController")
        window.hidden = false
    }

    func challengeUserToAuthorizeIfNeeded() {
        guard shouldCheckPin() else {
            return
        }

        if window.rootViewController is EnterPinController {
            // already showing pin controller
            return
        }

        let context = LAContext()

        if touchIdEnabled() && context.canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: nil) {
            isCheckingTouchID = true

            context.evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: String(localized: "pin_touch_id_description"),
                                   reply: { [weak self] success, error in
                dispatch_async(dispatch_get_main_queue()) {
                    if success {
                        self?.window.hidden = true
                    }
                    else {
                        self?.validatePin()
                    }

                    self?.isCheckingTouchID = false
                }
            })
        }
        else {
            validatePin()
        }
    }

    func validatePin() {
        let settings = submanagerObjects.getProfileSettings()
        guard let pin = settings.unlockPinCode else {
            fatalError("pin shouldn't be nil")
        }

        let controller = EnterPinController(theme: theme, state: .ValidatePin(validPin: pin))
        controller.topText = String(localized: "pin_enter_to_unlock")
        controller.delegate = self
        window.rootViewController = controller
        window.hidden = false
    }

    func shouldCheckPin() -> Bool {
        if isCheckingTouchID {
            // Already checking pin.
            return false
        }

        if window.hidden {
            // Already unlocked
            return false
        }

        return true
    }

    func touchIdEnabled() -> Bool {
        let settings = submanagerObjects.getProfileSettings()

        return settings.useTouchID
    }
}
