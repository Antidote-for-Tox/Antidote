//
//  ChangeUserStatusController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 30.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

protocol ChangeUserStatusControllerDelegate: class {
    func changeUserStatusController(controller: ChangeUserStatusController, selectedStatus: OCTToxUserStatus)
}

class ChangeUserStatusController: StaticTableController {
    weak var delegate: ChangeUserStatusControllerDelegate?

    private let selectedStatus: OCTToxUserStatus

    private let onlineModel = StaticTableDefaultCellModel()
    private let awayModel = StaticTableDefaultCellModel()
    private let busyModel = StaticTableDefaultCellModel()

    init(theme: Theme, selectedStatus: OCTToxUserStatus) {
        self.selectedStatus = selectedStatus

        super.init(theme: theme, style: .Plain, model: [
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
        let online = UserStatus(connectionStatus: OCTToxConnectionStatus.TCP, userStatus: OCTToxUserStatus.None)
        let away = UserStatus(connectionStatus: OCTToxConnectionStatus.TCP, userStatus: OCTToxUserStatus.Away)
        let busy = UserStatus(connectionStatus: OCTToxConnectionStatus.TCP, userStatus: OCTToxUserStatus.Busy)

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
            case .None:
                onlineModel.rightImageType = .Checkmark
            case .Away:
                awayModel.rightImageType = .Checkmark
            case .Busy:
                busyModel.rightImageType = .Checkmark
        }
    }

    func changeOnlineStatus(_: StaticTableBaseCell) {
        delegate?.changeUserStatusController(self, selectedStatus: .None)
    }

    func changeAwayStatus(_: StaticTableBaseCell) {
        delegate?.changeUserStatusController(self, selectedStatus: .Away)
    }

    func changeBusyStatus(_: StaticTableBaseCell) {
        delegate?.changeUserStatusController(self, selectedStatus: .Busy)
    }
}
