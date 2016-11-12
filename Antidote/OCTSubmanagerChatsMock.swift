// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
    
class OCTSubmanagerChatsMock: NSObject, OCTSubmanagerChats {
    func getOrCreateChatWithFriend(friend: OCTFriend!) -> OCTChat! {
        return OCTChat()
    }
    
    func removeMessages(messages: [OCTMessageAbstract]!) {
        // nop
    }
    
    func removeAllMessagesInChat(chat: OCTChat!, removeChat: Bool) {
        // nop
    }
    
    func sendMessageToChat(chat: OCTChat!,
                           text: String!,
                           type: OCTToxMessageType,
                           successBlock: (OCTMessageAbstract! -> Void)!,
                           failureBlock: (NSError! -> Void)!) {
        // nop
    }
    
    func setIsTyping(isTyping: Bool, inChat chat: OCTChat!) throws {
        // nop
    }
}
