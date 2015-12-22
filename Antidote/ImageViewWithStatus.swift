//
//  ImageViewWithStatus.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 20/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let UserStatusViewSize = 8.0
    static let UserStatusViewOffset = -1.0
}

class ImageViewWithStatus: UIView {
    var imageView: UIImageView!
    var userStatusView: UserStatusView!

    init() {
        super.init(frame: CGRectZero)

        createViews()
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateCornerRadius()
    }
}

private extension ImageViewWithStatus {
    func createViews() {
        imageView = UIImageView()
        imageView.backgroundColor = UIColor.clearColor()
        imageView.layer.masksToBounds = true
        addSubview(imageView)

        userStatusView = UserStatusView()
        addSubview(userStatusView)
    }

    func installConstraints() {
        imageView.snp_makeConstraints{ (make) -> Void in
            make.edges.equalTo(self)
        }

        userStatusView.snp_makeConstraints{ (make) -> Void in
            make.right.equalTo(self).offset(Constants.UserStatusViewOffset)
            make.bottom.equalTo(self).offset(Constants.UserStatusViewOffset)
            make.size.equalTo(Constants.UserStatusViewSize)
        }
    }

    func updateCornerRadius() {
        imageView.layer.cornerRadius = frame.size.width / 2
    }
}
