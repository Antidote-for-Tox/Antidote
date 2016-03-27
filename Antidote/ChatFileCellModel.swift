//
//  ChatFileCellModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 23.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class ChatFileCellModel: ChatMovableDateCellModel {
    enum State {
        case WaitingConfirmation
        case Loading
        case Paused
        case Cancelled
        case Done
    }

    var state: State = .WaitingConfirmation
    var fileName: String?
    var fileSize: String?
    var fileUTI: String?

    var startLoadingHandle: (Void -> Void)?
    var cancelHandle: (Void -> Void)?
    var pauseOrResumeHandle: (Void -> Void)?
    var openHandle: (Void -> Void)?
}
