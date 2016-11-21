// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol ChangeUserStatusControllerDelegate: class {
    func changeUserStatusController(_ controller: ChangeUserStatusController, selectedStatus: OCTToxUserStatus)
}

class ChangeUserStatusController: StaticTableController {
    weak var delegate: ChangeUserStatusControllerDelegate?

    fileprivate let selectedStatus: OCTToxUserStatus

    fileprivate let onlineModel = StaticTableDefaultCellModel()
    fileprivate let awayModel = StaticTableDefaultCellModel()
    fileprivate let busyModel = StaticTableDefaultCellModel()

    init(theme: Theme, selectedStatus: OCTToxUserStatus) {
        self.selectedStatus = selectedStatus

        super.init(theme: theme, style: .plain, model: [
            [
                onlineModel,
                awayModel,
                busyModel,
            ],
        ])

        updateModels()

        title = String(localized: "status_title")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChangeUserStatusController {
    func updateModels() {
        // Hardcoding any connected status to show only online/away/busy statuses here.
        let online = UserStatus(connectionStatus: OCTToxConnectionStatus.TCP, userStatus: OCTToxUserStatus.none)
        let away = UserStatus(connectionStatus: OCTToxConnectionStatus.TCP, userStatus: OCTToxUserStatus.away)
        let busy = UserStatus(connectionStatus: OCTToxConnectionStatus.TCP, userStatus: OCTToxUserStatus.busy)

        onlineModel.userStatus = online
        onlineModel.value = online.toString()
        onlineModel.didSelectHandler = changeOnlineStatus

        awayModel.userStatus = away
        awayModel.value = away.toString()
        awayModel.didSelectHandler = changeAwayStatus

        busyModel.userStatus = busy
        busyModel.value = busy.toString()
        busyModel.didSelectHandler = changeBusyStatus

        switch selectedStatus {
            case .none:
                onlineModel.rightImageType = .checkmark
            case .away:
                awayModel.rightImageType = .checkmark
            case .busy:
                busyModel.rightImageType = .checkmark
        }
    }

    func changeOnlineStatus(_: StaticTableBaseCell) {
        delegate?.changeUserStatusController(self, selectedStatus: .none)
    }

    func changeAwayStatus(_: StaticTableBaseCell) {
        delegate?.changeUserStatusController(self, selectedStatus: .away)
    }

    func changeBusyStatus(_: StaticTableBaseCell) {
        delegate?.changeUserStatusController(self, selectedStatus: .busy)
    }
}
