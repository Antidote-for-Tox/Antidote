//
//  CallCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class CallCoordinator: NSObject {
    init(theme: Theme, presentingController: UIViewController, submanagerCalls: OCTSubmanagerCalls, submanagerObjects: OCTSubmanagerObjects) {
        super.init()
    }

    func callToChat(chat: OCTChat, enableVideo: Bool) {

    }
}

extension CallCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {

    }
}
