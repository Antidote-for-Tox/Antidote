//
//  NotificationCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 18/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class NotificationCoordinator {
    private let theme: Theme

    private let notificationWindow: NotificationWindow

    init(theme: Theme) {
        self.theme = theme
        self.notificationWindow = NotificationWindow(theme: theme)
    }

    func toggleConnectingView(show show: Bool, animated: Bool) {
        notificationWindow.showConnectingView(show, animated: animated)
    }
}

extension NotificationCoordinator: CoordinatorProtocol {
    func start() {
        // nop
    }
}
