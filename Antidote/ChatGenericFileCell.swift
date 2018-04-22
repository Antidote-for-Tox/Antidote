// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

class ChatGenericFileCell: ChatMovableDateCell {
    var loadingView: LoadingImageView!
    var cancelButton: UIButton!
    var retryButton: UIButton!

    var progressObject: ChatProgressProtocol? {
        didSet {
            progressObject?.updateProgress = { [weak self] (progress: Float) -> Void in
                self?.updateProgress(CGFloat(progress))
            }

            progressObject?.updateEta = { [weak self] (eta: CFTimeInterval, bytesPerSecond: OCTToxFileSize) -> Void in
                self?.updateEta(String(timeInterval: eta))
                self?.updateBytesPerSecond(bytesPerSecond)
            }
        }
    }

    var state: ChatGenericFileCellModel.State = .waitingConfirmation

    var startLoadingHandle: (() -> Void)?
    var cancelHandle: (() -> Void)?
    var retryHandle: (() -> Void)?
    var pauseOrResumeHandle: (() -> Void)?
    var openHandle: (() -> Void)?

    /**
        This method should be called after setupWithTheme:model:
     */
    func setButtonImage(_ image: UIImage) {
        let square: UIImage

        canBeCopied = true

        if image.size.width == image.size.height {
            square = image
        }
        else {
            let side = min(image.size.width, image.size.height)
            let x = (image.size.width - side) / 2
            let y = (image.size.height - side) / 2
            let rect = CGRect(x: x, y: y, width: side, height: side)

            square = image.cropWithRect(rect)
        }

        loadingView.imageButton.setBackgroundImage(square, for: UIControlState())

        if state == .waitingConfirmation || state == .done {
            loadingView.centerImageView.image = nil
        }
    }

    override func setupWithTheme(_ theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let fileModel = model as? ChatGenericFileCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        state = fileModel.state
        startLoadingHandle = fileModel.startLoadingHandle
        cancelHandle = fileModel.cancelHandle
        retryHandle = fileModel.retryHandle
        pauseOrResumeHandle = fileModel.pauseOrResumeHandle
        openHandle = fileModel.openHandle

        canBeCopied = false

        switch state {
            case .loading:
                loadingView.centerImageView.image = UIImage.templateNamed("chat-file-pause-big")
            case .paused:
                loadingView.centerImageView.image = UIImage.templateNamed("chat-file-play-big")
            case .waitingConfirmation:
                fallthrough
            case .cancelled:
                fallthrough
            case .done:
                var fileExtension: String? = nil

                if let fileName = fileModel.fileName {
                    fileExtension = (fileName as NSString).pathExtension
                }

                loadingView.setImageWithUti(fileModel.fileUTI, fileExtension: fileExtension)
        }

        updateViewsWithState(fileModel.state, fileModel: fileModel)

        loadingView.imageButton.setImage(nil, for: UIControlState())

        let backgroundColor = theme.colorForType(.FileImageBackgroundActive)
        let backgroundImage = UIImage.imageWithColor(backgroundColor, size: CGSize(width: 1.0, height: 1.0))
        loadingView.imageButton.setBackgroundImage(backgroundImage, for: UIControlState())

        loadingView.progressView.backgroundLineColor = theme.colorForType(.FileImageAcceptButtonTint).withAlphaComponent(0.3)
        loadingView.progressView.lineColor = theme.colorForType(.FileImageAcceptButtonTint)

        loadingView.centerImageView.tintColor = theme.colorForType(.FileImageAcceptButtonTint)

        loadingView.topLabel.textColor = theme.colorForType(.FileImageCancelledText)
        loadingView.bottomLabel.textColor = theme.colorForType(.FileImageCancelledText)

        cancelButton.tintColor = theme.colorForType(.FileImageCancelButtonTint)
        retryButton.tintColor = theme.colorForType(.FileImageCancelButtonTint)
    }

    override func createViews() {
        super.createViews()

        loadingView = LoadingImageView()
        loadingView.pressedHandle = loadingViewPressed

        let cancelImage = UIImage.templateNamed("chat-file-cancel")

        cancelButton = UIButton()
        cancelButton.setImage(cancelImage, for: UIControlState())
        cancelButton.addTarget(self, action: #selector(ChatGenericFileCell.cancelButtonPressed), for: .touchUpInside)

        let retryImage = UIImage.templateNamed("chat-file-retry")

        retryButton = UIButton()
        retryButton.setImage(retryImage, for: UIControlState())
        retryButton.addTarget(self, action: #selector(ChatGenericFileCell.retryButtonPressed), for: .touchUpInside)
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        loadingView.isUserInteractionEnabled = !editing
        cancelButton.isUserInteractionEnabled = !editing
        retryButton.isUserInteractionEnabled = !editing
    }

    func updateProgress(_ progress: CGFloat) {
        loadingView.progressView.progress = progress
    }

    func updateEta(_ eta: String) {
        loadingView.bottomLabel.text = eta
    }

    func updateBytesPerSecond(_ bytesPerSecond: OCTToxFileSize) {}

    @objc func cancelButtonPressed() {
        cancelHandle?()
    }

    @objc func retryButtonPressed() {
        retryHandle?()
    }

    /// Override in subclass
    func updateViewsWithState(_ state: ChatGenericFileCellModel.State, fileModel: ChatGenericFileCellModel) {}

    /// Override in subclass
    func loadingViewPressed() {}
}

// ChatEditable
extension ChatGenericFileCell {
    override func shouldShowMenu() -> Bool {
        return true
    }

    override func menuTargetRect() -> CGRect {
        return loadingView.frame
    }
}
