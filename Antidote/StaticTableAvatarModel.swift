//
//  StaticTableAvatarModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 03/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

class StaticTableAvatarModel: StaticTableBaseModel {
    struct Constants {
        static let AvatarImageSize: CGFloat = 120.0
    }

    var avatar: UIImage?
    var didTapOnAvatar: (Void -> Void)?

    var userInteractionEnabled: Bool = true
}
