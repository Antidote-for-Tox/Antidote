//
//  SettingsAdvancedController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol SettingsAdvancedControllerDelegate: class {
    func settingsAdvancedControllerToxOptionsChanged(controller: SettingsAdvancedController)
}

class SettingsAdvancedController: StaticTableController {
    weak var delegate: SettingsAdvancedControllerDelegate?

    private let theme: Theme
    private let userDefaults = UserDefaultsManager()

    private let IPv6Model = StaticTableSwitchCellModel()
    private let UDPModel = StaticTableSwitchCellModel()
    private let restoreDefaultsModel = StaticTableButtonCellModel()

    init(theme: Theme) {
        self.theme = theme

        super.init(theme: theme, style: .Grouped, model: [
            [
                IPv6Model,
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
        IPv6Model.title = String(localized: "settings_ipv6_enabled")
        IPv6Model.on = userDefaults.IPv6Enabled
        IPv6Model.valueChangedHandler = IPv6Changed

        UDPModel.title = String(localized: "settings_udp_enabled")
        UDPModel.on = userDefaults.UDPEnabled
        UDPModel.valueChangedHandler = UDPChanged

        restoreDefaultsModel.title = String(localized: "settings_restore_default")
        restoreDefaultsModel.didSelectHandler = restoreDefaultsSettings
    }

    func IPv6Changed(on: Bool) {
        userDefaults.IPv6Enabled = on
        delegate?.settingsAdvancedControllerToxOptionsChanged(self)
    }

    func UDPChanged(on: Bool) {
        userDefaults.UDPEnabled = on
        delegate?.settingsAdvancedControllerToxOptionsChanged(self)
    }

    func restoreDefaultsSettings(_: StaticTableBaseCell) {
        userDefaults.resetIPv6Enabled()
        userDefaults.resetUDPEnabled()
        delegate?.settingsAdvancedControllerToxOptionsChanged(self)
    }
}
