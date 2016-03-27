//
//  LoadingFileView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit
import MobileCoreServices

private struct Constants {
    static let ImageSize = 30.0
    static let ImageViewTopOffset = 4.0
    static let Offset = 8.0
    static let LabelHeight = 22.0
    static let LabelsOffset = -4.0
    static let ButtonSize = 25.0
    static let ProgressBottomOffset = -10.0
    static let ProgressToButtonOffset = -50.0
    static let ProgressToBottomOffset = 5.0
    static let MaxWidth = 400.0
}

class LoadingFileView: UIView {
    var imageView: UIImageView!
    var topLabel: UILabel!
    var progressView: UIProgressView!
    var bottomLabel: UILabel!
    var button: UIButton!

    var enableProgressView: Bool = false {
        didSet {
            updateProgressAndBottomLabel()
        }
    }

    private var bottomNormalLeftConstraint: Constraint!
    private var progressViewToBottomConstraint: Constraint!

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clearColor()
        createViews()
        installConstraints()

        updateProgressAndBottomLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCancelledImage() {
        imageView.image = UIImage.templateNamed("chat-file-type-canceled")
    }

    func setImageWithUti(uti: String?, fileExtension: String?) {
        let imageName = imageNameWithUti(uti, fileExtension: fileExtension)
        imageView.image = UIImage.templateNamed(imageName)
    }

    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: Constants.MaxWidth, height: Constants.ImageSize)
    }

}

private extension LoadingFileView {
    func createViews() {
        imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        addSubview(imageView)

        topLabel = UILabel()
        topLabel.font = UIFont.systemFontOfSize(14.0)
        addSubview(topLabel)

        progressView = UIProgressView(progressViewStyle: .Default)
        addSubview(progressView)

        bottomLabel = UILabel()
        bottomLabel.font = UIFont.systemFontOfSize(14.0, weight: UIFontWeightLight)
        addSubview(bottomLabel)

        button = UIButton()
        addSubview(button)
    }

    func installConstraints() {
        snp_makeConstraints {
            $0.width.lessThanOrEqualTo(Constants.MaxWidth)
        }

        imageView.snp_makeConstraints {
            $0.top.equalTo(self).offset(Constants.ImageViewTopOffset)
            $0.left.equalTo(self)
            $0.size.equalTo(Constants.ImageSize)
        }

        topLabel.snp_makeConstraints {
            $0.top.equalTo(self)
            $0.left.equalTo(imageView.snp_right).offset(Constants.Offset)
            $0.height.equalTo(Constants.LabelHeight)
        }

        progressView.snp_makeConstraints {
            $0.bottom.equalTo(self).offset(Constants.ProgressBottomOffset)
            $0.left.equalTo(topLabel)
            $0.right.equalTo(button.snp_left).offset(Constants.ProgressToButtonOffset)
        }

        bottomLabel.snp_makeConstraints {
            $0.top.equalTo(topLabel.snp_bottom).offset(Constants.LabelsOffset)
            $0.bottom.equalTo(self)
            $0.height.equalTo(Constants.LabelHeight)

            bottomNormalLeftConstraint = $0.left.equalTo(topLabel).constraint
        }
        bottomNormalLeftConstraint.deactivate()

        bottomLabel.snp_makeConstraints {
            progressViewToBottomConstraint = $0.left.equalTo(progressView.snp_right).offset(Constants.ProgressToBottomOffset).constraint
        }
        progressViewToBottomConstraint.deactivate()

        button.snp_makeConstraints {
            $0.centerY.equalTo(self)
            $0.left.equalTo(topLabel.snp_right).offset(Constants.Offset)
            $0.right.equalTo(self)
            $0.size.equalTo(Constants.ButtonSize)
        }
    }

    func updateProgressAndBottomLabel() {
        if enableProgressView {
            progressView.hidden = false
            bottomNormalLeftConstraint.deactivate()
            progressViewToBottomConstraint.activate()
        }
        else {
            progressView.hidden = true
            progressViewToBottomConstraint.deactivate()
            bottomNormalLeftConstraint.activate()
        }
    }

    func imageNameWithUti(uti: String?, fileExtension: String?) -> String {
        guard let uti = uti else {
            return "chat-file-type-basic"
        }

        if UTTypeEqual(uti, kUTTypeGIF) {
            return "chat-file-type-gif"
        }
        else if UTTypeEqual(uti, kUTTypeHTML) {
            return "chat-file-type-html"
        }
        else if UTTypeEqual(uti, kUTTypeJPEG) {
            return "chat-file-type-jpg"
        }
        else if UTTypeEqual(uti, kUTTypeMP3) {
            return "chat-file-type-mp3"
        }
        else if UTTypeEqual(uti, kUTTypeMPEG) {
            return "chat-file-type-mpg"
        }
        else if UTTypeEqual(uti, kUTTypeMPEG4) {
            return "chat-file-type-mpg"
        }
        else if UTTypeEqual(uti, kUTTypePDF) {
            return "chat-file-type-pdf"
        }
        else if UTTypeEqual(uti, kUTTypePNG) {
            return "chat-file-type-png"
        }
        else if UTTypeEqual(uti, kUTTypeTIFF) {
            return "chat-file-type-tif"
        }
        else if UTTypeEqual(uti, kUTTypePlainText) {
            return "chat-file-type-txt"
        }

        guard let fileExtension = fileExtension else {
            return "chat-file-type-basic"
        }

        switch fileExtension {
            case "7z":
                return "chat-file-type-7zip"
            case "aac":
                return "chat-file-type-aac"
            case "avi":
                return "chat-file-type-avi"
            case "css":
                return "chat-file-type-css"
            case "csv":
                return "chat-file-type-csv"
            case "doc":
                return "chat-file-type-doc"
            case "ebup":
                return "chat-file-type-ebup"
            case "exe":
                return "chat-file-type-exe"
            case "fb2":
                return "chat-file-type-fb2"
            case "flv":
                return "chat-file-type-flv"
            case "mov":
                return "chat-file-type-mov"
            case "ogg":
                return "chat-file-type-ogg"
            case "otf":
                return "chat-file-type-otf"
            case "ppt":
                return "chat-file-type-ppt"
            case "psd":
                return "chat-file-type-psd"
            case "rar":
                return "chat-file-type-rar"
            case "tar":
                return "chat-file-type-tar"
            case "ttf":
                return "chat-file-type-ttf"
            case "wav":
                return "chat-file-type-wav"
            case "wma":
                return "chat-file-type-wma"
            case "xls":
                return "chat-file-type-xls"
            case "zip":
                return "chat-file-type-zip"
            default:
                return "chat-file-type-basic"
        }
    }
}
