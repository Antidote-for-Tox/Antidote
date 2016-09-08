//
//  PinAuthorizationCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02/09/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class PinAuthorizationCoordinator: NSObject {
    private let theme: Theme
    private let window: UIWindow

    init(theme: Theme) {
        self.theme = theme
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

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
        showLockScreenIfNeeded()
    }

    func appDidBecomeActiveNotification() {
        if !challengeUserToAuthorizeIfNeeded() {
            window.hidden = true
        }
    }
}

extension PinAuthorizationCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        challengeUserToAuthorizeIfNeeded()
    }
}

extension PinAuthorizationCoordinator: EnterPinControllerDelegate {
    func enterPinController(controller: EnterPinController, successWithPin pin: String) {
        window.hidden = true
    }
}

private extension PinAuthorizationCoordinator {
    func showLockScreenIfNeeded() {
        guard isPinEnabled() else {
            return
        }

        let storyboard = UIStoryboard(name: "LaunchPlaceholderBoard", bundle: NSBundle.mainBundle())
        window.rootViewController = storyboard.instantiateViewControllerWithIdentifier("LaunchPlaceholderController")
        window.hidden = false
    }

    func challengeUserToAuthorizeIfNeeded() -> Bool {
        guard isPinEnabled() else {
            return false
        }

        let controller = EnterPinController(theme: theme, state: .ValidatePin(validPin: "1234"))
        controller.delegate = self
        window.rootViewController = controller
        window.hidden = false

        return true
    }

    func isPinEnabled() -> Bool {
        return true
    }
}
