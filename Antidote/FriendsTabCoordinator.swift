//
//  FriendsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

class FriendsTabCoordinator: RunningBasicCoordinator {
    private let toxManager: OCTManager

    init(theme: Theme, toxManager: OCTManager) {
        self.toxManager = toxManager

        super.init(theme: theme)
    }

    override func start() {
        let controller = FriendListController(theme: theme, submanagerObjects: toxManager.objects, submanagerFriends: toxManager.friends)

        navigationController.pushViewController(controller, animated: false)
    }
}
