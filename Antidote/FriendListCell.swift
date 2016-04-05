//
//  FriendListCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

class FriendListCell: BaseCell {
    struct Constants {
        static let AvatarSize = 30.0
        static let AvatarLeftOffset = 10.0
        static let AvatarRightOffset = 16.0

        static let TopLabelHeight = 22.0
        static let MinimumBottomLabelHeight = 15.0

        static let VerticalOffset = 3.0
    }

    private var avatarView: ImageViewWithStatus!
    private var topLabel: UILabel!
    private var bottomLabel: UILabel!
    private var arrowImageView: UIImageView!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let friendModel = model as? FriendListCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        separatorInset.left = CGFloat(Constants.AvatarLeftOffset + Constants.AvatarSize + Constants.AvatarRightOffset)

        avatarView.imageView.image = friendModel.avatar
        avatarView.userStatusView.theme = theme
        avatarView.userStatusView.userStatus = friendModel.status
        avatarView.userStatusView.hidden = friendModel.hideStatus

        topLabel.text = friendModel.topText
        topLabel.textColor = theme.colorForType(.NormalText)

        bottomLabel.text = friendModel.bottomText
        bottomLabel.textColor = theme.colorForType(.FriendCellStatus)
        bottomLabel.numberOfLines = friendModel.multilineBottomtext ? 0 : 1
    }

    override func createViews() {
        super.createViews()

        avatarView = ImageViewWithStatus()
        contentView.addSubview(avatarView)

        topLabel = UILabel()
        topLabel.font = UIFont.systemFontOfSize(18.0)
        contentView.addSubview(topLabel)

        bottomLabel = UILabel()
        bottomLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .Light)
        contentView.addSubview(bottomLabel)

        let image = UIImage(named: "right-arrow")!.flippedToCorrectLayout()
        arrowImageView = UIImageView(image: image)
        arrowImageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        contentView.addSubview(arrowImageView)
    }

    override func installConstraints() {
        super.installConstraints()

        avatarView.snp_makeConstraints {
            $0.leading.equalTo(contentView).offset(Constants.AvatarLeftOffset)
            $0.centerY.equalTo(contentView)
            $0.size.equalTo(Constants.AvatarSize)
        }

        topLabel.snp_makeConstraints {
            $0.leading.equalTo(avatarView.snp_trailing).offset(Constants.AvatarRightOffset)
            $0.top.equalTo(contentView).offset(Constants.VerticalOffset)
            $0.height.equalTo(Constants.TopLabelHeight)
        }

        bottomLabel.snp_makeConstraints {
            $0.leading.trailing.equalTo(topLabel)
            $0.top.equalTo(topLabel.snp_bottom)
            $0.bottom.equalTo(contentView).offset(-Constants.VerticalOffset)
            $0.height.greaterThanOrEqualTo(Constants.MinimumBottomLabelHeight)
        }

        arrowImageView.snp_makeConstraints {
            $0.centerY.equalTo(contentView)
            $0.leading.greaterThanOrEqualTo(topLabel.snp_trailing)
            $0.trailing.equalTo(contentView)
        }
    }
}
