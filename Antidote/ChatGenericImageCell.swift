//
//  ChatGenericImageCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

class ChatGenericImageCell: ChatFileCell {
    var loadingView: LoadingImageView!
    var cancelButton: UIButton!

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
    }

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let imageModel = model as? ChatGenericImageCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        updateViewsWithState(imageModel.state, imageModel: imageModel)

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
    }

    override func createViews() {
        super.createViews()

        loadingView = LoadingImageView()
        loadingView.pressedHandle = loadingViewPressed

        let cancelImage = UIImage.templateNamed("chat-file-cancel")

        cancelButton = UIButton()
        cancelButton.setImage(cancelImage, forState: .Normal)
        cancelButton.addTarget(self, action: "cancelButtonPressed", forControlEvents: .TouchUpInside)
    }

    override func updateProgress(progress: CGFloat) {
        loadingView.progressView.progress = progress
    }

    override func updateEta(eta: String) {
        loadingView.bottomLabel.text = eta
    }

    func cancelButtonPressed() {
        cancelHandle?()
    }

    /// Override in subclass
    func updateViewsWithState(state: ChatFileCellModel.State, imageModel: ChatGenericImageCellModel) {}

    /// Override in subclass
    func loadingViewPressed() {}
}
