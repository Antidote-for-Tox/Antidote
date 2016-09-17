//
//  ChangePinTimeoutController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 17/09/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

protocol ChangePinTimeoutControllerDelegate: class {
    func changePinTimeoutControllerDone(controller: ChangePinTimeoutController)
}

class ChangePinTimeoutController: StaticTableController {
    weak var delegate: ChangePinTimeoutControllerDelegate?

    private weak var submanagerObjects: OCTSubmanagerObjects!

    private let immediatelyModel = StaticTableDefaultCellModel()
    private let seconds30Model = StaticTableDefaultCellModel()
    private let minute1Model = StaticTableDefaultCellModel()
    private let minute2Model = StaticTableDefaultCellModel()
    private let minute5Model = StaticTableDefaultCellModel()

    init(theme: Theme, submanagerObjects: OCTSubmanagerObjects) {
        self.submanagerObjects = submanagerObjects

        super.init(theme: theme, style: .Plain, model: [
            [
                immediatelyModel,
                seconds30Model,
                minute1Model,
                minute2Model,
                minute5Model,
            ],
        ])

        updateModels()

        title = String(localized: "pin_lock_timeout")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChangePinTimeoutController {
    func updateModels() {
        let settings = submanagerObjects.getProfileSettings()

        immediatelyModel.value = String(localized: "pin_lock_immediately")
        immediatelyModel.didSelectHandler = immediatelyHandler
        immediatelyModel.rightImageType = .None

        seconds30Model.value = String(localized: "pin_lock_30_seconds")
        seconds30Model.didSelectHandler = seconds30Handler
        seconds30Model.rightImageType = .None

        minute1Model.value = String(localized: "pin_lock_1_minute")
        minute1Model.didSelectHandler = minute1Handler
        minute1Model.rightImageType = .None

        minute2Model.value = String(localized: "pin_lock_2_minutes")
        minute2Model.didSelectHandler = minute2Handler
        minute2Model.rightImageType = .None

        minute5Model.value = String(localized: "pin_lock_5_minutes")
        minute5Model.didSelectHandler = minute5Handler
        minute5Model.rightImageType = .None


        switch settings.lockTimeout {
            case .Immediately:
                immediatelyModel.rightImageType = .Checkmark
            case .Seconds30:
                seconds30Model.rightImageType = .Checkmark
            case .Minute1:
                minute1Model.rightImageType = .Checkmark
            case .Minute2:
                minute2Model.rightImageType = .Checkmark
            case .Minute5:
                minute5Model.rightImageType = .Checkmark
        }
    }

    func immediatelyHandler(_: StaticTableBaseCell) {
        selectedTimeout(.Immediately)
    }

    func seconds30Handler(_: StaticTableBaseCell) {
        selectedTimeout(.Seconds30)
    }

    func minute1Handler(_: StaticTableBaseCell) {
        selectedTimeout(.Minute1)
    }

    func minute2Handler(_: StaticTableBaseCell) {
        selectedTimeout(.Minute2)
    }

    func minute5Handler(_: StaticTableBaseCell) {
        selectedTimeout(.Minute5)
    }

    func selectedTimeout(timeout: ProfileSettings.LockTimeout) {
        let settings = submanagerObjects.getProfileSettings()
        settings.lockTimeout = timeout
        submanagerObjects.saveProfileSettings(settings)

        delegate?.changePinTimeoutControllerDone(self)
    }
}
