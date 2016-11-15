// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit
import SnapKit

private struct Constants {
    static let BigOffset = 20.0
    static let SmallOffset = 8.0
    static let ImageButtonSize = 180.0
    static let CloseButtonSize = 25.0
}

class ChatIncomingFileCell: ChatGenericFileCell {
    override func setButtonImage(_ image: UIImage) {
        super.setButtonImage(image)
        loadingView.bottomLabel.isHidden = true
    }

    override func createViews() {
        super.createViews()

        contentView.addSubview(loadingView)
        contentView.addSubview(cancelButton)
    }

    override func installConstraints() {
        super.installConstraints()

        loadingView.snp.makeConstraints {
            $0.leading.equalTo(contentView).offset(Constants.BigOffset)
            $0.top.equalTo(contentView).offset(Constants.SmallOffset)
            $0.bottom.equalTo(contentView).offset(-Constants.SmallOffset)
            $0.size.equalTo(Constants.ImageButtonSize)
        }

        cancelButton.snp.makeConstraints {
            $0.leading.equalTo(loadingView.snp.trailing).offset(Constants.SmallOffset)
            $0.top.equalTo(loadingView)
            $0.size.equalTo(Constants.CloseButtonSize)
        }
    }

    override func updateViewsWithState(_ state: ChatGenericFileCellModel.State, fileModel: ChatGenericFileCellModel) {
        loadingView.imageButton.isUserInteractionEnabled = true
        loadingView.progressView.isHidden = true
        loadingView.topLabel.isHidden = false
        loadingView.topLabel.text = fileModel.fileName
        loadingView.bottomLabel.text = fileModel.fileSize
        loadingView.bottomLabel.isHidden = false

        cancelButton.isHidden = false

        switch state {
            case .waitingConfirmation:
                loadingView.centerImageView.image = UIImage.templateNamed("chat-file-download-big")
            case .loading:
                loadingView.progressView.isHidden = false
            case .paused:
                break
            case .cancelled:
                loadingView.setCancelledImage()
                loadingView.imageButton.isUserInteractionEnabled = false
                cancelButton.isHidden = true
                loadingView.bottomLabel.text = String(localized: "chat_file_cancelled")
            case .done:
                cancelButton.isHidden = true
                loadingView.topLabel.isHidden = true
                loadingView.bottomLabel.text = fileModel.fileName
        }
    }

    override func loadingViewPressed() {
        switch state {
            case .waitingConfirmation:
                startLoadingHandle?()
            case .loading:
                pauseOrResumeHandle?()
            case .paused:
                pauseOrResumeHandle?()
            case .cancelled:
                break
            case .done:
                openHandle?()
        }
    }
}
