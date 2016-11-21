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

class ChatOutgoingFileCell: ChatGenericFileCell {
    override func setButtonImage(_ image: UIImage) {
        super.setButtonImage(image)

        loadingView.bottomLabel.isHidden = true

        if state == .cancelled {
            loadingView.bottomLabel.isHidden = false
            loadingView.centerImageView.image = nil
        }
    }

    override func createViews() {
        super.createViews()

        movableContentView.addSubview(loadingView)
        movableContentView.addSubview(cancelButton)
        movableContentView.addSubview(retryButton)
    }

    override func installConstraints() {
        super.installConstraints()

        cancelButton.snp.makeConstraints {
            $0.trailing.equalTo(loadingView.snp.leading).offset(-Constants.SmallOffset)
            $0.top.equalTo(loadingView)
            $0.size.equalTo(Constants.CloseButtonSize)
        }

        retryButton.snp.makeConstraints {
            $0.center.equalTo(cancelButton)
            $0.size.equalTo(cancelButton)
        }

        loadingView.snp.makeConstraints {
            $0.trailing.equalTo(movableContentView).offset(-Constants.BigOffset)
            $0.top.equalTo(movableContentView).offset(Constants.SmallOffset)
            $0.bottom.equalTo(movableContentView).offset(-Constants.SmallOffset)
            $0.size.equalTo(Constants.ImageButtonSize)
        }
    }

    override func updateViewsWithState(_ state: ChatGenericFileCellModel.State, fileModel: ChatGenericFileCellModel) {
        loadingView.imageButton.isUserInteractionEnabled = true
        loadingView.progressView.isHidden = true
        loadingView.topLabel.isHidden = true
        loadingView.bottomLabel.isHidden = false
        loadingView.bottomLabel.text = fileModel.fileName

        cancelButton.isHidden = false
        retryButton.isHidden = true

        switch state {
            case .waitingConfirmation:
                loadingView.imageButton.isUserInteractionEnabled = false
                loadingView.bottomLabel.text = String(localized: "chat_waiting")
            case .loading:
                loadingView.progressView.isHidden = false
            case .paused:
                break
            case .cancelled:
                loadingView.bottomLabel.text = String(localized: "chat_file_cancelled")
                cancelButton.isHidden = true
                retryButton.isHidden = false
            case .done:
                cancelButton.isHidden = true
        }
    }

    override func loadingViewPressed() {
        switch state {
            case .waitingConfirmation:
                break
            case .loading:
                pauseOrResumeHandle?()
            case .paused:
                pauseOrResumeHandle?()
            case .cancelled:
                openHandle?()
            case .done:
                openHandle?()
        }
    }
}
