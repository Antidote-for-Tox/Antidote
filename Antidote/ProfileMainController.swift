// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

protocol ProfileMainControllerDelegate: class {
    func profileMainControllerLogout(controller: ProfileMainController)
    func profileMainControllerChangeUserName(controller: ProfileMainController)
    func profileMainControllerChangeUserStatus(controller: ProfileMainController)
    func profileMainControllerChangeStatusMessage(controller: ProfileMainController)
    func profileMainController(controller: ProfileMainController, showQRCodeWithText text: String)
    func profileMainControllerShowProfileDetails(controller: ProfileMainController)
    func profileMainControllerDidChangeAvatar(controller: ProfileMainController)
}

class ProfileMainController: StaticTableController {
    weak var delegate: ProfileMainControllerDelegate?

    private weak var submanagerUser: OCTSubmanagerUser!
    private let avatarManager: AvatarManager

    private let avatarModel = StaticTableAvatarCellModel()
    private let userNameModel = StaticTableDefaultCellModel()
    private let statusMessageModel = StaticTableDefaultCellModel()
    private let userStatusModel = StaticTableDefaultCellModel()
    private let toxIdModel = StaticTableDefaultCellModel()
    private let profileDetailsModel = StaticTableDefaultCellModel()
    private let logoutModel = StaticTableButtonCellModel()

    init(theme: Theme, submanagerUser: OCTSubmanagerUser) {
        self.submanagerUser = submanagerUser

        avatarManager = AvatarManager(theme: theme)

        super.init(theme: theme, style: .Plain, model: [
            [
                avatarModel,
            ],
            [
                userNameModel,
                statusMessageModel,
            ],
            [
                userStatusModel,
            ],
            [
                toxIdModel,
            ],
            [
                profileDetailsModel,
            ],
            [
                logoutModel,
            ],
        ])

        updateModels()

        title = String(localized: "profile_title")
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

extension ProfileMainController: UIImagePickerControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        dismissViewControllerAnimated(true, completion: nil)

        guard var image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }

        if image.size.width != image.size.height {
            let side = min(image.size.width, image.size.height)
            let x = (image.size.width - side) / 2
            let y = (image.size.height - side) / 2
            let rect = CGRect(x: x, y: y, width: side, height: side)

            image = image.cropWithRect(rect)
        }

        let data: NSData

        do {
            data = try pngDataFromImage(image)
        }
        catch {
            handleErrorWithType(.ConvertImageToPNG, error: nil)
            return
        }

        do {
            try submanagerUser.setUserAvatar(data)
            updateModels()
            reloadTableView()

            delegate?.profileMainControllerDidChangeAvatar(self)
        }
        catch let error as NSError {
            handleErrorWithType(.ChangeAvatar, error: error)
        }
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ProfileMainController: UINavigationControllerDelegate {}

private extension ProfileMainController {
    struct PNGFromDataError: ErrorType {}

    func updateModels() {
        if let avatarData = submanagerUser.userAvatar() {
            avatarModel.avatar = UIImage(data: avatarData)
        }
        else {
            avatarModel.avatar = avatarManager.avatarFromString(
                    submanagerUser.userName() ?? "?",
                    diameter: StaticTableAvatarCellModel.Constants.AvatarImageSize)
        }
        avatarModel.didTapOnAvatar = performAvatarAction

        userNameModel.title = String(localized: "name")
        userNameModel.value = submanagerUser.userName()
        userNameModel.rightImageType = .Arrow
        userNameModel.didSelectHandler = changeUserName

        // Hardcoding any connected status to show only online/away/busy statuses here.
        let userStatus = UserStatus(connectionStatus: OCTToxConnectionStatus.TCP, userStatus: submanagerUser.userStatus)

        userStatusModel.userStatus = userStatus
        userStatusModel.value = userStatus.toString()
        userStatusModel.rightImageType = .Arrow
        userStatusModel.didSelectHandler = changeUserStatus

        statusMessageModel.title = String(localized: "status_message")
        statusMessageModel.value = submanagerUser.userStatusMessage()
        statusMessageModel.rightImageType = .Arrow
        statusMessageModel.didSelectHandler = changeStatusMessage

        toxIdModel.title = String(localized: "my_tox_id")
        toxIdModel.value = submanagerUser.userAddress
        toxIdModel.rightButton = String(localized: "show_qr")
        toxIdModel.rightButtonHandler = showToxIdQR
        toxIdModel.userInteractionEnabled = false
        toxIdModel.canCopyValue = true

        profileDetailsModel.value = String(localized: "profile_details")
        profileDetailsModel.didSelectHandler = showProfileDetails
        profileDetailsModel.rightImageType = .Arrow

        logoutModel.title = String(localized: "logout_button")
        logoutModel.didSelectHandler = logout
    }

