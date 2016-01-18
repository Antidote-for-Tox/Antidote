//
//  TabBarProfileItem.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 17.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit
import SnapKit

class TabBarProfileItem: TabBarAbstractItem {
    override var selected: Bool {
        didSet {
            imageViewWithStatus.imageView.tintColor = theme.colorForType(selected ? .TabItemActive : .TabItemInactive)
        }
    }

    var userStatus: UserStatus = .Offline {
        didSet {
            imageViewWithStatus.userStatusView.userStatus = userStatus
        }
    }

    private let theme: Theme

    private var imageViewWithStatus: ImageViewWithStatus!
    private var button: UIButton!

    init(theme: Theme) {
        self.theme = theme

        super.init(frame: CGRectZero)

        backgroundColor = .clearColor()

        createViews()
        installConstraints()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Actions
extension TabBarProfileItem {
    func buttonPressed() {
        didTapHandler?()
    }
}

private extension TabBarProfileItem {
    func createViews() {

        imageViewWithStatus = ImageViewWithStatus()
        imageViewWithStatus.imageView.image = UIImage(named: "tab-bar-profile")!.imageWithRenderingMode(.AlwaysTemplate)
        imageViewWithStatus.userStatusView.theme = theme
        addSubview(imageViewWithStatus)

        button = UIButton()
        button.backgroundColor = .clearColor()
        button.addTarget(self, action: "buttonPressed", forControlEvents: .TouchUpInside)
        addSubview(button)
    }

    func installConstraints() {
        imageViewWithStatus.snp_makeConstraints {
            $0.center.equalTo(self)
        }

        button.snp_makeConstraints {
            $0.edges.equalTo(self)
        }
    }
}

