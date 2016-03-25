//
//  SettingsMainController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation
import MessageUI

protocol SettingsMainControllerDelegate: class {
    func settingsMainControllerShowAboutScreen(controller: SettingsMainController)
    func settingsMainControllerShowAdvancedSettings(controller: SettingsMainController)
    func settingsMainControllerChangeAutodownloadImages(controller: SettingsMainController)
}

class SettingsMainController: StaticTableController {
    weak var delegate: SettingsMainControllerDelegate?

    private let theme: Theme
    private let userDefaults = UserDefaultsManager()

    private let aboutModel = StaticTableDefaultCellModel()
    private let autodownloadImagesModel = StaticTableInfoCellModel()
    private let notificationsModel = StaticTableSwitchCellModel()
    private let advancedSettingsModel = StaticTableDefaultCellModel()
    private let feedbackModel = StaticTableButtonCellModel()

    init(theme: Theme) {
        self.theme = theme

        super.init(theme: theme, style: .Grouped, model: [
            [
                aboutModel,
            ],
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
                feedbackModel,
            ],
        ], footers: [
            nil,
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

extension SettingsMainController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

private extension SettingsMainController{
    func updateModels() {
        aboutModel.value = String(localized: "settings_about")
        aboutModel.didSelectHandler = showAboutScreen
        aboutModel.rightImageType = .Arrow

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

        feedbackModel.title = String(localized: "settings_feedback")
        feedbackModel.didSelectHandler = feedback
    }

    func showAboutScreen() {
        delegate?.settingsMainControllerShowAboutScreen(self)
    }

    func notificationsValueChanged(on: Bool) {
        userDefaults.showNotificationPreview = on
    }

    func changeAutodownloadImages() {
        delegate?.settingsMainControllerChangeAutodownloadImages(self)
    }

    func showAdvancedSettings() {
        delegate?.settingsMainControllerShowAdvancedSettings(self)
    }

    func feedback() {
        guard MFMailComposeViewController.canSendMail() else {
            UIAlertView.showErrorWithMessage(String(localized: "settings_configure_email"))
            return
        }

        let controller = MFMailComposeViewController()
        controller.navigationBar.tintColor = theme.colorForType(.LinkText)
        controller.setSubject("Feedback")
        controller.setToRecipients(["feedback@antidote.im"])
        controller.mailComposeDelegate = self

        presentViewController(controller, animated: true, completion: nil)
    }
}
