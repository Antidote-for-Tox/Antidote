//
//  ChatsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

protocol ChatsTabCoordinatorDelegate: class {
    func chatsTabCoordinator(coordinator: ChatsTabCoordinator, chatWillAppear chat: OCTChat)
    func chatsTabCoordinator(coordinator: ChatsTabCoordinator, chatWillDisapper chat: OCTChat)
}

class ChatsTabCoordinator: RunningNavigationCoordinator {
    weak var delegate: ChatsTabCoordinatorDelegate?

    private weak var submanagerObjects: OCTSubmanagerObjects!
    private weak var submanagerChats: OCTSubmanagerChats!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerChats: OCTSubmanagerChats) {
        self.submanagerObjects = submanagerObjects
        self.submanagerChats = submanagerChats

        super.init(theme: theme)
    }

    override func startWithOptions(options: CoordinatorOptions?) {
        let controller = ChatListController(theme: theme, submanagerObjects: submanagerObjects)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)
    }

    func showChat(chat: OCTChat, animated: Bool) {
        let controller = ChatPrivateController(
                theme: theme,
                chat: chat,
                submanagerChats: submanagerChats,
                submanagerObjects: submanagerObjects,
                delegate: self)

        navigationController.popToRootViewControllerAnimated(false)
        navigationController.pushViewController(controller, animated: animated)
    }
}

extension ChatsTabCoordinator: ChatListControllerDelegate {
    func chatListController(controller: ChatListController, didSelectChat chat: OCTChat) {
        showChat(chat, animated: true)
    }
}

extension ChatsTabCoordinator: ChatPrivateControllerDelegate {
    func chatPrivateControllerWillAppear(controller: ChatPrivateController) {
        delegate?.chatsTabCoordinator(self, chatWillAppear: controller.chat)
    }

    func chatPrivateControllerWillDisappear(controller: ChatPrivateController) {
        delegate?.chatsTabCoordinator(self, chatWillDisapper: controller.chat)
    }
}
