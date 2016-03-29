//
//  TopCoordinatorProtocol.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 29.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

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
          - resultBlock: call block with true in case if URL was handled, with false otherwise.

        - Returns: true if coordinator did handle url, false otherwise.
     */
    func handleOpenURL(url: NSURL, resultBlock: Bool -> Void)
}

extension TopCoordinatorProtocol {
    func handleLocalNotification(notification: UILocalNotification) -> Bool {
        return false
    }

    func handleOpenURL(url: NSURL, resultBlock: Bool -> Void) {
        resultBlock(false)
    }
}
