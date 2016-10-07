//
//  SettingsMainController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

protocol SettingsMainControllerDelegate: class {
    func settingsMainControllerShowAboutScreen(controller: SettingsMainController)
    func settingsMainControllerShowFaqScreen(controller: SettingsMainController)
    func settingsMainControllerShowAdvancedSettings(controller: SettingsMainController)
    func settingsMainControllerChangeAutodownloadImages(controller: SettingsMainController)
}

class SettingsMainController: StaticTableController {
    weak var delegate: SettingsMainControllerDelegate?

    private let theme: Theme
    private let userDefaults = UserDefaultsManager()

    private let aboutModel = StaticTableDefaultCellModel()
    private let faqModel = StaticTableDefaultCellModel()
    private let autodownloadImagesModel = StaticTableInfoCellModel()
    private let notificationsModel = StaticTableSwitchCellModel()
    private let advancedSettingsModel = StaticTableDefaultCellModel()

    init(theme: Theme) {
        self.theme = theme

        super.init(theme: theme, style: .Grouped, model: [
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateModels()
        reloadTableView()
    }
}

private extension SettingsMainController{
    func updateModels() {
        aboutModel.value = String(localized: "settings_about")
        aboutModel.didSelectHandler = showAboutScreen
        aboutModel.rightImageType = .Arrow

        faqModel.value = String(localized: "settings_faq")
        faqModel.didSelectHandler = showFaqScreen
        faqModel.rightImageType = .Arrow

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
        advancedSettingsModel.rightImageType = .Arrow
    }

    func showAboutScreen(_: StaticTableBaseCell) {
        delegate?.settingsMainControllerShowAboutScreen(self)
    }

    func showFaqScreen(_: StaticTableBaseCell) {
        delegate?.settingsMainControllerShowFaqScreen(self)
    }

    func notificationsValueChanged(on: Bool) {
        userDefaults.showNotificationPreview = on
    }

    func changeAutodownloadImages(_: StaticTableBaseCell) {
        delegate?.settingsMainControllerChangeAutodownloadImages(self)
    }

    func showAdvancedSettings(_: StaticTableBaseCell) {
        delegate?.settingsMainControllerShowAdvancedSettings(self)
    }
}