    func logout(_: StaticTableBaseCell) {
        delegate?.profileMainControllerLogout(self)
    }

    func performAvatarAction(cell: StaticTableAvatarCell) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alert.popoverPresentationController?.sourceView = cell
        alert.popoverPresentationController?.sourceRect = CGRect(x: cell.frame.size.width / 2, y: cell.frame.size.height / 2, width: 1.0, height: 1.0)

        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(UIAlertAction(title: String(localized: "photo_from_camera"), style: .Default) { [unowned self] _ -> Void in
                let controller = UIImagePickerController()
                controller.sourceType = .Camera
                controller.delegate = self

                if (UIImagePickerController.isCameraDeviceAvailable(.Front)) {
                    controller.cameraDevice = .Front
                }

                self.presentViewController(controller, animated: true, completion: nil)
            })
        }

        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: String(localized: "photo_from_photo_library"), style: .Default) { [unowned self] _ -> Void in
                let controller = UIImagePickerController()
                controller.sourceType = .PhotoLibrary
                controller.delegate = self
                self.presentViewController(controller, animated: true, completion: nil)
            })
        }

        if submanagerUser.userAvatar() != nil {
            alert.addAction(UIAlertAction(title: String(localized: "alert_delete"), style: .Destructive) { [unowned self] _ -> Void in
                self.removeAvatar()
            })
        }

        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .Cancel, handler: nil))

        presentViewController(alert, animated: true, completion: nil)
    }

    func removeAvatar() {
        do {
            try submanagerUser.setUserAvatar(nil)
            updateModels()
            reloadTableView()

            delegate?.profileMainControllerDidChangeAvatar(self)
        }
        catch let error as NSError {
            handleErrorWithType(.ChangeAvatar, error: error)
        }
    }

    func pngDataFromImage(image: UIImage) throws -> NSData {
        var imageSize = image.size

        // Maximum png size will be (4 * width * height)
        // * 1.5 to get as big avatar size as possible
        while OCTToxFileSize(4 * imageSize.width * imageSize.height) > OCTToxFileSize(1.5 * Double(kOCTManagerMaxAvatarSize)) {
            imageSize.width *= 0.9
            imageSize.height *= 0.9
        }

        imageSize.width = ceil(imageSize.width)
        imageSize.height = ceil(imageSize.height)

        var data: NSData
        var tempImage = image

        repeat {
            UIGraphicsBeginImageContext(imageSize)
            tempImage.drawInRect(CGRect(origin: CGPointZero, size: imageSize))
            tempImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            guard let theData = UIImagePNGRepresentation(tempImage) else {
                throw PNGFromDataError()
            }
            data = theData

            imageSize.width *= 0.9
            imageSize.height *= 0.9
        } while (OCTToxFileSize(data.length) > kOCTManagerMaxAvatarSize)

        return data
    }

    func changeUserName(_: StaticTableBaseCell) {
        delegate?.profileMainControllerChangeUserName(self)
    }

    func changeUserStatus(_: StaticTableBaseCell) {
        delegate?.profileMainControllerChangeUserStatus(self)
    }

    func changeStatusMessage(_: StaticTableBaseCell) {
        delegate?.profileMainControllerChangeStatusMessage(self)
    }

    func showToxIdQR() {
        delegate?.profileMainController(self, showQRCodeWithText: submanagerUser.userAddress)
    }

    func showProfileDetails(_: StaticTableBaseCell) {
        delegate?.profileMainControllerShowProfileDetails(self)
    }
}
