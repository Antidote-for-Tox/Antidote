//
//  ActiveSessionCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 08/08/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class ActiveSessionCoordinator {
    private var runningCoordinator: RunningCoordinator?
}

extension ActiveSessionCoordinator: TopCoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
    }

    func handleLocalNotification(notification: UILocalNotification) {
        // if let runningCoordinator = runningCoordinator {
        //     runningCoordinator.handleLocalNotification
        // }

        // cachedLocalNotification = notification
        // return true
    }

    func handleInboxURL(url: NSURL) {
        // cachedOpenURL = nil
    }
}
