//
//  FriendListCellModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

class FriendListCellModel: BaseCellModel {
    var avatar: UIImage?

    var topText: String = ""
    var bottomText: String = ""
    var multilineBottomtext: Bool = false

    var status: UserStatus = .Offline
    var hideStatus: Bool = false
}
