// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol FriendRequestControllerDelegate: class {
    func friendRequestControllerDidFinish(controller: FriendRequestController)
}

class FriendRequestController: StaticTableController {
    weak var delegate: FriendRequestControllerDelegate?

    private let request: OCTFriendRequest

    private weak var submanagerFriends: OCTSubmanagerFriends!

    private let publicKeyModel: StaticTableDefaultCellModel
    private let messageModel: StaticTableDefaultCellModel
    private let buttonsModel: StaticTableMultiChoiceButtonCellModel

    init(theme: Theme, request: OCTFriendRequest, submanagerFriends: OCTSubmanagerFriends) {
        self.request = request

        self.submanagerFriends = submanagerFriends

        publicKeyModel = StaticTableDefaultCellModel()
        messageModel = StaticTableDefaultCellModel()
        buttonsModel = StaticTableMultiChoiceButtonCellModel()

        super.init(theme: theme, style: .Plain, model: [
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
            StaticTableMultiChoiceButtonCellModel.ButtonModel(title: String(localized: "contact_request_decline"), style: .Negative, target: self, action: #selector(FriendRequestController.declineButtonPressed)),
            StaticTableMultiChoiceButtonCellModel.ButtonModel(title: String(localized: "contact_request_accept"), style: .Positive, target: self, action: #selector(FriendRequestController.acceptButtonPressed)),
        ]
    }
}

extension FriendRequestController {
    func declineButtonPressed() {
        let alert = UIAlertController(title: String(localized: "contact_request_delete_title"), message: nil, preferredStyle: .Alert)

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: String(localized: "alert_delete"), style: .Destructive) { [unowned self] _ -> Void in
            self.submanagerFriends.removeFriendRequest(self.request)
            self.delegate?.friendRequestControllerDidFinish(self)
        })

        presentViewController(alert, animated: true, completion: nil)
    }

    func acceptButtonPressed() {
        do {
            try submanagerFriends.approveFriendRequest(request)
            delegate?.friendRequestControllerDidFinish(self)
        }
        catch let error as NSError {
            handleErrorWithType(.ToxAddFriend, error: error)
        }
    }
}
