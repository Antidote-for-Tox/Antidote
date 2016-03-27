//
//  ChatIncomingFileCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let BorderOffset = 20.0
    static let VerticalOffset = 4.0
    static let ButtonOffset = 16.0
    static let ButtonSize = 25.0
    static let LoadingRightOffset = -130.0
}

class ChatIncomingFileCell: ChatFileCell {
    private var loadingView: LoadingFileView!
    private var cancelButton: UIButton!
    private var acceptButton: UIButton!
    private var openButton: UIButton!

    private var cancelToAcceptConstraint: Constraint!
    private var cancelToBorderConstraint: Constraint!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let fileModel = model as? ChatIncomingFileCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        loadingView.imageView.tintColor = theme.colorForType(.LinkText)
        loadingView.topLabel.text = fileModel.fileName
        loadingView.topLabel.textColor = theme.colorForType(.NormalText)
        loadingView.tintColor = theme.colorForType(.LinkText)

        acceptButton.tintColor = theme.colorForType(.FileImageCancelButtonTint)
        cancelButton.tintColor = theme.colorForType(.FileImageCancelButtonTint)
        openButton.hidden = true

        func setUti() {
            var fileExtension: String? = nil

            if let fileName = fileModel.fileName {
                fileExtension = (fileName as NSString).pathExtension
            }

            loadingView.setImageWithUti(fileModel.fileUTI, fileExtension: fileExtension)
        }

        switch fileModel.state {
            case .WaitingConfirmation:
                setUti()
                loadingView.button.setImage(nil, forState: .Normal)
                loadingView.bottomLabel.text = fileModel.fileSize
                loadingView.enableProgressView = false

                acceptButton.hidden = false
                cancelButton.hidden = false
                cancelToBorderConstraint.deactivate()
                cancelToAcceptConstraint.activate()
            case .Loading:
                setUti()
                loadingView.button.setImage(UIImage.templateNamed("chat-file-pause"), forState: .Normal)
                loadingView.enableProgressView = true

                acceptButton.hidden = true
                cancelButton.hidden = false
                cancelToAcceptConstraint.deactivate()
                cancelToBorderConstraint.activate()
            case .Paused:
                setUti()
                loadingView.button.setImage(UIImage.templateNamed("chat-file-play"), forState: .Normal)
                loadingView.bottomLabel.text = String(localized: "chat_paused")
                loadingView.enableProgressView = false

                acceptButton.hidden = true
                cancelButton.hidden = false
                cancelToAcceptConstraint.deactivate()
                cancelToBorderConstraint.activate()
            case .Cancelled:
                loadingView.setCancelledImage()
                loadingView.button.setImage(nil, forState: .Normal)
                loadingView.bottomLabel.text = String(localized: "chat_file_cancelled")
                loadingView.enableProgressView = false

                acceptButton.hidden = true
                cancelButton.hidden = true
            case .Done:
                setUti()
                loadingView.button.setImage(nil, forState: .Normal)
                loadingView.bottomLabel.text = nil
                loadingView.topLabel.textColor = theme.colorForType(.LinkText)
                loadingView.enableProgressView = false

                acceptButton.hidden = true
                cancelButton.hidden = true
                openButton.hidden = false
        }
    }

    override func createViews() {
        super.createViews()

        loadingView = LoadingFileView()
        loadingView.button.addTarget(self, action: "pauseButtonPressed", forControlEvents: .TouchUpInside)
        contentView.addSubview(loadingView)

        let acceptImage = UIImage.templateNamed("chat-file-download")
        acceptButton = UIButton()
        acceptButton.setImage(acceptImage, forState: .Normal)
        acceptButton.addTarget(self, action: "acceptButtonPressed", forControlEvents: .TouchUpInside)
        movableContentView.addSubview(acceptButton)

        let cancelImage = UIImage.templateNamed("chat-file-cancel")
        cancelButton = UIButton()
        cancelButton.setImage(cancelImage, forState: .Normal)
        cancelButton.addTarget(self, action: "cancelButtonPressed", forControlEvents: .TouchUpInside)
        movableContentView.addSubview(cancelButton)

        openButton = UIButton()
        openButton.addTarget(self, action: "openButtonPressed", forControlEvents: .TouchUpInside)
        contentView.addSubview(openButton)
    }

    override func installConstraints() {
        super.installConstraints()

        loadingView.snp_makeConstraints {
            $0.top.equalTo(contentView).offset(Constants.VerticalOffset)
            $0.bottom.equalTo(contentView).offset(-Constants.VerticalOffset)
            $0.left.equalTo(contentView).offset(Constants.BorderOffset)
            $0.right.lessThanOrEqualTo(contentView).offset(Constants.LoadingRightOffset)
        }

        acceptButton.snp_makeConstraints {
            $0.right.equalTo(movableContentView).offset(-Constants.ButtonOffset)
            $0.centerY.equalTo(movableContentView)
            $0.size.equalTo(Constants.ButtonSize)
        }

        cancelButton.snp_makeConstraints {
            cancelToAcceptConstraint = $0.right.equalTo(acceptButton.snp_left).offset(-Constants.ButtonOffset).constraint
            $0.centerY.equalTo(movableContentView)
            $0.size.equalTo(Constants.ButtonSize)
        }
        cancelToAcceptConstraint.deactivate()

        cancelButton.snp_makeConstraints {
            cancelToBorderConstraint = $0.right.equalTo(movableContentView).offset(-Constants.ButtonOffset).constraint
        }
        cancelToBorderConstraint.deactivate()

        openButton.snp_makeConstraints {
            $0.edges.equalTo(self)
        }
    }

    override func updateProgress(progress: CGFloat) {
        loadingView.progressView.progress = Float(progress)
    }

    override func updateEta(eta: String) {
        loadingView.bottomLabel.text = eta
    }

    func pauseButtonPressed() {
        pauseOrResumeHandle?()
    }

    func acceptButtonPressed() {
        startLoadingHandle?()
    }

    func cancelButtonPressed() {
        cancelHandle?()
    }

    func openButtonPressed() {
        openHandle?()
    }
}
