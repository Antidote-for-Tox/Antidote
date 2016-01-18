//
//  FriendsTabCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation
import Cent

protocol FriendsTabCoordinatorDelegate: class {
    func friendsTabCoordinatorOpenChat(coordinator: FriendsTabCoordinator, forFriend friend: OCTFriend)
    func friendsTabCoordinatorCall(coordinator: FriendsTabCoordinator, toFriend friend: OCTFriend)
    func friendsTabCoordinatorVideoCall(coordinator: FriendsTabCoordinator, toFriend friend: OCTFriend)
}

class FriendsTabCoordinator: RunningNavigationCoordinator {
    weak var delegate: FriendsTabCoordinatorDelegate?

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
        delegate?.friendsTabCoordinatorOpenChat(self, forFriend: friend)
    }

    func friendCardControllerCall(controller: FriendCardController, toFriend friend: OCTFriend) {
        delegate?.friendsTabCoordinatorCall(self, toFriend: friend)
    }

    func friendCardControllerVideoCall(controller: FriendCardController, toFriend friend: OCTFriend) {
        delegate?.friendsTabCoordinatorVideoCall(self, toFriend: friend)
    }
}

extension FriendsTabCoordinator: AddFriendControllerDelegate {
    func addFriendControllerScanQRCode(
            controller: AddFriendController,
            validateCodeHandler: String -> Bool,
            didScanHander: String -> Void) {

        let scanner = QRScannerController(theme: theme)

        scanner.didScanStringsBlock = { [unowned self, scanner] in
            let qrCode = $0.filter { validateCodeHandler($0) }.first

            if let code = qrCode {
                didScanHander(code)
                self.navigationController.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                scanner.pauseScanning = true

                let title = String(localized:"error_title")
                let message = String(localized:"add_friend_wrong_qr")
                let button = String(localized:"error_ok_button")

                let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)

                alert.addAction(UIAlertAction(title: button, style: .Default) { [unowned scanner ] _ -> Void in
                    scanner.pauseScanning = false
                })

                scanner.presentViewController(alert, animated: true, completion: nil)
            }
        }

        scanner.cancelBlock = { [unowned self] in
            self.navigationController.dismissViewControllerAnimated(true, completion: nil)
        }

        let scannerNavCon = UINavigationController(rootViewController: scanner)
        navigationController.presentViewController(scannerNavCon, animated: true, completion: nil)
    }

    func addFriendControllerDidFinish(controller: AddFriendController) {
        navigationController.popViewControllerAnimated(true)
    }
}
