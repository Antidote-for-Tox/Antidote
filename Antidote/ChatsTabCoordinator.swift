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
    private let submanagerChats: OCTSubmanagerChats

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerChats: OCTSubmanagerChats) {
        self.submanagerObjects = submanagerObjects
        self.submanagerChats = submanagerChats

        super.init(theme: theme)
    }

    override func start() {
        let controller = ChatListController(theme: theme, submanagerObjects: submanagerObjects)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)
    }

    func showChat(chat: OCTChat, animated: Bool) {
        let controller = ChatPrivateController(
                theme: theme,
                chat: chat,
                submanagerChats: submanagerChats,
                submanagerObjects: submanagerObjects)

        navigationController.popToRootViewControllerAnimated(false)
        navigationController.pushViewController(controller, animated: animated)
    }
}

extension ChatsTabCoordinator: ChatListControllerDelegate {
    func chatListController(controller: ChatListController, didSelectChat chat: OCTChat) {
        showChat(chat, animated: true)
    }
}
