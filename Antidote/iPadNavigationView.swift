//
//  iPadNavigationView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 28.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

private struct Constants {
    static let Width = 200.0
    static let Height = 34.0
    static let Offset = 12.0
}

class iPadNavigationView: UIView {
    var avatarView: ImageViewWithStatus!
    var label: UILabel!

    var didTapHandler: (Void -> Void)?

    private var button: UIButton!

    init(theme: Theme) {
        super.init(frame: CGRect(x: 0.0, y: 0.0, width: Constants.Width, height: Constants.Height))

        createViews(theme)
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension iPadNavigationView {
    func buttonPressed() {
        didTapHandler?()
    }
}

private extension iPadNavigationView {
    func createViews(theme: Theme) {
        avatarView = ImageViewWithStatus()
        avatarView.userStatusView.theme = theme
        addSubview(avatarView)

        label = UILabel()
        label.font = UIFont.systemFontOfSize(22.0)
        addSubview(label)

        button = UIButton()
        button.addTarget(self, action: "buttonPressed", forControlEvents: .TouchUpInside)
        addSubview(button)
    }

    func installConstraints() {
        avatarView.snp_makeConstraints {
            $0.top.equalTo(self)
            $0.left.equalTo(self)
            $0.size.equalTo(Constants.Height)
        }

        label.snp_makeConstraints {
            $0.left.equalTo(avatarView.snp_right).offset(Constants.Offset)
            $0.right.equalTo(self)
            $0.top.equalTo(self)
            $0.bottom.equalTo(self)
        }

        button.snp_makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}
