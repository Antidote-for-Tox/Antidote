// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import MobileCoreServices
import Photos

fileprivate struct Constants {
    static let inactivityTimeout = 4.0
}

/**
    Manager responsible for sending messages and files, updating typing notification,
    saving entered text in database.
 */
class ChatInputViewManager: NSObject {
    fileprivate var chat: OCTChat!
    fileprivate weak var inputView: ChatInputView?

    fileprivate weak var submanagerChats: OCTSubmanagerChats!
    fileprivate weak var submanagerFiles: OCTSubmanagerFiles!
    fileprivate weak var submanagerObjects: OCTSubmanagerObjects!

    fileprivate weak var presentingViewController: UIViewController!

    fileprivate var inactivityTimer: Timer?

    init(inputView: ChatInputView,
         chat: OCTChat,
         submanagerChats: OCTSubmanagerChats,
         submanagerFiles: OCTSubmanagerFiles,
         submanagerObjects: OCTSubmanagerObjects,
         presentingViewController: UIViewController) {

        self.chat = chat
        self.inputView = inputView
        self.submanagerChats = submanagerChats
        self.submanagerFiles = submanagerFiles
        self.submanagerObjects = submanagerObjects
        self.presentingViewController = presentingViewController

        super.init()

        inputView.delegate = self
        inputView.text = chat.enteredText ?? ""
    }

    deinit {
        endUserInteraction()
    }
}

extension ChatInputViewManager: ChatInputViewDelegate {
    func chatInputViewCameraButtonPressed(_ view: ChatInputView, cameraView: UIView) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.popoverPresentationController?.sourceView = cameraView
        alert.popoverPresentationController?.sourceRect = CGRect(x: cameraView.frame.size.width / 2, y: cameraView.frame.size.height / 2, width: 1.0, height: 1.0)

        func addAction(title: String, sourceType: UIImagePickerControllerSourceType) {
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                alert.addAction(UIAlertAction(title: title, style: .default) { [unowned self] _ -> Void in
                    let controller = UIImagePickerController()
                    controller.delegate = self
                    controller.sourceType = sourceType
                    controller.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
                    controller.videoQuality = .typeHigh
                    self.presentingViewController.present(controller, animated: true, completion: nil)
                })
            }
        }

        addAction(title: String(localized: "photo_from_camera"), sourceType: .camera)
        addAction(title: String(localized: "photo_from_photo_library"), sourceType: .photoLibrary)
        alert.addAction(UIAlertAction(title: String(localized: "alert_cancel"), style: .cancel, handler: nil))

        presentingViewController.present(alert, animated: true, completion: nil)
    }

    func chatInputViewSendButtonPressed(_ view: ChatInputView) {
        submanagerChats.sendMessage(to: chat, text: view.text, type: .normal, successBlock: nil, failureBlock: nil)

        view.text = ""
        endUserInteraction()
    }

    func chatInputViewTextDidChange(_ view: ChatInputView) {
        try? submanagerChats.setIsTyping(true, in: chat)
        inactivityTimer?.invalidate()

        inactivityTimer = Timer.scheduledTimer(timeInterval: Constants.inactivityTimeout, closure: {[weak self] _ -> Void in
            self?.endUserInteraction()
        }, repeats: false)
    }
}

extension ChatInputViewManager: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        presentingViewController.dismiss(animated: true, completion: nil)

        guard let type = info[UIImagePickerControllerMediaType] as? String else {
            return
        }

        let typeImage = kUTTypeImage as String
        let typeMovie = kUTTypeMovie as String

        switch type {
            case typeImage:
                sendImage(imagePickerInfo: info)
            case typeMovie:
                sendMovie(imagePickerInfo: info)
            default:
                return
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

extension ChatInputViewManager: UINavigationControllerDelegate {}

fileprivate extension ChatInputViewManager {
    func endUserInteraction() {
        try? submanagerChats.setIsTyping(false, in: chat)
        inactivityTimer?.invalidate()

        if let inputView = inputView {
            submanagerObjects.change(chat, enteredText: inputView.text)
        }
    }

    func sendImage(imagePickerInfo: [String : Any]) {
        guard let image = imagePickerInfo[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        guard let data = UIImageJPEGRepresentation(image, 0.9) else {
            return
        }

        var fileName: String? = fileNameFromImageInfo(imagePickerInfo)

        if fileName == nil {
            let dateString = DateFormatter(type: .dateAndTime).string(from: Date())
            fileName = "Photo \(dateString).jpg".replacingOccurrences(of: "/", with: "-")
        }

        submanagerFiles.send(data, withFileName: fileName!, to: chat) { (error: Error) in
            handleErrorWithType(.sendFileToFriend, error: error as NSError)
        }
    }

    func sendMovie(imagePickerInfo: [String : Any]) {
        guard let url = imagePickerInfo[UIImagePickerControllerMediaURL] as? URL else {
            return
        }

        submanagerFiles.sendFile(atPath: url.path, moveToUploads: true, to: chat) { (error: Error) in
            handleErrorWithType(.sendFileToFriend, error: error as NSError)
        }
    }

    func fileNameFromImageInfo(_ info: [String: Any]) -> String? {
        guard let url = info[UIImagePickerControllerReferenceURL] as? URL else {
            return nil
        }

        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [url], options: nil)

        guard let asset = fetchResult.firstObject else {
            return nil
        }

        if #available(iOS 9.0, *) {
            if let resource = PHAssetResource.assetResources(for: asset).first {
                return resource.originalFilename
            }
        } else {
            // Fallback on earlier versions
            if let name = asset.value(forKey: "filename") as? String {
                return name
            }
        }

        return nil
    }
}
