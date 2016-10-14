// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol ChatsTabCoordinatorDelegate: class {
    func chatsTabCoordinator(coordinator: ChatsTabCoordinator, chatWillAppear chat: OCTChat)
    func chatsTabCoordinator(coordinator: ChatsTabCoordinator, chatWillDisapper chat: OCTChat)
    func chatsTabCoordinator(coordinator: ChatsTabCoordinator, callToChat chat: OCTChat, enableVideo: Bool)
}

class ChatsTabCoordinator: ActiveSessionNavigationCoordinator {
    weak var delegate: ChatsTabCoordinatorDelegate?

    private weak var submanagerObjects: OCTSubmanagerObjects!
    private weak var submanagerChats: OCTSubmanagerChats!
    private weak var submanagerFiles: OCTSubmanagerFiles!

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects, submanagerChats: OCTSubmanagerChats, submanagerFiles: OCTSubmanagerFiles) {
        self.submanagerObjects = submanagerObjects
        self.submanagerChats = submanagerChats
        self.submanagerFiles = submanagerFiles

        super.init(theme: theme)
    }

    override func startWithOptions(options: CoordinatorOptions?) {
        let controller = ChatListController(theme: theme, submanagerChats: submanagerChats, submanagerObjects: submanagerObjects)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)
    }

    func showChat(chat: OCTChat, animated: Bool) {
        if let top = navigationController.topViewController as? ChatPrivateController {
            if top.chat == chat {
                // controller is already visible
                return
            }
        }

        let controller = ChatPrivateController(
                theme: theme,
                chat: chat,
                submanagerChats: submanagerChats,
                submanagerObjects: submanagerObjects,
                submanagerFiles: submanagerFiles,
                delegate: self)

        navigationController.popToRootViewControllerAnimated(false)
        navigationController.pushViewController(controller, animated: animated)
    }

    /**
        Returns active chat controller if it is visible, nil otherwise.
     */
    func activeChatController() -> ChatPrivateController? {
        return navigationController.topViewController as? ChatPrivateController
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

    func chatPrivateControllerCallToChat(controller: ChatPrivateController, enableVideo: Bool) {
        delegate?.chatsTabCoordinator(self, callToChat: controller.chat, enableVideo: enableVideo)
    }

    func chatPrivateControllerShowQuickLookController(
            controller: ChatPrivateController,
            dataSource: QuickLookPreviewControllerDataSource,
            selectedIndex: Int)
    {
        let controller = QuickLookPreviewController()
        controller.dataSource = dataSource
        controller.dataSourceStorage = dataSource
        controller.currentPreviewItemIndex = selectedIndex

        navigationController.presentViewController(controller, animated: true, completion: nil)
    }
}
