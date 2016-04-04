//
//  ChatListCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 12/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

class ChatListCell: BaseCell {
    struct Constants {
        static let AvatarSize = 40.0
        static let AvatarLeftOffset = 10.0
        static let AvatarRightOffset = 16.0

        static let NicknameLabelHeight = 22.0
        static let MessageLabelHeight = 22.0

        static let NicknameToDateMinOffset = 5.0
        static let DateToArrowOffset = 5.0

        static let RightOffset = -7.0
        static let VerticalOffset = 3.0
    }

    private var avatarView: ImageViewWithStatus!
    private var nicknameLabel: UILabel!
    private var messageLabel: UILabel!
    private var dateLabel: UILabel!
    private var arrowImageView: UIImageView!

    override func setupWithTheme(theme: Theme, model: BaseCellModel) {
        super.setupWithTheme(theme, model: model)

        guard let chatModel = model as? ChatListCellModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        separatorInset.left = CGFloat(Constants.AvatarLeftOffset + Constants.AvatarSize + Constants.AvatarRightOffset)

        avatarView.imageView.image = chatModel.avatar
        avatarView.userStatusView.theme = theme
        avatarView.userStatusView.userStatus = chatModel.status

        nicknameLabel.text = chatModel.nickname
        nicknameLabel.textColor = theme.colorForType(.NormalText)

        messageLabel.text = chatModel.message
        messageLabel.textColor = theme.colorForType(.ChatListCellMessage)

        dateLabel.text = chatModel.dateText
        dateLabel.textColor = theme.colorForType(.ChatListCellMessage)

        backgroundColor = chatModel.isUnread ? theme.colorForType(.ChatListCellUnreadBackground) : .clearColor()
    }

    override func createViews() {
        super.createViews()

        avatarView = ImageViewWithStatus()
        contentView.addSubview(avatarView)

        nicknameLabel = UILabel()
        nicknameLabel.font = UIFont.systemFontOfSize(18.0)
        contentView.addSubview(nicknameLabel)

        messageLabel = UILabel()
        messageLabel.font = UIFont.systemFontOfSize(12.0)
        contentView.addSubview(messageLabel)

        dateLabel = UILabel()
        dateLabel.font = UIFont.antidoteFontWithSize(12.0, weight: .Light)
        contentView.addSubview(dateLabel)

        let image = UIImage(named: "right-arrow")!
        arrowImageView = UIImageView(image: image)
        arrowImageView.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
        contentView.addSubview(arrowImageView)
    }

    override func installConstraints() {
        super.installConstraints()

        avatarView.snp_makeConstraints {
            $0.left.equalTo(contentView).offset(Constants.AvatarLeftOffset)
            $0.centerY.equalTo(contentView)
            $0.size.equalTo(Constants.AvatarSize)
        }

        nicknameLabel.snp_makeConstraints {
            $0.left.equalTo(avatarView.snp_right).offset(Constants.AvatarRightOffset)
            $0.top.equalTo(contentView).offset(Constants.VerticalOffset)
            $0.height.equalTo(Constants.NicknameLabelHeight)
        }

        messageLabel.snp_makeConstraints {
            $0.left.equalTo(nicknameLabel)
            $0.right.equalTo(contentView).offset(Constants.RightOffset)
            $0.top.equalTo(nicknameLabel.snp_bottom)
            $0.bottom.equalTo(contentView).offset(-Constants.VerticalOffset)
            $0.height.equalTo(Constants.MessageLabelHeight)
        }

        dateLabel.snp_makeConstraints {
            $0.left.greaterThanOrEqualTo(nicknameLabel.snp_right).offset(Constants.NicknameToDateMinOffset)
            $0.top.equalTo(nicknameLabel)
            $0.height.equalTo(nicknameLabel)
        }

        arrowImageView.snp_makeConstraints {
            $0.centerY.equalTo(dateLabel)
            $0.left.greaterThanOrEqualTo(dateLabel.snp_right).offset(Constants.DateToArrowOffset)
            $0.right.equalTo(contentView).offset(Constants.RightOffset)
        }
    }
}
