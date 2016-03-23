//
//  ChatIncomingImageCellModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.03.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class ChatIncomingImageCellModel: ChatMovableDateCellModel {
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
    var progress: CGFloat = 0.0

    var startLoadingHandle: (Void -> Void)?
    var cancelHandle: (Void -> Void)?
    var pauseOrResumeHandle: (Void -> Void)?
    var openHandle: (Void -> Void)?
}
