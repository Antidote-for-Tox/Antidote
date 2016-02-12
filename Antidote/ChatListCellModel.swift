//
//  ChatListCellModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 12/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class ChatListCellModel: BaseCellModel {
    var avatar: UIImage?

    var nickname: String = ""
    var message: String = ""
    var dateText: String = ""

    var status: UserStatus = .Offline

    var isUnread: Bool = false
}
