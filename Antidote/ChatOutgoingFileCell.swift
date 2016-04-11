//
//  ChatOutgoingFileCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25.03.16.
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

class ChatOutgoingFileCell: ChatGenericFileCell {
    override func setButtonImage(image: UIImage) {
        super.setButtonImage(image)

        loadingView.bottomLabel.hidden = true
        if state == .Cancelled {
            loadingView.centerImageView.image = nil
        }
    }

    override func createViews() {
        super.createViews()

        movableContentView.addSubview(loadingView)
        movableContentView.addSubview(cancelButton)
    }

    override func installConstraints() {
        super.installConstraints()

        cancelButton.snp_makeConstraints {
            $0.trailing.equalTo(loadingView.snp_leading).offset(-Constants.SmallOffset)
            $0.top.equalTo(loadingView)
            $0.size.equalTo(Constants.CloseButtonSize)
        }

        loadingView.snp_makeConstraints {
            $0.trailing.equalTo(movableContentView).offset(-Constants.BigOffset)
            $0.top.equalTo(movableContentView).offset(Constants.SmallOffset)
            $0.bottom.equalTo(movableContentView).offset(-Constants.SmallOffset)
            $0.size.equalTo(Constants.ImageButtonSize)
        }
    }

    override func updateViewsWithState(state: ChatGenericFileCellModel.State, fileModel: ChatGenericFileCellModel) {
        loadingView.imageButton.userInteractionEnabled = true
        loadingView.progressView.hidden = true
        loadingView.topLabel.hidden = true
        loadingView.bottomLabel.hidden = false
        loadingView.bottomLabel.text = fileModel.fileName

        cancelButton.hidden = false

        switch state {
            case .WaitingConfirmation:
                loadingView.imageButton.userInteractionEnabled = false
                loadingView.bottomLabel.text = String(localized: "chat_waiting")
            case .Loading:
                loadingView.progressView.hidden = false
            case .Paused:
                break
            case .Cancelled:
                loadingView.bottomLabel.text = String(localized: "chat_file_cancelled")
                cancelButton.hidden = true
            case .Done:
                cancelButton.hidden = true
        }
    }

    override func loadingViewPressed() {
        switch state {
            case .WaitingConfirmation:
                break
            case .Loading:
                pauseOrResumeHandle?()
            case .Paused:
                pauseOrResumeHandle?()
            case .Cancelled:
                openHandle?()
            case .Done:
                openHandle?()
        }
    }
}
