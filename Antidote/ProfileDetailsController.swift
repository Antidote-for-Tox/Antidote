// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import LocalAuthentication

protocol ProfileDetailsControllerDelegate: class {
    func profileDetailsControllerSetPin(_ controller: ProfileDetailsController)
    func profileDetailsControllerChangeLockTimeout(_ controller: ProfileDetailsController)
    func profileDetailsControllerChangePassword(_ controller: ProfileDetailsController)
    func profileDetailsControllerDeleteProfile(_ controller: ProfileDetailsController)
}

class ProfileDetailsController: StaticTableController {
    weak var delegate: ProfileDetailsControllerDelegate?

    fileprivate weak var toxManager: OCTManager!

    fileprivate let pinEnabledModel = StaticTableSwitchCellModel()
    fileprivate let lockTimeoutModel = StaticTableInfoCellModel()
    fileprivate let touchIdEnabledModel = StaticTableSwitchCellModel()

    fileprivate let changePasswordModel = StaticTableButtonCellModel()
    fileprivate let exportProfileModel = StaticTableButtonCellModel()
    fileprivate let deleteProfileModel = StaticTableButtonCellModel()

    fileprivate var documentInteractionController: UIDocumentInteractionController?

    init(theme: Theme, toxManager: OCTManager) {
        self.toxManager = toxManager

        var model = [[StaticTableBaseCellModel]]()
        var footers = [String?]()

        model.append([pinEnabledModel, lockTimeoutModel])
        footers.append(String(localized: "pin_description"))

        if LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            model.append([touchIdEnabledModel])
            footers.append(String(localized: "pin_touch_id_description"))
        }

        model.append([changePasswordModel])
        footers.append(nil)

        model.append([exportProfileModel, deleteProfileModel])
        footers.append(nil)

        super.init(theme: theme, style: .grouped, model: model, footers: footers)

        updateModel()

        title = String(localized: "profile_details")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateModel()
        reloadTableView()
    }
}

extension ProfileDetailsController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
        return view
    }

    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
        return view.frame
    }
}

private extension ProfileDetailsController {
    func updateModel() {
        let settings = toxManager.objects.getProfileSettings()
        let isPinEnabled = settings.unlockPinCode != nil

        pinEnabledModel.title = String(localized: "pin_enabled")
        pinEnabledModel.on = isPinEnabled
        pinEnabledModel.valueChangedHandler = pinEnabledValueChanged

        lockTimeoutModel.title = String(localized: "pin_lock_timeout")
        lockTimeoutModel.showArrow = true
        lockTimeoutModel.didSelectHandler = changeLockTimeout

        switch settings.lockTimeout {
            case .Immediately:
                lockTimeoutModel.value = String(localized: "pin_lock_immediately")
            case .Seconds30:
                lockTimeoutModel.value = String(localized: "pin_lock_30_seconds")
            case .Minute1:
                lockTimeoutModel.value = String(localized: "pin_lock_1_minute")
            case .Minute2:
                lockTimeoutModel.value = String(localized: "pin_lock_2_minutes")
            case .Minute5:
                lockTimeoutModel.value = String(localized: "pin_lock_5_minutes")
        }

        touchIdEnabledModel.enabled = isPinEnabled
        touchIdEnabledModel.title = String(localized: "pin_touch_id_enabled")
        touchIdEnabledModel.on = settings.useTouchID
        touchIdEnabledModel.valueChangedHandler = touchIdEnabledValueChanged

        changePasswordModel.title = String(localized: "change_password")
        changePasswordModel.didSelectHandler = changePassword

        exportProfileModel.title = String(localized: "export_profile")
        exportProfileModel.didSelectHandler = exportProfile

        deleteProfileModel.title = String(localized: "delete_profile")
        deleteProfileModel.didSelectHandler = deleteProfile
    }

    func pinEnabledValueChanged(_ on: Bool) {
        if on {
            delegate?.profileDetailsControllerSetPin(self)
        }
        else {
            let settings = toxManager.objects.getProfileSettings()
            settings.unlockPinCode = nil
            toxManager.objects.saveProfileSettings(settings)
        }

        updateModel()
        reloadTableView()
    }

    func changeLockTimeout(_: StaticTableBaseCell) {
        delegate?.profileDetailsControllerChangeLockTimeout(self)
    }

    func touchIdEnabledValueChanged(_ on: Bool) {
        let settings = toxManager.objects.getProfileSettings()
        settings.useTouchID = on
        toxManager.objects.saveProfileSettings(settings)
    }

    func changePassword(_: StaticTableBaseCell) {
        delegate?.profileDetailsControllerChangePassword(self)
    }

    func exportProfile(_: StaticTableBaseCell) {
        do {
            let path = try toxManager.exportToxSaveFile()

            let name = UserDefaultsManager().lastActiveProfile ?? "profile"

            documentInteractionController = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
            documentInteractionController!.delegate = self
            documentInteractionController!.name = "\(name).tox"
            documentInteractionController!.presentOptionsMenu(from: view.frame, in:view, animated: true)
        }
        catch let error as NSError {
            handleErrorWithType(.exportProfile, error: error)
        }
    }

    func deleteProfile(_ cell: StaticTableBaseCell) {
        let title1 = String(localized: "delete_profile_confirmation_title_1")
        let title2 = String(localized: "delete_profile_confirmation_title_2")
        let message = String(localized: "delete_profile_confirmation_message")
        let yes = String(localized: "alert_delete")
        let cancel = String(localized: "alert_cancel")

        let alert1 = UIAlertController(title: title1, message: message, preferredStyle: .actionSheet)
        alert1.popoverPresentationController?.sourceView = cell
        alert1.popoverPresentationController?.sourceRect = CGRect(x: cell.frame.size.width / 2, y: cell.frame.size.height / 2, width: 1.0, height: 1.0)

        alert1.addAction(UIAlertAction(title: yes, style: .destructive) { [unowned self] _ -> Void in
            let alert2 = UIAlertController(title: title2, message: nil, preferredStyle: .actionSheet)
            alert2.popoverPresentationController?.sourceView = cell
            alert2.popoverPresentationController?.sourceRect = CGRect(x: cell.frame.size.width / 2, y: cell.frame.size.height / 2, width: 1.0, height: 1.0)

            alert2.addAction(UIAlertAction(title: yes, style: .destructive) { [unowned self] _ -> Void in
                self.reallyDeleteProfile()
            })
            alert2.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))

            self.present(alert2, animated: true, completion: nil)
        })

        alert1.addAction(UIAlertAction(title: cancel, style: .cancel, handler: nil))

        present(alert1, animated: true, completion: nil)
    }

    func reallyDeleteProfile() {
        delegate?.profileDetailsControllerDeleteProfile(self)
    }
}
