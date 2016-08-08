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
    weak var delegate: ActiveSessionCoordinatorDelegate?

    private var runningCoordinator: RunningCoordinator

    init(theme: Theme, window: UIWindow, toxManager: OCTManager) {
        self.runningCoordinator = RunningCoordinator(theme: theme, window: window, toxManager: toxManager)

        runningCoordinator.delegate = self
    }
}

extension ActiveSessionCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
        runningCoordinator.startWithOptions(options)
    }

    func handleLocalNotification(notification: UILocalNotification) {
        runningCoordinator.handleLocalNotification(notification)
    }

    func handleInboxURL(url: NSURL) {
        runningCoordinator.handleInboxURL(url)
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
