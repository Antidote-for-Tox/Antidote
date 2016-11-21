// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol RunningCoordinatorDelegate: class {
    func runningCoordinatorDidLogout(_ coordinator: RunningCoordinator, importToxProfileFromURL: URL?)
    func runningCoordinatorDeleteProfile(_ coordinator: RunningCoordinator)
    func runningCoordinatorRecreateCoordinatorsStack(_ coordinator: RunningCoordinator, options: CoordinatorOptions)
}

class RunningCoordinator {
    weak var delegate: RunningCoordinatorDelegate?

    fileprivate let theme: Theme
    fileprivate let window: UIWindow

    fileprivate var toxManager: OCTManager
    fileprivate var options: CoordinatorOptions?

    fileprivate var activeSessionCoordinator: ActiveSessionCoordinator?
    fileprivate var pinAuthorizationCoordinator: PinAuthorizationCoordinator

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
    func startWithOptions(_ options: CoordinatorOptions?) {
        self.options = options

        activeSessionCoordinator = ActiveSessionCoordinator(theme: theme, window: window, toxManager: toxManager)
        activeSessionCoordinator?.delegate = self
        activeSessionCoordinator?.startWithOptions(options)

        pinAuthorizationCoordinator.startWithOptions(nil)
    }

    func handleLocalNotification(_ notification: UILocalNotification) {
        activeSessionCoordinator?.handleLocalNotification(notification)
    }

    func handleInboxURL(_ url: URL) {
        activeSessionCoordinator?.handleInboxURL(url)
    }
}

extension RunningCoordinator: ActiveSessionCoordinatorDelegate {
    func activeSessionCoordinatorDidLogout(_ coordinator: ActiveSessionCoordinator, importToxProfileFromURL url: URL?) {
        let keychainManager = KeychainManager()
        keychainManager.deleteActiveAccountData()

        delegate?.runningCoordinatorDidLogout(self, importToxProfileFromURL: url)
    }

    func activeSessionCoordinatorDeleteProfile(_ coordinator: ActiveSessionCoordinator) {
        delegate?.runningCoordinatorDeleteProfile(self)
    }

    func activeSessionCoordinatorRecreateCoordinatorsStack(_ coordinator: ActiveSessionCoordinator, options: CoordinatorOptions) {
        delegate?.runningCoordinatorRecreateCoordinatorsStack(self, options: options)
    }

    func activeSessionCoordinatorDidStartCall(_ coordinator: ActiveSessionCoordinator) {
        pinAuthorizationCoordinator.preventFromLocking = true
    }

    func activeSessionCoordinatorDidFinishCall(_ coordinator: ActiveSessionCoordinator) {
        pinAuthorizationCoordinator.preventFromLocking = false
    }
}

private extension RunningCoordinator {
}
