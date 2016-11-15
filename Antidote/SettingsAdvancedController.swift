// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol SettingsAdvancedControllerDelegate: class {
    func settingsAdvancedControllerToxOptionsChanged(_ controller: SettingsAdvancedController)
}

class SettingsAdvancedController: StaticTableController {
    weak var delegate: SettingsAdvancedControllerDelegate?

    fileprivate let theme: Theme
    fileprivate let userDefaults = UserDefaultsManager()

    fileprivate let UDPModel = StaticTableSwitchCellModel()
    fileprivate let restoreDefaultsModel = StaticTableButtonCellModel()

    init(theme: Theme) {
        self.theme = theme

        super.init(theme: theme, style: .grouped, model: [
            [
                UDPModel,
            ],
            [
                restoreDefaultsModel,
            ],
        ])

        title = String(localized: "settings_advanced_settings")
        updateModels()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SettingsAdvancedController {
    func updateModels() {
        UDPModel.title = String(localized: "settings_udp_enabled")
        UDPModel.on = userDefaults.UDPEnabled
        UDPModel.valueChangedHandler = UDPChanged

        restoreDefaultsModel.title = String(localized: "settings_restore_default")
        restoreDefaultsModel.didSelectHandler = restoreDefaultsSettings
    }

    func UDPChanged(_ on: Bool) {
        userDefaults.UDPEnabled = on
        delegate?.settingsAdvancedControllerToxOptionsChanged(self)
    }

    func restoreDefaultsSettings(_: StaticTableBaseCell) {
        userDefaults.resetUDPEnabled()
        delegate?.settingsAdvancedControllerToxOptionsChanged(self)
    }
}
