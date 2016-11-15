// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
    
class OCTSubmanagerChatsMock: NSObject, OCTSubmanagerChats {
    func getOrCreateChat(with friend: OCTFriend!) -> OCTChat! {
        return OCTChat()
    }
    
    func removeMessages(_ messages: [OCTMessageAbstract]!) {
        // nop
    }
    
    func removeAllMessages(in chat: OCTChat!, removeChat: Bool) {
        // nop
    }
    
    public func sendMessage(to chat: OCTChat!,
            text: String!,
            type: OCTToxMessageType,
            successBlock userSuccessBlock: ((OCTMessageAbstract?) -> Void)!,
            failureBlock userFailureBlock: ((Error?) -> Void)!) {
        // nop
    }
    
    func setIsTyping(_ isTyping: Bool, in chat: OCTChat!) throws {
        // nop
    }
}
