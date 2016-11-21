// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol FriendsTabCoordinatorDelegate: class {
    func friendsTabCoordinatorOpenChat(_ coordinator: FriendsTabCoordinator, forFriend friend: OCTFriend)
    func friendsTabCoordinatorCall(_ coordinator: FriendsTabCoordinator, toFriend friend: OCTFriend)
    func friendsTabCoordinatorVideoCall(_ coordinator: FriendsTabCoordinator, toFriend friend: OCTFriend)
}

class FriendsTabCoordinator: ActiveSessionNavigationCoordinator {
    weak var delegate: FriendsTabCoordinatorDelegate?

    fileprivate weak var toxManager: OCTManager!

    init(theme: Theme, toxManager: OCTManager) {
        self.toxManager = toxManager

        super.init(theme: theme)
    }

    override func startWithOptions(_ options: CoordinatorOptions?) {
        let controller = FriendListController(theme: theme, submanagerObjects: toxManager.objects, submanagerFriends: toxManager.friends, submanagerChats: toxManager.chats, submanagerUser: toxManager.user)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: false)
    }

    func showRequest(_ request: OCTFriendRequest, animated: Bool) {
        navigationController.popToRootViewController(animated: false)

        let controller = FriendRequestController(theme: theme, request: request, submanagerFriends: toxManager.friends)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: animated)
    }
}

extension FriendsTabCoordinator: FriendListControllerDelegate {
    func friendListController(_ controller: FriendListController, didSelectFriend friend: OCTFriend) {
        let controller = FriendCardController(theme: theme, friend: friend, submanagerObjects: toxManager.objects)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }

    func friendListController(_ controller: FriendListController, didSelectRequest request: OCTFriendRequest) {
        showRequest(request, animated: true)
    }

    func friendListControllerAddFriend(_ controller: FriendListController) {
        let controller = AddFriendController(theme: theme, submanagerFriends: toxManager.friends)
        controller.delegate = self

        navigationController.pushViewController(controller, animated: true)
    }

    func friendListController(_ controller: FriendListController, showQRCodeWithText text: String) {
        let controller = QRViewerController(theme: theme, text: text)
        controller.delegate = self

        let toPresent = UINavigationController(rootViewController: controller)

        navigationController.present(toPresent, animated: true, completion: nil)
    }
}

extension FriendsTabCoordinator: QRViewerControllerDelegate {
    func qrViewerControllerDidFinishPresenting() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

extension FriendsTabCoordinator: FriendCardControllerDelegate {
    func friendCardControllerChangeNickname(_ controller: FriendCardController, forFriend friend: OCTFriend) {
        let title = String(localized: "nickname")
        let defaultValue = friend.nickname

        let textController = TextEditController(theme: theme, title: title, defaultValue: defaultValue, changeTextHandler: {
            [unowned self] newValue -> Void in
            self.toxManager.objects.change(friend, nickname: newValue)

        }, userFinishedEditing: { [unowned self] in
            self.navigationController.popViewController(animated: true)
        })

        navigationController.pushViewController(textController, animated: true)
    }

    func friendCardControllerOpenChat(_ controller: FriendCardController, forFriend friend: OCTFriend) {
        delegate?.friendsTabCoordinatorOpenChat(self, forFriend: friend)
    }

    func friendCardControllerCall(_ controller: FriendCardController, toFriend friend: OCTFriend) {
        delegate?.friendsTabCoordinatorCall(self, toFriend: friend)
    }

    func friendCardControllerVideoCall(_ controller: FriendCardController, toFriend friend: OCTFriend) {
        delegate?.friendsTabCoordinatorVideoCall(self, toFriend: friend)
    }
}

extension FriendsTabCoordinator: FriendRequestControllerDelegate {
    func friendRequestControllerDidFinish(_ controller: FriendRequestController) {
        navigationController.popViewController(animated: true)
    }
}

extension FriendsTabCoordinator: AddFriendControllerDelegate {
    func addFriendControllerScanQRCode(_ controller: AddFriendController,
                                       validateCodeHandler: @escaping (String) -> Bool,
                                       didScanHander: @escaping (String) -> Void) {
        let scanner = QRScannerController(theme: theme)

        scanner.didScanStringsBlock = { [unowned self, scanner] in
            let qrCode = $0.filter { validateCodeHandler($0) }.first

            if let code = qrCode {
                didScanHander(code)
                self.navigationController.dismiss(animated: true, completion: nil)
            }
            else {
                scanner.pauseScanning = true

                let title = String(localized:"error_title")
                let message = String(localized:"add_contact_wrong_qr")
                let button = String(localized:"error_ok_button")

                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: button, style: .default) { [unowned scanner ] _ -> Void in
                    scanner.pauseScanning = false
                })

                scanner.present(alert, animated: true, completion: nil)
            }
        }

        scanner.cancelBlock = { [unowned self] in
            self.navigationController.dismiss(animated: true, completion: nil)
        }

        let scannerNavCon = UINavigationController(rootViewController: scanner)
        navigationController.present(scannerNavCon, animated: true, completion: nil)
    }

    func addFriendControllerDidFinish(_ controller: AddFriendController) {
        navigationController.popViewController(animated: true)
    }
}
