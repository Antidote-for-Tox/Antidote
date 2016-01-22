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
    func settingsMainControllerShowBetaTesterMenu(controller: SettingsMainController)
    func settingsMainControllerShowAdvancedSettings(controller: SettingsMainController)
}

class SettingsMainController: StaticTableController {
    weak var delegate: SettingsMainControllerDelegate?

    private let theme: Theme

    private let aboutModel = StaticTableDefaultCellModel()
    private let betaTesterMenuModel = StaticTableDefaultCellModel()
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
                notificationsModel,
            ],
            [
                advancedSettingsModel,
            ],
            [
                betaTesterMenuModel,
                feedbackModel,
            ],
        ], footers: [
            nil,
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

        betaTesterMenuModel.value = String(localized: "settings_beta_tester_menu")
        betaTesterMenuModel.didSelectHandler = showBetaTesterMenu

        notificationsModel.title = String(localized: "settings_notifications_message_preview")
        notificationsModel.on = true
        notificationsModel.valueChangedHandler = notificationsValueChanged

        advancedSettingsModel.value = String(localized: "settings_advanced_settings")
        advancedSettingsModel.didSelectHandler = showAdvancedSettings

        feedbackModel.title = String(localized: "settings_feedback")
        feedbackModel.didSelectHandler = feedback
    }

    func showAboutScreen() {
        delegate?.settingsMainControllerShowAboutScreen(self)
    }

    func showBetaTesterMenu() {
        delegate?.settingsMainControllerShowBetaTesterMenu(self)
    }

    func notificationsValueChanged(on: Bool) {
        print("changed \(on)")
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
