//
//  IncompressibleView.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 19.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class IncompressibleView: UIView {
    var customIntrinsicContentSize: CGSize = CGSizeZero

    override func intrinsicContentSize() -> CGSize {
        return customIntrinsicContentSize
    }
}
