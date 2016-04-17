//
//  ChatGenericFileCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

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

    var state: ChatGenericFileCellModel.State = .WaitingConfirmation

    var startLoadingHandle: (Void -> Void)?
    var cancelHandle: (Void -> Void)?
    var retryHandle: (Void -> Void)?
    var pauseOrResumeHandle: (Void -> Void)?
    var openHandle: (Void -> Void)?

    /**
        This method should be called after setupWithTheme:model:
     */
    func setButtonImage(image: UIImage) {
        let square: UIImage

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

        loadingView.imageButton.setBackgroundImage(square, forState: .Normal)

        if state == .WaitingConfirmation || state == .Done {
            loadingView.centerImageView.image = nil
        }
    }

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
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

        switch state {
            case .Loading:
                loadingView.centerImageView.image = UIImage.templateNamed("chat-file-pause-big")
            case .Paused:
                loadingView.centerImageView.image = UIImage.templateNamed("chat-file-play-big")
            case .WaitingConfirmation:
                fallthrough
            case .Cancelled:
                fallthrough
            case .Done:
                var fileExtension: String? = nil

                if let fileName = fileModel.fileName {
                    fileExtension = (fileName as NSString).pathExtension
                }

                loadingView.setImageWithUti(fileModel.fileUTI, fileExtension: fileExtension)
        }

        updateViewsWithState(fileModel.state, fileModel: fileModel)

        loadingView.imageButton.setImage(nil, forState: .Normal)

        let backgroundColor = theme.colorForType(.FileImageBackgroundActive)
        let backgroundImage = UIImage.imageWithColor(backgroundColor, size: CGSize(width: 1.0, height: 1.0))
        loadingView.imageButton.setBackgroundImage(backgroundImage, forState: .Normal)

        loadingView.progressView.backgroundLineColor = theme.colorForType(.FileImageAcceptButtonTint).colorWithAlphaComponent(0.3)
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
        cancelButton.setImage(cancelImage, forState: .Normal)
        cancelButton.addTarget(self, action: #selector(ChatGenericFileCell.cancelButtonPressed), forControlEvents: .TouchUpInside)

        let retryImage = UIImage.templateNamed("chat-file-retry")

        retryButton = UIButton()
        retryButton.setImage(retryImage, forState: .Normal)
        retryButton.addTarget(self, action: #selector(ChatGenericFileCell.retryButtonPressed), forControlEvents: .TouchUpInside)
    }

    func updateProgress(progress: CGFloat) {
        loadingView.progressView.progress = progress
    }

    func updateEta(eta: String) {
        loadingView.bottomLabel.text = eta
    }

    func updateBytesPerSecond(bytesPerSecond: OCTToxFileSize) {}

    func cancelButtonPressed() {
        cancelHandle?()
    }

    func retryButtonPressed() {
        retryHandle?()
    }

    /// Override in subclass
    func updateViewsWithState(state: ChatGenericFileCellModel.State, fileModel: ChatGenericFileCellModel) {}

    /// Override in subclass
    func loadingViewPressed() {}
}
