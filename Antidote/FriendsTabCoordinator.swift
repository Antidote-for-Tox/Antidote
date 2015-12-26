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
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)
    }
}

extension FriendsTabCoordinator: FriendListControllerDelegate {
    func friendListController(controller: FriendListController, didSelectFriend friend: OCTFriend) {
        let controller = FriendCardController(theme: theme, friend: friend, submanagerObjects: toxManager.objects)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }

    func friendListControllerAddFriend(controller: FriendListController) {
        let controller = AddFriendController(theme: theme, submanagerFriends: toxManager.friends)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }
}

extension FriendsTabCoordinator: FriendCardControllerDelegate {
    func friendCardControllerChangeNickname(controller: FriendCardController, forFriend friend: OCTFriend) {
        let title = String(localized: "nickname")
        let defaultValue = friend.nickname

        let textController = TextEditController(theme: theme, title: title, defaultValue: defaultValue) {
            [unowned self] newValue -> Void in

            self.toxManager.objects.changeFriend(friend, nickname: newValue)
            self.navigationController.popViewControllerAnimated(true)
        }

        navigationController.pushViewController(textController, animated: true)
    }

    func friendCardControllerOpenChat(controller: FriendCardController, forFriend friend: OCTFriend) {
        print("open chat")
    }

    func friendCardControllerCallFriend(controller: FriendCardController, forFriend friend: OCTFriend) {
        print("call")
    }

    func friendCardControllerVideoCallFriend(controller: FriendCardController, forFriend friend: OCTFriend) {
        print("video call")
    }
}

extension FriendsTabCoordinator: AddFriendControllerDelegate {
    func addFriendController(controller: AddFriendController, scanQRWithHandler: [String] -> Bool) {

    }

    func addFriendControllerDidFinish(controller: AddFriendController) {
        navigationController.popViewControllerAnimated(true)
    }
}
