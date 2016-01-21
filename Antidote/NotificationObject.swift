//
//  NotificationObject.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 21/01/16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

enum NotificationAction {
    case OpenChat(chatUniqueIdentifier: String)
    case OpenRequests
}

extension NotificationAction {
    private struct Constants {
        static let ValueKey = "ValueKey"
        static let ArgumentKey = "ArgumentKey"

        static let OpenChatValue = "OpenChatValue"
        static let OpenRequestsValue = "OpenRequestsValue"
    }

    init?(dictionary: [String: String]) {
        guard let value = dictionary[Constants.ValueKey] else {
            return nil
        }

        switch value {
            case Constants.OpenChatValue:
                guard let argument = dictionary[Constants.ArgumentKey] else {
                    return nil
                }
                self = OpenChat(chatUniqueIdentifier: argument)
            case Constants.OpenRequestsValue:
                self = .OpenRequests
            default:
                return nil
        }
    }

    func archive() -> [String: String] {
        switch self {
            case .OpenChat(let identifier):
                return [
                    Constants.ValueKey: Constants.OpenChatValue,
                    Constants.ArgumentKey: identifier,
                ]
            case .OpenRequests:
                return [Constants.ValueKey: Constants.OpenRequestsValue]
        }
    }
}

struct NotificationObject {
    let image: UIImage
    let title: String
    let body: String
    let action: NotificationAction
}
