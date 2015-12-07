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
    static let AvatarImageSize: CGFloat = 120.0
}

class StaticTableAvatarCell: UITableViewCell {
    private var model: StaticTableAvatarModel?

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
        self.model = model
    }
}

extension StaticTableAvatarCell {
    func buttonPressed() {
        model?.didTapOnAvatar?()
    }
}

private extension StaticTableAvatarCell {
    func createButton() {
        button = UIButton()
        button.layer.cornerRadius = Constants.AvatarImageSize
        button.layer.masksToBounds = true
        button.addTarget(self, action: "buttonPressed", forControlEvents: .TouchUpInside)
        contentView.addSubview(button)
    }

    func installConstraints() {
        button.snp_makeConstraints{ (make) -> Void in
            make.centerX.equalTo(contentView)
            make.top.bottom.equalTo(contentView)
            make.size.equalTo(Constants.AvatarImageSize)
        }
    }
}
