//
//  LoginButton.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 10/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class LoginButton: UIButton {
    init(theme: Theme) {
        super.init(frame: CGRectZero)

        setTitleColor(theme.colorForType(.LoginButtonText), forState:UIControlState.Normal)
        titleLabel?.font = UIFont.systemFontOfSize(18.0)
        layer.cornerRadius = 5.0
        layer.masksToBounds = true

        let bgColor = theme.colorForType(.LoginButtonBackground)
        let bgImage = UIImage.imageWithColor(bgColor, size: CGSize(width: 1.0, height: 1.0))
        setBackgroundImage(bgImage, forState:UIControlState.Normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
