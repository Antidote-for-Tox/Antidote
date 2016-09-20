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
    private enum State {
        case Unlocked
        case Locked(lockTime: CFTimeInterval)
        case ValidatingPin
    }

    private let theme: Theme
    private let window: UIWindow

    private weak var submanagerObjects: OCTSubmanagerObjects!

    private var state: State

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, lockOnStartup: Bool) {
        self.theme = theme
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        self.submanagerObjects = submanagerObjects
        self.state = .Unlocked

        super.init()

        // Showing window on top of all other windows.
        window.windowLevel = UIWindowLevelStatusBar + 1000

        if lockOnStartup {
            lockIfNeeded(0)
        }

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
        lockIfNeeded(CACurrentMediaTime())
    }

    func appDidBecomeActiveNotification() {
        switch state {
            case .Unlocked:
                // unlocked, nothing to do here
                break
            case .Locked(let lockTime):
                isPinDateExpired(lockTime) ? challengeUserToAuthorize(lockTime) : unlock()
            case .ValidatingPin:
                // checking pin, no action required
                break
        }
    }
}

extension PinAuthorizationCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        switch state {
            case .Locked(let lockTime):
                challengeUserToAuthorize(lockTime)
            default:
                // ignore
                break
        }
    }
}

extension PinAuthorizationCoordinator: EnterPinControllerDelegate {
    func enterPinController(controller: EnterPinController, successWithPin pin: String) {
        unlock()
    }

    func enterPinControllerFailure(controller: EnterPinController) {
        controller.resetEnteredPin()
        controller.topText = String(localized: "pin_incorrect")
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}

private extension PinAuthorizationCoordinator {
    func lockIfNeeded(lockTime: CFTimeInterval) {
        guard submanagerObjects.getProfileSettings().unlockPinCode != nil else {
            return
        }

        for window in UIApplication.sharedApplication().windows {
            window.endEditing(true)
        }

        let storyboard = UIStoryboard(name: "LaunchPlaceholderBoard", bundle: NSBundle.mainBundle())
        window.rootViewController = storyboard.instantiateViewControllerWithIdentifier("LaunchPlaceholderController")
        window.hidden = false

        switch state {
            case .Unlocked:
                // In case of Locked state don't want to update lockTime.
                // In case of ValidatingPin state we also don't want to do anything.
                state = .Locked(lockTime: lockTime)
            default:
                break
        }
    }

    func unlock() {
        state = .Unlocked
        window.hidden = true
    }

    func challengeUserToAuthorize(lockTime: CFTimeInterval) {
        if window.rootViewController is EnterPinController {
            // already showing pin controller
            return
        }

        if shouldUseTouchID() {
            state = .ValidatingPin

            LAContext().evaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics,
                                       localizedReason: String(localized: "pin_touch_id_description"),
                                       reply: { [weak self] success, error in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.state = .Locked(lockTime: lockTime)

                    success ? self?.unlock() : self?.showValidatePinController()
                }
            })
        }
        else {
            showValidatePinController()
        }
    }

    func showValidatePinController() {
        let settings = submanagerObjects.getProfileSettings()
        guard let pin = settings.unlockPinCode else {
            fatalError("pin shouldn't be nil")
        }

        let controller = EnterPinController(theme: theme, state: .ValidatePin(validPin: pin))
        controller.topText = String(localized: "pin_enter_to_unlock")
        controller.delegate = self
        window.rootViewController = controller
    }

    func isPinDateExpired(lockTime: CFTimeInterval) -> Bool {
        let settings = submanagerObjects.getProfileSettings()
        let delta = CACurrentMediaTime() - lockTime

        switch settings.lockTimeout {
            case .Immediately:
                return true
            case .Seconds30:
                return delta > 30
            case .Minute1:
                return delta > 60
            case .Minute2:
                return delta > (60 * 2)
            case .Minute5:
                return delta > (60 * 5)
        }
    }

    func shouldUseTouchID() -> Bool {
        guard submanagerObjects.getProfileSettings().useTouchID else {
            return false
        }

        guard LAContext().canEvaluatePolicy(.DeviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return false
        }

        return true
    }
}
