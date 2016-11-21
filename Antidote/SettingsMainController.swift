// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol SettingsMainControllerDelegate: class {
    func settingsMainControllerShowAboutScreen(_ controller: SettingsMainController)
    func settingsMainControllerShowFaqScreen(_ controller: SettingsMainController)
    func settingsMainControllerShowAdvancedSettings(_ controller: SettingsMainController)
    func settingsMainControllerChangeAutodownloadImages(_ controller: SettingsMainController)
}

class SettingsMainController: StaticTableController {
    weak var delegate: SettingsMainControllerDelegate?

    fileprivate let theme: Theme
    fileprivate let userDefaults = UserDefaultsManager()

    fileprivate let aboutModel = StaticTableDefaultCellModel()
    fileprivate let faqModel = StaticTableDefaultCellModel()
    fileprivate let autodownloadImagesModel = StaticTableInfoCellModel()
    fileprivate let notificationsModel = StaticTableSwitchCellModel()
    fileprivate let advancedSettingsModel = StaticTableDefaultCellModel()

    init(theme: Theme) {
        self.theme = theme

        super.init(theme: theme, style: .grouped, model: [
            [
                autodownloadImagesModel,
            ],
            [
                notificationsModel,
            ],
            [
                advancedSettingsModel,
            ],
            [
                faqModel,
                aboutModel,
            ],
        ], footers: [
            String(localized: "settings_autodownload_images_description"),
            String(localized: "settings_notifications_description"),
            nil,
            nil,
        ])

        title = String(localized: "settings_title")
        updateModels()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateModels()
        reloadTableView()
    }
}

private extension SettingsMainController{
    func updateModels() {
        aboutModel.value = String(localized: "settings_about")
        aboutModel.didSelectHandler = showAboutScreen
        aboutModel.rightImageType = .arrow

        faqModel.value = String(localized: "settings_faq")
        faqModel.didSelectHandler = showFaqScreen
        faqModel.rightImageType = .arrow

        autodownloadImagesModel.title = String(localized: "settings_autodownload_images")
        autodownloadImagesModel.showArrow = true
        autodownloadImagesModel.didSelectHandler = changeAutodownloadImages
        switch userDefaults.autodownloadImages {
            case .Never:
                autodownloadImagesModel.value = String(localized: "settings_never")
            case .UsingWiFi:
                autodownloadImagesModel.value = String(localized: "settings_wifi")
            case .Always:
                autodownloadImagesModel.value = String(localized: "settings_always")
        }

        notificationsModel.title = String(localized: "settings_notifications_message_preview")
        notificationsModel.on = userDefaults.showNotificationPreview
        notificationsModel.valueChangedHandler = notificationsValueChanged

        advancedSettingsModel.value = String(localized: "settings_advanced_settings")
        advancedSettingsModel.didSelectHandler = showAdvancedSettings
        advancedSettingsModel.rightImageType = .arrow
    }

    func showAboutScreen(_: StaticTableBaseCell) {
        delegate?.settingsMainControllerShowAboutScreen(self)
    }

    func showFaqScreen(_: StaticTableBaseCell) {
        delegate?.settingsMainControllerShowFaqScreen(self)
    }

    func notificationsValueChanged(_ on: Bool) {
        userDefaults.showNotificationPreview = on
    }

    func changeAutodownloadImages(_: StaticTableBaseCell) {
        delegate?.settingsMainControllerChangeAutodownloadImages(self)
    }

    func showAdvancedSettings(_: StaticTableBaseCell) {
        delegate?.settingsMainControllerShowAdvancedSettings(self)
    }
}
