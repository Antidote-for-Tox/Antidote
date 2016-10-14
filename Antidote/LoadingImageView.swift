// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import MobileCoreServices

class LoadingImageView: UIView {
    struct Constants {
        static let ImageButtonSize: CGFloat = 180.0
        static let LabelHorizontalOffset = 12.0
        static let LabelBottomOffset = -6.0
        static let CenterImageSize = 50.0
        static let ProgressViewSize = 70.0
    }

    var imageButton: UIButton!
    var progressView: ProgressCircleView!
    var centerImageView: UIImageView!
    var topLabel: UILabel!
    var bottomLabel: UILabel!

    var pressedHandle: (Void -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clearColor()
        createViews()
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setCancelledImage() {
        centerImageView.image = UIImage.templateNamed("chat-file-type-canceled")
    }

    func setImageWithUti(uti: String?, fileExtension: String?) {
        let imageName = imageNameWithUti(uti, fileExtension: fileExtension)
        centerImageView.image = UIImage.templateNamed(imageName)
    }
}

extension LoadingImageView {
    func imageButtonPressed() {
        pressedHandle?()
    }
}

private extension LoadingImageView {
    func createViews() {
        imageButton = UIButton()
        imageButton.layer.cornerRadius = 12.0
        imageButton.clipsToBounds = true
        imageButton.addTarget(self, action: #selector(LoadingImageView.imageButtonPressed), forControlEvents: .TouchUpInside)
        addSubview(imageButton)

        centerImageView = UIImageView()
        centerImageView.contentMode = .Center
        addSubview(centerImageView)

        progressView = ProgressCircleView()
        progressView.userInteractionEnabled = false
        addSubview(progressView)

        topLabel = UILabel()
        topLabel.font = UIFont.systemFontOfSize(14.0)
        addSubview(topLabel)

        bottomLabel = UILabel()
        bottomLabel.font = UIFont.systemFontOfSize(14.0)
        addSubview(bottomLabel)
    }

    func installConstraints() {
        snp_makeConstraints {
            $0.size.equalTo(Constants.ImageButtonSize)
        }

        imageButton.snp_makeConstraints {
            $0.edges.equalTo(self)
        }

        centerImageView.snp_makeConstraints {
            $0.center.equalTo(self)
            $0.size.equalTo(Constants.CenterImageSize)
        }

        progressView.snp_makeConstraints {
            $0.center.equalTo(self)
            $0.size.equalTo(Constants.ProgressViewSize)
        }

        topLabel.snp_makeConstraints {
            $0.leading.equalTo(self).offset(Constants.LabelHorizontalOffset)
            $0.trailing.lessThanOrEqualTo(self).offset(-Constants.LabelHorizontalOffset)
            $0.bottom.equalTo(bottomLabel.snp_top)
        }

        bottomLabel.snp_makeConstraints {
            $0.leading.equalTo(self).offset(Constants.LabelHorizontalOffset)
            $0.trailing.lessThanOrEqualTo(self).offset(-Constants.LabelHorizontalOffset)
            $0.bottom.equalTo(self).offset(Constants.LabelBottomOffset)
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
