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
    static let CloseButtonSize = 25.0
}

class ChatIncomingImageCell: ChatGenericImageCell {
    override func setButtonImage(image: UIImage) {
        super.setButtonImage(image)
        loadingView.bottomLabel.hidden = true
    }

    override func createViews() {
        super.createViews()

        contentView.addSubview(loadingView)
        contentView.addSubview(cancelButton)
    }

    override func installConstraints() {
        super.installConstraints()

        loadingView.snp_makeConstraints {
            $0.left.equalTo(contentView).offset(Constants.BigOffset)
            $0.top.equalTo(contentView).offset(Constants.SmallOffset)
            $0.bottom.equalTo(contentView).offset(-Constants.SmallOffset)
            $0.size.equalTo(Constants.ImageButtonSize)
        }

        cancelButton.snp_makeConstraints {
            $0.left.equalTo(loadingView.snp_right).offset(Constants.SmallOffset)
            $0.top.equalTo(loadingView)
            $0.size.equalTo(Constants.CloseButtonSize)
        }
    }

    override func updateViewsWithState(state: ChatFileCellModel.State, imageModel: ChatGenericImageCellModel) {
        loadingView.imageButton.userInteractionEnabled = true
        loadingView.progressView.hidden = true
        loadingView.topLabel.hidden = false
        loadingView.topLabel.text = imageModel.fileName
        loadingView.bottomLabel.text = imageModel.fileSize
        loadingView.bottomLabel.hidden = false

        cancelButton.hidden = false

        switch state {
            case .WaitingConfirmation:
                loadingView.centerImageView.image = UIImage.templateNamed("chat-file-download-big")
            case .Loading:
                loadingView.progressView.hidden = false
            case .Paused:
                break
            case .Cancelled:
                loadingView.imageButton.userInteractionEnabled = false
                cancelButton.hidden = true
                loadingView.bottomLabel.text = String(localized: "chat_file_cancelled")
            case .Done:
                cancelButton.hidden = true
                loadingView.topLabel.hidden = true
                loadingView.bottomLabel.text = imageModel.fileName
        }
    }

    override func loadingViewPressed() {
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
}
