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
     */
    func handleLocalNotification(notification: UILocalNotification)

    /**
        Handle openURL request.

        - Parameters:
          - url: URL to handle.
     */
    func handleInboxURL(url: NSURL)
}
