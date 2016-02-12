//
//  StaticTableChatButtonsCellModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 24/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import Foundation

class StaticTableChatButtonsCellModel: StaticTableBaseCellModel {
    var chatButtonHandler: (Void -> Void)?
    var callButtonHandler: (Void -> Void)?
    var videoButtonHandler: (Void -> Void)?

    var chatButtonEnabled: Bool = true
    var callButtonEnabled: Bool = true
    var videoButtonEnabled: Bool = true
}
