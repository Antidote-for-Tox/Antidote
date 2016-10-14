// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol RunningCoordinatorDelegate: class {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator, importToxProfileFromURL: NSURL?)
    func runningCoordinatorDeleteProfile(coordinator: RunningCoordinator)
    func runningCoordinatorRecreateCoordinatorsStack(coordinator: RunningCoordinator, options: CoordinatorOptions)
}

class RunningCoordinator {
    weak var delegate: RunningCoordinatorDelegate?

    private let theme: Theme
    private let window: UIWindow

    private var toxManager: OCTManager
    private var options: CoordinatorOptions?

    private var activeSessionCoordinator: ActiveSessionCoordinator?
    private var pinAuthorizationCoordinator: PinAuthorizationCoordinator

    init(theme: Theme, window: UIWindow, toxManager: OCTManager, skipAuthorizationChallenge: Bool) {
        self.theme = theme
        self.window = window
        self.toxManager = toxManager
        self.pinAuthorizationCoordinator = PinAuthorizationCoordinator(theme: theme,
                                                                       submanagerObjects: toxManager.objects,
                                                                       lockOnStartup: !skipAuthorizationChallenge)
    }
}

extension RunningCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        self.options = options

        activeSessionCoordinator = ActiveSessionCoordinator(theme: theme, window: window, toxManager: toxManager)
        activeSessionCoordinator?.delegate = self
        activeSessionCoordinator?.startWithOptions(options)

        pinAuthorizationCoordinator.startWithOptions(nil)
    }

    func handleLocalNotification(notification: UILocalNotification) {
        activeSessionCoordinator?.handleLocalNotification(notification)
    }

    func handleInboxURL(url: NSURL) {
        activeSessionCoordinator?.handleInboxURL(url)
    }
}

extension RunningCoordinator: ActiveSessionCoordinatorDelegate {
    func activeSessionCoordinatorDidLogout(coordinator: ActiveSessionCoordinator, importToxProfileFromURL url: NSURL?) {
        let keychainManager = KeychainManager()
        keychainManager.deleteActiveAccountData()

        delegate?.runningCoordinatorDidLogout(self, importToxProfileFromURL: url)
    }

    func activeSessionCoordinatorDeleteProfile(coordinator: ActiveSessionCoordinator) {
        delegate?.runningCoordinatorDeleteProfile(self)
    }

    func activeSessionCoordinatorRecreateCoordinatorsStack(coordinator: ActiveSessionCoordinator, options: CoordinatorOptions) {
        delegate?.runningCoordinatorRecreateCoordinatorsStack(self, options: options)
    }
}

private extension RunningCoordinator {
}
