//
//  StaticTableAvatarCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 03/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit
import SnapKit

class StaticTableAvatarCell: UITableViewCell {
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

    func setupWithTheme(theme: Theme, model: StaticTableAvatarModel) {
        button.userInteractionEnabled = model.userInteractionEnabled
        button.setImage(model.avatar, forState: .Normal)
        didTapOnAvatar = model.didTapOnAvatar
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
            make.top.bottom.equalTo(contentView)
            make.size.equalTo(StaticTableAvatarModel.Constants.AvatarImageSize)
        }
    }
}
