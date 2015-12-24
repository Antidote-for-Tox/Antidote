//
//  FriendCardController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 24/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

protocol FriendCardControllerDelegate: class {
    func friendCardControllerChangeNickname(controller: FriendCardController)
}

class FriendCardController: StaticTableController {
    weak var delegate: FriendCardControllerDelegate?

    let friend: OCTFriend

    private let avatarManager: AvatarManager
    private let friendController: RBQFetchedResultsController

    private let avatarModel: StaticTableAvatarCellModel
    private let nicknameModel: StaticTableDefaultCellModel
    private let nameModel: StaticTableDefaultCellModel
    private let statusMessageModel: StaticTableDefaultCellModel
    private let publicKeyModel: StaticTableDefaultCellModel

    init(theme: Theme, friend: OCTFriend, submanagerObjects: OCTSubmanagerObjects) {
        self.friend = friend

        self.avatarManager = AvatarManager(theme: theme)

        let predicate = NSPredicate(format: "uniqueIdentifier == %@", friend.uniqueIdentifier)
        friendController = submanagerObjects.fetchedResultsControllerForType(.Friend, predicate: predicate)

        avatarModel = StaticTableAvatarCellModel()
        nicknameModel = StaticTableDefaultCellModel()
        nameModel = StaticTableDefaultCellModel()
        statusMessageModel = StaticTableDefaultCellModel()
        publicKeyModel = StaticTableDefaultCellModel()

        super.init(theme: theme, model: [
            [
                avatarModel,
            ],
            [
                nicknameModel,
                nameModel,
                statusMessageModel,
            ],
            [
                publicKeyModel,
            ],
        ])

        friendController.delegate = self
        updateModels()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FriendCardController: RBQFetchedResultsControllerDelegate {
    func controllerDidChangeContent(controller: RBQFetchedResultsController) {
        updateModels()
        reloadTableView()
    }
}

private extension FriendCardController {
    func updateModels() {
        title = friend.nickname

        avatarModel.avatar = avatarManager.avatarFromString(
                friend.nickname,
                diameter: StaticTableAvatarCellModel.Constants.AvatarImageSize)
        avatarModel.userInteractionEnabled = false

        nicknameModel.title = String(localized: "nickname")
        nicknameModel.value = friend.nickname
        nicknameModel.showArrow = true
        nicknameModel.didSelectHandler = changeNickname

        nameModel.title = String(localized: "name")
        nameModel.value = friend.name
        nameModel.showArrow = false
        nameModel.userInteractionEnabled = false

        statusMessageModel.title = String(localized: "status_message")
        statusMessageModel.value = friend.statusMessage
        statusMessageModel.showArrow = false
        statusMessageModel.userInteractionEnabled = false

        publicKeyModel.title = String(localized: "public_key")
        publicKeyModel.value = friend.publicKey
        publicKeyModel.showArrow = false
        publicKeyModel.userInteractionEnabled = false
    }

    func changeNickname() {
        delegate?.friendCardControllerChangeNickname(self)
    }
}
