//
//  CallCoordinator.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class CallCoordinator: NSObject {
    private let theme: Theme
    private weak var presentingController: UIViewController!

    init(theme: Theme, presentingController: UIViewController, submanagerCalls: OCTSubmanagerCalls, submanagerObjects: OCTSubmanagerObjects) {
        self.theme = theme
        self.presentingController = presentingController

        super.init()
    }

    func callToChat(chat: OCTChat, enableVideo: Bool) {
        let friend = chat.friends.lastObject() as! OCTFriend

        let controller = CallIncomingController(theme: theme, callerName: friend.nickname)

        let navigation = UINavigationController(rootViewController: controller)
        navigation.modalPresentationStyle = .OverCurrentContext
        navigation.navigationBarHidden = true

        presentingController.presentViewController(navigation, animated: false, completion: nil)
    }
}

extension CallCoordinator: CoordinatorProtocol {
    func startWithOptions(options: CoordinatorOptions?) {
    }
}
