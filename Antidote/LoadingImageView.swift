//
//  LoadingImageView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 25.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

private struct Constants {
    static let ImageButtonSize = 180.0
    static let LabelHorizontalOffset = 12.0
    static let LabelBottomOffset = -6.0
    static let CenterImageSize = 50.0
    static let ProgressViewSize = 70.0
}

class LoadingImageView: UIView {
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
        imageButton.addTarget(self, action: "imageButtonPressed", forControlEvents: .TouchUpInside)
        addSubview(imageButton)

        centerImageView = UIImageView()
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
            $0.left.equalTo(self).offset(Constants.LabelHorizontalOffset)
            $0.right.lessThanOrEqualTo(self).offset(-Constants.LabelHorizontalOffset)
            $0.bottom.equalTo(bottomLabel.snp_top)
        }

        bottomLabel.snp_makeConstraints {
            $0.left.equalTo(self).offset(Constants.LabelHorizontalOffset)
            $0.right.lessThanOrEqualTo(self).offset(-Constants.LabelHorizontalOffset)
            $0.bottom.equalTo(self).offset(Constants.LabelBottomOffset)
        }
    }
}
