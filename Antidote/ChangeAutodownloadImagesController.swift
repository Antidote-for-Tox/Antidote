// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol ChangeAutodownloadImagesControllerDelegate: class {
    func changeAutodownloadImagesControllerDidChange(controller: ChangeAutodownloadImagesController)
}

class ChangeAutodownloadImagesController: StaticTableController {
    weak var delegate: ChangeAutodownloadImagesControllerDelegate?

    private let userDefaults: UserDefaultsManager
    private let selectedStatus: UserDefaultsManager.AutodownloadImages

    private let neverModel = StaticTableDefaultCellModel()
    private let wifiModel = StaticTableDefaultCellModel()
    private let alwaysModel = StaticTableDefaultCellModel()

    init(theme: Theme) {
        self.userDefaults = UserDefaultsManager()
        self.selectedStatus = userDefaults.autodownloadImages

        super.init(theme: theme, style: .Plain, model: [
            [
                neverModel,
                wifiModel,
                alwaysModel,
            ],
        ])

        updateModels()

        title = String(localized: "settings_autodownload_images")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ChangeAutodownloadImagesController {
    func updateModels() {
        neverModel.value = String(localized: "settings_never")
        neverModel.didSelectHandler = changeNever

        wifiModel.value = String(localized: "settings_using_wifi")
        wifiModel.didSelectHandler = changeUsingWifi

        alwaysModel.value = String(localized: "settings_always")
        alwaysModel.didSelectHandler = changeAlways

        switch selectedStatus {
            case .Never:
                neverModel.rightImageType = .Checkmark
            case .UsingWiFi:
                wifiModel.rightImageType = .Checkmark
            case .Always:
                alwaysModel.rightImageType = .Checkmark
        }
    }

    func changeNever(_: StaticTableBaseCell) {
        userDefaults.autodownloadImages = .Never
        delegate?.changeAutodownloadImagesControllerDidChange(self)
    }

    func changeUsingWifi(_: StaticTableBaseCell) {
        userDefaults.autodownloadImages = .UsingWiFi
        delegate?.changeAutodownloadImagesControllerDidChange(self)
    }

    func changeAlways(_: StaticTableBaseCell) {
        userDefaults.autodownloadImages = .Always
        delegate?.changeAutodownloadImagesControllerDidChange(self)
    }
}
