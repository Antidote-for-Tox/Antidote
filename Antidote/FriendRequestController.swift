// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol FriendRequestControllerDelegate: class {
    func friendRequestControllerDidFinish(_ controller: FriendRequestController)
}

class FriendRequestController: StaticTableController {
    weak var delegate: FriendRequestControllerDelegate?

    fileprivate let request: OCTFriendRequest

    fileprivate weak var submanagerFriends: OCTSubmanagerFriends!

    fileprivate let publicKeyModel: StaticTableDefaultCellModel
    fileprivate let messageModel: StaticTableDefaultCellModel
    fileprivate let buttonsModel: StaticTableMultiChoiceButtonCellModel

    init(theme: Theme, request: OCTFriendRequest, submanagerFriends: OCTSubmanagerFriends) {
        self.request = request

        self.submanagerFriends = submanagerFriends

        publicKeyModel = StaticTableDefaultCellModel()
        messageModel = StaticTableDefaultCellModel()
        buttonsModel = StaticTableMultiChoiceButtonCellModel()

        super.init(theme: theme, style: .plain, model: [
            [
                publicKeyModel,
                messageModel,
            ],
            [
                buttonsModel,
            ],
        ])

        updateModels()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension FriendRequestController {
    func updateModels() {
        title = String(localized: "contact_request")

        publicKeyModel.title = String(localized: "public_key")
        publicKeyModel.value = request.publicKey
        publicKeyModel.userInteractionEnabled = false

        messageModel.title = String(localized: "status_message")
        messageModel.value = request.message
        messageModel.userInteractionEnabled = false

        buttonsModel.buttons = [
            StaticTableMultiChoiceButtonCellModel.ButtonModel(title: String(localized: "contact_request_decline"), style: .negative, target: self, action: #selector(FriendRequestController.declineButtonPressed)),
            StaticTableMultiChoiceButtonCellModel.ButtonModel(title: String(localized: "contact_request_accept"), style: .positive, target: self, action: #selector(FriendRequestController.acceptButtonPressed)),
        ]
    }
}

extension FriendRequestController {
    func declineButtonPressed() {
        let alert = UIAlertController(title: String(localized: "contact_request_delete_title"), message: nil, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: String(localized: "alert_delete"), style: .destructive) { [unowned self] _ -> Void in
            self.submanagerFriends.remove(self.request)
            self.delegate?.friendRequestControllerDidFinish(self)
        })

        present(alert, animated: true, completion: nil)
    }

    func acceptButtonPressed() {
        do {
            try submanagerFriends.approve(request)
            delegate?.friendRequestControllerDidFinish(self)
        }
        catch let error as NSError {
            handleErrorWithType(.toxAddFriend, error: error)
        }
    }
}
