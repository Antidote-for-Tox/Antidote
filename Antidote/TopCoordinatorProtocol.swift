//
//  TopCoordinatorProtocol.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 29.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class OpenURL{
    /// URL to open.
    let url: NSURL

    /// Ask user before opening url or not.
    let askUser: Bool

    init(url: NSURL, askUser: Bool) {
        self.url = url
        self.askUser = askUser
    }
}

enum HandleURLResult {
    case Success
    case Failure(openURL: OpenURL)
}

protocol TopCoordinatorProtocol: CoordinatorProtocol {
    /**
        Handle local notification.

        - Parameters:
          - notification: Notification to handle

        - Returns: true if coordinator did handle url, false otherwise.
     */
    func handleLocalNotification(notification: UILocalNotification) -> Bool

    /**
        Handle openURL request.

        - Parameters:
          - url: URL to handle.
          - resultBlock:
            - result: true in case if url was handled, false otherwise.
            - url: url to handle. Coordinator may update initial url if needed.
     */
    func handleOpenURL(openURL: OpenURL, resultBlock: HandleURLResult -> Void)
}

extension TopCoordinatorProtocol {
    func handleLocalNotification(notification: UILocalNotification) -> Bool {
        return false
    }

    func handleOpenURL(openURL: OpenURL, resultBlock: HandleURLResult -> Void) {
        resultBlock(.Failure(openURL: openURL))
    }
}
