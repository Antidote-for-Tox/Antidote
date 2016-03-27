//
//  StaticTableAvatarCellModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 03/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

class StaticTableAvatarCellModel: StaticTableBaseCellModel {
    struct Constants {
        static let AvatarImageSize: CGFloat = 120.0
    }

    var avatar: UIImage?
    var didTapOnAvatar: (StaticTableAvatarCell -> Void)?

    var userInteractionEnabled: Bool = true
}
