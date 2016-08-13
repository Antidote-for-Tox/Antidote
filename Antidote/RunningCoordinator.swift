//
//  RunningCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol RunningCoordinatorDelegate: class {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator, importToxProfileFromURL: NSURL?)
    func runningCoordinatorDeleteProfile(coordinator: RunningCoordinator)
    func runningCoordinatorRecreateCoordinatorsStack(coordinator: RunningCoordinator, options: CoordinatorOptions)
}

class RunningCoordinator {
    private enum InfoObject {
        case ToxManager(manager: OCTManager)
        case ProfileName(name: String)
    }

    weak var delegate: RunningCoordinatorDelegate?

    private let theme: Theme
    private let window: UIWindow

    private var infoObject: InfoObject

//    private let authenticationCoordinator: AuthenticationCoordinator
    private var activeSessionCoordinator: ActiveSessionCoordinator?

    private init(theme: Theme, window: UIWindow, infoObject: InfoObject) {
        self.theme = theme
        self.window = window
        self.infoObject = infoObject
//        self.authenticationCoordinator = AuthenticationCoordinator()
    }

    convenience init(theme: Theme, window: UIWindow, toxManager: OCTManager) {
        self.init(theme: theme, window: window, infoObject: .ToxManager(manager: toxManager))
    }

    convenience init(theme: Theme, window: UIWindow, profileName: String) {
        self.init(theme: theme, window: window, infoObject: .ProfileName(name: profileName))
            // let path = ProfileManager().pathForProfileWithName(profile)
    }
}

extension RunningCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
//        authenticationCoordinator.startWithOptions(nil)

        switch infoObject {
            case .ToxManager(let manager):
                activeSessionCoordinator = ActiveSessionCoordinator(theme: theme, window: window, toxManager: manager)
                activeSessionCoordinator?.delegate = self
                activeSessionCoordinator?.startWithOptions(options)
            case .ProfileName(let name):
                print("profile \(name)")
        }
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
