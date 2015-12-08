//
//  StaticTableAvatarCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 03/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let AvatarVerticalOffset = 10.0
}

class StaticTableAvatarCell: StaticTableBaseCell {
    var didTapOnAvatar: (Void -> Void)?

    private var button: UIButton!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        createButton()
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupWithTheme(theme: Theme, model: StaticTableBaseModel) {
        super.setupWithTheme(theme, model: model)

        guard let avatarModel = model as? StaticTableAvatarModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        button.userInteractionEnabled = avatarModel.userInteractionEnabled
        button.setImage(avatarModel.avatar, forState: .Normal)
        didTapOnAvatar = avatarModel.didTapOnAvatar
    }
}

extension StaticTableAvatarCell {
    func buttonPressed() {
        didTapOnAvatar?()
    }
}

private extension StaticTableAvatarCell {
    func createButton() {
        button = UIButton()
        button.layer.cornerRadius = StaticTableAvatarModel.Constants.AvatarImageSize / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: "buttonPressed", forControlEvents: .TouchUpInside)
        contentView.addSubview(button)
    }

    func installConstraints() {
        button.snp_makeConstraints{ (make) -> Void in
            make.centerX.equalTo(contentView)
            make.top.equalTo(contentView).offset(Constants.AvatarVerticalOffset)
            make.bottom.equalTo(contentView).offset(-Constants.AvatarVerticalOffset)
            make.size.equalTo(StaticTableAvatarModel.Constants.AvatarImageSize)
        }
    }
}
