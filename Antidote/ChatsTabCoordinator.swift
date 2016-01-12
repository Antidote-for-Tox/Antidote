//
//  ChatsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class ChatsTabCoordinator: RunningBasicCoordinator {
    private let submanagerObjects: OCTSubmanagerObjects

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.submanagerObjects = submanagerObjects

        super.init(theme: theme)
    }

    override func start() {
        let controller = ChatListController(theme: theme, submanagerObjects: submanagerObjects)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)
    }
}

extension ChatsTabCoordinator: ChatListControllerDelegate {
    func chatListController(controller: ChatListController, didSelectChat chat: OCTChat) {

    }
}
