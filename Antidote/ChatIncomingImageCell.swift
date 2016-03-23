//
//  ChatIncomingImageCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let BigOffset = 20.0
    static let SmallOffset = 8.0
    static let ImageButtonSize = 180.0
    static let BottomLabelHorizontalOffset = 12.0
    static let BottomLabelBottomOffset = -6.0
    static let CenterImageSize = 50.0
    static let ProgressViewSize = 70.0
    static let CloseButtonSize = 25.0
}

class ChatIncomingImageCell: ChatFileCell {
    private var imageButton: UIButton!
    private var progressView: CircleProgressView!
    private var centerImageView: UIImageView!
    private var topLabel: UILabel!
    private var bottomLabel: UILabel!
    private var cancelButton: UIButton!

    private var startLoadingHandle: (Void -> Void)?

    /**
        This method should be called after setupWithTheme:model:
     */
    func setButtonImage(image: UIImage) {
        imageButton.setImage(image, forState: .Normal)
        imageButton.setBackgroundImage(nil, forState: .Normal)

        bottomLabel.hidden = true
    }

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let imageModel = model as? ChatIncomingImageCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        var centerImage: UIImage? = nil

        switch imageModel.state {
            case .WaitingConfirmation:
                centerImage = UIImage(named: "chat-file-download")!

                imageButton.userInteractionEnabled = true
                progressView.hidden = true
                centerImageView.hidden = false
                cancelButton.hidden = false

                topLabel.hidden = false
                topLabel.text = imageModel.fileName
                bottomLabel.hidden = false
                bottomLabel.text = imageModel.fileSize
            case .Loading:
                centerImage = UIImage(named: "chat-file-pause")!

                imageButton.userInteractionEnabled = true
                progressView.hidden = false
                centerImageView.hidden = false
                cancelButton.hidden = false

                topLabel.hidden = false
                topLabel.text = imageModel.fileName
                bottomLabel.hidden = false
                bottomLabel.text = imageModel.fileSize
            case .Paused:
                centerImage = UIImage(named: "chat-file-play")!

                imageButton.userInteractionEnabled = true
                progressView.hidden = true
                centerImageView.hidden = false
                cancelButton.hidden = false

                topLabel.hidden = false
                topLabel.text = imageModel.fileName
                bottomLabel.hidden = false
                bottomLabel.text = imageModel.fileSize
            case .Cancelled:
                imageButton.userInteractionEnabled = false
                progressView.hidden = true
                centerImageView.hidden = true
                cancelButton.hidden = true

                topLabel.hidden = false
                topLabel.text = imageModel.fileName
                bottomLabel.hidden = false
                bottomLabel.text = String(localized: "chat_file_cancelled")
            case .Done:
                imageButton.userInteractionEnabled = true
                progressView.hidden = true
                centerImageView.hidden = true
                cancelButton.hidden = true

                topLabel.hidden = true
                bottomLabel.hidden = false
                bottomLabel.text = imageModel.fileName
        }

        imageButton.setImage(nil, forState: .Normal)

        let backgroundColor = theme.colorForType(.FileImageBackgroundActive)
        let backgroundImage = UIImage.imageWithColor(backgroundColor, size: CGSize(width: 1.0, height: 1.0))
        imageButton.backgroundColor = backgroundColor
        imageButton.setBackgroundImage(backgroundImage, forState: .Normal)

        progressView.backgroundLineColor = theme.colorForType(.FileImageAcceptButtonTint).colorWithAlphaComponent(0.3)
        progressView.lineColor = theme.colorForType(.FileImageAcceptButtonTint)

        centerImageView.image = centerImage?.imageWithRenderingMode(.AlwaysTemplate)
        centerImageView.tintColor = theme.colorForType(.FileImageAcceptButtonTint)

        topLabel.textColor = theme.colorForType(.FileImageCancelledText)
        bottomLabel.textColor = theme.colorForType(.FileImageCancelledText)

        cancelButton.tintColor = theme.colorForType(.FileImageCancelButtonTint)

        startLoadingHandle = imageModel.startLoadingHandle
    }

    override func createViews() {
        super.createViews()

        imageButton = UIButton()
        imageButton.layer.cornerRadius = 12.0
        imageButton.clipsToBounds = true
        imageButton.imageView?.contentMode = .ScaleAspectFill
        imageButton.addTarget(self, action: "imageButtonPressed", forControlEvents: .TouchUpInside)
        contentView.addSubview(imageButton)

        centerImageView = UIImageView()
        contentView.addSubview(centerImageView)

        progressView = CircleProgressView()
        progressView.userInteractionEnabled = false
        contentView.addSubview(progressView)

        topLabel = UILabel()
        topLabel.font = UIFont.systemFontOfSize(14.0)
        contentView.addSubview(topLabel)

        bottomLabel = UILabel()
        bottomLabel.font = UIFont.systemFontOfSize(14.0)
        contentView.addSubview(bottomLabel)

        let cancelImage = UIImage(named: "chat-file-cancel")!.imageWithRenderingMode(.AlwaysTemplate)

        cancelButton = UIButton()
        cancelButton.setImage(cancelImage, forState: .Normal)
        cancelButton.addTarget(self, action: "cancelButtonPressed", forControlEvents: .TouchUpInside)
        contentView.addSubview(cancelButton)
    }

    override func installConstraints() {
        super.installConstraints()

        imageButton.snp_makeConstraints {
            $0.left.equalTo(contentView).offset(Constants.BigOffset)
            $0.top.equalTo(contentView).offset(Constants.BigOffset)
            $0.bottom.equalTo(contentView).offset(-Constants.BigOffset)
            $0.size.equalTo(Constants.ImageButtonSize)
        }

        centerImageView.snp_makeConstraints {
            $0.center.equalTo(imageButton)
            $0.size.equalTo(Constants.CenterImageSize)
        }

        progressView.snp_makeConstraints {
            $0.center.equalTo(imageButton)
            $0.size.equalTo(Constants.ProgressViewSize)
        }

        topLabel.snp_makeConstraints {
            $0.left.equalTo(imageButton).offset(Constants.BottomLabelHorizontalOffset)
            $0.right.lessThanOrEqualTo(imageButton).offset(-Constants.BottomLabelHorizontalOffset)
            $0.bottom.equalTo(bottomLabel.snp_top).offset(Constants.BottomLabelBottomOffset)
        }

        bottomLabel.snp_makeConstraints {
            $0.left.equalTo(imageButton).offset(Constants.BottomLabelHorizontalOffset)
            $0.right.lessThanOrEqualTo(imageButton).offset(-Constants.BottomLabelHorizontalOffset)
            $0.bottom.equalTo(imageButton).offset(Constants.BottomLabelBottomOffset)
        }

        cancelButton.snp_makeConstraints {
            $0.left.equalTo(imageButton.snp_right).offset(Constants.SmallOffset)
            $0.top.equalTo(imageButton)
            $0.size.equalTo(Constants.CloseButtonSize)
        }
    }

    override func updateProgress(progress: CGFloat) {
        progressView.progress = progress
    }

    override func updateEta(eta: String) {
        bottomLabel.text = eta
    }
}

extension ChatIncomingImageCell {
    func imageButtonPressed() {
        switch state {
            case .WaitingConfirmation:
                startLoadingHandle?()
            case .Loading:
                pauseOrResumeHandle?()
            case .Paused:
                pauseOrResumeHandle?()
            case .Cancelled:
                break
            case .Done:
                openHandle?()
        }
    }

    func cancelButtonPressed() {
        cancelHandle?()
    }
}
