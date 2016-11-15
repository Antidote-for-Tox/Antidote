// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol SettingsAboutControllerDelegate: class {
    func settingsAboutControllerShowAcknowledgements(_ controller: SettingsAboutController)
}

class SettingsAboutController: StaticTableController {
    weak var delegate: SettingsAboutControllerDelegate?

    fileprivate let antidoteVersionModel = StaticTableInfoCellModel()
    fileprivate let antidoteBuildModel = StaticTableInfoCellModel()
    fileprivate let toxcoreVersionModel = StaticTableInfoCellModel()
    fileprivate let acknowledgementsModel = StaticTableDefaultCellModel()

    init(theme: Theme) {
        super.init(theme: theme, style: .grouped, model: [
            [
                antidoteVersionModel,
                antidoteBuildModel,
            ],
            [
                toxcoreVersionModel,
            ],
            [
                acknowledgementsModel,
            ],
        ])

        title = String(localized: "settings_about")
        updateModels()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension SettingsAboutController {
    func updateModels() {
        antidoteVersionModel.title = String(localized: "settings_antidote_version")
        antidoteVersionModel.value =  Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

        antidoteBuildModel.title = String(localized: "settings_antidote_build")
        antidoteBuildModel.value = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        toxcoreVersionModel.title = String(localized: "settings_toxcore_version")
        toxcoreVersionModel.value = OCTTox.version()

        acknowledgementsModel.value = String(localized: "settings_acknowledgements")
        acknowledgementsModel.didSelectHandler = showAcknowledgements
        acknowledgementsModel.rightImageType = .arrow
    }

    func showAcknowledgements(_: StaticTableBaseCell) {
        delegate?.settingsAboutControllerShowAcknowledgements(self)
    }
}
