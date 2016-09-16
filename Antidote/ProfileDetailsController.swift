//
//  ProfileDetailsController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 30.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

protocol ProfileDetailsControllerDelegate: class {
    func profileDetailsControllerSetPin(controller: ProfileDetailsController)
    func profileDetailsControllerRemovePin(controller: ProfileDetailsController)
    func profileDetailsControllerChangePassword(controller: ProfileDetailsController)
    func profileDetailsControllerDeleteProfile(controller: ProfileDetailsController)
}

class ProfileDetailsController: StaticTableController {
    weak var delegate: ProfileDetailsControllerDelegate?

    private weak var toxManager: OCTManager!

    private let pinEnabledModel = StaticTableSwitchCellModel()
    private let lockTimeoutModel = StaticTableInfoCellModel()
    private let touchIdEnabledModel = StaticTableSwitchCellModel()

    private let changePasswordModel = StaticTableButtonCellModel()
    private let exportProfileModel = StaticTableButtonCellModel()
    private let deleteProfileModel = StaticTableButtonCellModel()

    private var documentInteractionController: UIDocumentInteractionController?

    init(theme: Theme, toxManager: OCTManager) {
        self.toxManager = toxManager

        super.init(theme: theme, style: .Grouped, model: [
            [
                pinEnabledModel,
                lockTimeoutModel,
            ],
            [
                touchIdEnabledModel,
            ],
            [
                changePasswordModel,
            ],
            [
                exportProfileModel,
                deleteProfileModel,
            ],
        ], footers: [
            String(localized: "pin_description"),
            String(localized: "pin_touch_id_description"),
            nil,
            nil,
        ])

        updateModel()

        title = String(localized: "profile_details")
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        updateModel()
        reloadTableView()
    }
}

extension ProfileDetailsController: UIDocumentInteractionControllerDelegate {
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }

    func documentInteractionControllerViewForPreview(controller: UIDocumentInteractionController) -> UIView? {
        return view
    }

    func documentInteractionControllerRectForPreview(controller: UIDocumentInteractionController) -> CGRect {
        return view.frame
    }
}

private extension ProfileDetailsController {
    func updateModel() {
        let settings = toxManager.objects.getProfileSettings()

        pinEnabledModel.title = String(localized: "pin_enabled")
        pinEnabledModel.on = settings.unlockPinCode != nil
        pinEnabledModel.valueChangedHandler = pinEnabledValueChanged

        lockTimeoutModel.title = String(localized: "pin_lock_timeout")
        lockTimeoutModel.showArrow = true
        lockTimeoutModel.didSelectHandler = changeLockTimeout
        lockTimeoutModel.value = String(localized: "pin_lock_immediately")

        touchIdEnabledModel.title = String(localized: "pin_touch_id_enabled")
        touchIdEnabledModel.on = false
        touchIdEnabledModel.valueChangedHandler = touchIdEnabledValueChanged

        changePasswordModel.title = String(localized: "change_password")
        changePasswordModel.didSelectHandler = changePassword

        exportProfileModel.title = String(localized: "export_profile")
        exportProfileModel.didSelectHandler = exportProfile

        deleteProfileModel.title = String(localized: "delete_profile")
        deleteProfileModel.didSelectHandler = deleteProfile
    }

    func pinEnabledValueChanged(on: Bool) {
        if on {
            delegate?.profileDetailsControllerSetPin(self)
        }
        else {
            delegate?.profileDetailsControllerRemovePin(self)
        }
    }

    func changeLockTimeout(_: StaticTableBaseCell) {
    }

    func touchIdEnabledValueChanged(on: Bool) {
    }

    func changePassword(_: StaticTableBaseCell) {
        delegate?.profileDetailsControllerChangePassword(self)
    }

    func exportProfile(_: StaticTableBaseCell) {
        do {
            let path = try toxManager.exportToxSaveFile()

            let name = UserDefaultsManager().lastActiveProfile ?? "profile"

            documentInteractionController = UIDocumentInteractionController(URL: NSURL.fileURLWithPath(path))
            documentInteractionController!.delegate = self
            documentInteractionController!.name = "\(name).tox"
            documentInteractionController!.presentOptionsMenuFromRect(view.frame, inView:view, animated: true)
        }
        catch let error as NSError {
            handleErrorWithType(.ExportProfile, error: error)
        }
    }

    func deleteProfile(cell: StaticTableBaseCell) {
        let title1 = String(localized: "delete_profile_confirmation_title_1")
        let title2 = String(localized: "delete_profile_confirmation_title_2")
        let message = String(localized: "delete_profile_confirmation_message")
        let yes = String(localized: "alert_delete")
        let cancel = String(localized: "alert_cancel")

        let alert1 = UIAlertController(title: title1, message: message, preferredStyle: .ActionSheet)
        alert1.popoverPresentationController?.sourceView = cell
        alert1.popoverPresentationController?.sourceRect = CGRect(x: cell.frame.size.width / 2, y: cell.frame.size.height / 2, width: 1.0, height: 1.0)

        alert1.addAction(UIAlertAction(title: yes, style: .Destructive) { [unowned self] _ -> Void in
            let alert2 = UIAlertController(title: title2, message: nil, preferredStyle: .ActionSheet)
            alert2.popoverPresentationController?.sourceView = cell
            alert2.popoverPresentationController?.sourceRect = CGRect(x: cell.frame.size.width / 2, y: cell.frame.size.height / 2, width: 1.0, height: 1.0)

            alert2.addAction(UIAlertAction(title: yes, style: .Destructive) { [unowned self] _ -> Void in
                self.reallyDeleteProfile()
            })
            alert2.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: nil))

            self.presentViewController(alert2, animated: true, completion: nil)
        })

        alert1.addAction(UIAlertAction(title: cancel, style: .Cancel, handler: nil))

        presentViewController(alert1, animated: true, completion: nil)
    }

    func reallyDeleteProfile() {
        delegate?.profileDetailsControllerDeleteProfile(self)
    }
}
