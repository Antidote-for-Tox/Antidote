//
//  ProfileDetailsController.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 30.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

protocol ProfileDetailsControllerDelegate: class {
    func profileDetailsControllerChangePassword(controller: ProfileDetailsController)
    func profileDetailsControllerDeleteProfile(controller: ProfileDetailsController)
}

class ProfileDetailsController: StaticTableController {
    weak var delegate: ProfileDetailsControllerDelegate?

    private let toxManager: OCTManager

    private let passwordModel = StaticTableDefaultCellModel()
    private let exportProfileModel = StaticTableButtonCellModel()
    private let deleteProfileModel = StaticTableButtonCellModel()

    private var documentInteractionController: UIDocumentInteractionController?

    init(theme: Theme, toxManager: OCTManager) {
        self.toxManager = toxManager

        super.init(theme: theme, style: .Plain, model: [
            [
                passwordModel,
            ],
            [
                exportProfileModel,
                deleteProfileModel,
            ],
        ])

        updateModels()

        title = String(localized: "status_title")
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
    func updateModels() {
        if let passphrase = toxManager.configuration().passphrase where !passphrase.isEmpty {
            passwordModel.value = String(localized: "change_password")
        }
        else {
            passwordModel.value = String(localized: "set_password")
        }
        passwordModel.didSelectHandler = changePassword
        passwordModel.rightImageType = .Arrow

        exportProfileModel.title = String(localized: "export_profile")
        exportProfileModel.didSelectHandler = exportProfile

        deleteProfileModel.title = String(localized: "delete_profile")
        deleteProfileModel.didSelectHandler = deleteProfile
    }

    func changePassword() {
        delegate?.profileDetailsControllerChangePassword(self)
    }

    func exportProfile() {
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

    func deleteProfile() {
        let title1 = String(localized: "delete_profile_confirmation_title_1")
        let title2 = String(localized: "delete_profile_confirmation_title_2")
        let message = String(localized: "delete_profile_confirmation_message")
        let yes = String(localized: "delete_profile_yes")
        let cancel = String(localized: "delete_profile_cancel")

        let alert1 = UIAlertController(title: title1, message: message, preferredStyle: .ActionSheet)

        alert1.addAction(UIAlertAction(title: yes, style: .Destructive) { [unowned self] _ -> Void in
            let alert2 = UIAlertController(title: title2, message: nil, preferredStyle: .ActionSheet)

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
