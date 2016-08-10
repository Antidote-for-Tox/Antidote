//
//  ActiveSessionCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol ActiveSessionCoordinatorDelegate: class {
    func activeSessionCoordinatorDidLogout(coordinator: ActiveSessionCoordinator, importToxProfileFromURL: NSURL?)
    func activeSessionCoordinatorDeleteProfile(coordinator: ActiveSessionCoordinator)
    func activeSessionCoordinatorRecreateCoordinatorsStack(coordinator: ActiveSessionCoordinator, options: CoordinatorOptions)
}

class ActiveSessionCoordinator {
    private enum InfoObject {
        case ToxManager(manager: OCTManager)
        case ProfileName(name: String)
    }

    weak var delegate: ActiveSessionCoordinatorDelegate?

    private let theme: Theme
    private let window: UIWindow

    private var infoObject: InfoObject

//    private let authenticationCoordinator: AuthenticationCoordinator
    private var runningCoordinator: RunningCoordinator?

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

extension ActiveSessionCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
//        authenticationCoordinator.startWithOptions(nil)

        switch infoObject {
            case .ToxManager(let manager):
                runningCoordinator = RunningCoordinator(theme: theme, window: window, toxManager: manager)
                runningCoordinator?.delegate = self
                runningCoordinator?.startWithOptions(options)
            case .ProfileName(let name):
                print("profile \(name)")
        }
    }

    func handleLocalNotification(notification: UILocalNotification) {
        runningCoordinator?.handleLocalNotification(notification)
    }

    func handleInboxURL(url: NSURL) {
        runningCoordinator?.handleInboxURL(url)
    }
}

extension ActiveSessionCoordinator: RunningCoordinatorDelegate {
    func runningCoordinatorDidLogout(coordinator: RunningCoordinator, importToxProfileFromURL url: NSURL?) {
        delegate?.activeSessionCoordinatorDidLogout(self, importToxProfileFromURL: url)
    }

    func runningCoordinatorDeleteProfile(coordinator: RunningCoordinator) {
        delegate?.activeSessionCoordinatorDeleteProfile(self)
    }

    func runningCoordinatorRecreateCoordinatorsStack(coordinator: RunningCoordinator, options: CoordinatorOptions) {
        delegate?.activeSessionCoordinatorRecreateCoordinatorsStack(self, options: options)
    }
}

private extension ActiveSessionCoordinator {
}
