// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import MobileCoreServices

private enum Gender {
    case male
    case female
}

class OCTManagerMock: NSObject, OCTManager {
    var bootstrap: OCTSubmanagerBootstrap
    var calls: OCTSubmanagerCalls
    var chats: OCTSubmanagerChats
    var files: OCTSubmanagerFiles
    var friends: OCTSubmanagerFriends
    var objects: OCTSubmanagerObjects
    var user: OCTSubmanagerUser

    var realm: RLMRealm

    override init() {
        let configuration = RLMRealmConfiguration.default()
        configuration.inMemoryIdentifier = "test realm"
        realm = try! RLMRealm(configuration: configuration)

        bootstrap = OCTSubmanagerBootstrapMock()
        calls = OCTSubmanagerCallsMock()
        chats = OCTSubmanagerChatsMock()
        files = OCTSubmanagerFilesMock()
        friends = OCTSubmanagerFriendsMock()
        objects = OCTSubmanagerObjectsMock(realm: realm)
        user = OCTSubmanagerUserMock()

        super.init()

        populateRealm()
    }
    
    func configuration() -> OCTManagerConfiguration {
        return OCTManagerConfiguration()
    }
    
    func exportToxSaveFile() throws -> String {
        return "123"
    }
    
    func changeEncryptPassword(_ newPassword: String, oldPassword: String) -> Bool {
        return true
    }
    
    func isManagerEncrypted(withPassword password: String) -> Bool {
        return true
    }
}

private extension OCTManagerMock {
    func populateRealm() {
        realm.beginWriteTransaction()

        let f1 = addFriend(gender: .female, number: 1, connectionStatus: .TCP, status: .none)
        let f2 = addFriend(gender: .male, number: 1, connectionStatus: .TCP, status: .busy)
        let f3 = addFriend(gender: .female, number: 2, connectionStatus: .none, status: .none)
        let f4 = addFriend(gender: .male, number: 2, connectionStatus: .TCP, status: .away)
        let f5 = addFriend(gender: .male, number: 3, connectionStatus: .TCP, status: .none)
        let f6 = addFriend(gender: .female, number: 3, connectionStatus: .TCP, status: .away)
        let f7 = addFriend(gender: .male, number: 4, connectionStatus: .TCP, status: .away)
        let f8 = addFriend(gender: .female, number: 4, connectionStatus: .none, status: .none)
        let f9 = addFriend(gender: .female, number: 5, connectionStatus: .TCP, status: .none)
        let f10 = addFriend(gender: .male, number: 5, connectionStatus: .none, status: .none)

        let c1 = addChat(friend: f1)
        let c2 = addChat(friend: f2)
        let c3 = addChat(friend: f3)
        let c4 = addChat(friend: f4)
        let c5 = addChat(friend: f5)
        let c6 = addChat(friend: f6)
        let c7 = addChat(friend: f7)
        let c8 = addChat(friend: f8)
        let c9 = addChat(friend: f9)
        let c10 = addChat(friend: f10)

        addDemoConversationToChat(c1)
        addCallMessage(chat: c2, outgoing: false, answered: false, duration: 0.0)
        addTextMessage(chat: c3, outgoing: false, text: String(localized: "app_store_screenshot_chat_message_1"))
        addCallMessage(chat: c4, outgoing: true, answered: true, duration: 1473.0)
        addTextMessage(chat: c5, outgoing: false, text: String(localized: "app_store_screenshot_chat_message_2"))
        addFileMessage(chat: c6, outgoing: false, fileName: "party.png")
        addTextMessage(chat: c7, outgoing: true, text: String(localized: "app_store_screenshot_chat_message_3"))
        addTextMessage(chat: c8, outgoing: true, text: String(localized: "app_store_screenshot_chat_message_4"))
        addFileMessage(chat: c9, outgoing: true, fileName: "presentation_2016.pdf")
        addTextMessage(chat: c10, outgoing: false, text: String(localized: "app_store_screenshot_chat_message_5"))

        c1.lastReadDateInterval = Date().timeIntervalSince1970
        // unread message
        // c2.lastReadDateInterval = NSDate().timeIntervalSince1970
        c3.lastReadDateInterval = Date().timeIntervalSince1970
        c4.lastReadDateInterval = Date().timeIntervalSince1970
        c5.lastReadDateInterval = Date().timeIntervalSince1970
        c6.lastReadDateInterval = Date().timeIntervalSince1970
        c7.lastReadDateInterval = Date().timeIntervalSince1970
        c8.lastReadDateInterval = Date().timeIntervalSince1970
        c9.lastReadDateInterval = Date().timeIntervalSince1970
        c10.lastReadDateInterval = Date().timeIntervalSince1970

        try! realm.commitWriteTransaction()
    }

    func addFriend(gender: Gender,
                   number: Int,
                   connectionStatus: OCTToxConnectionStatus,
                   status: OCTToxUserStatus) -> OCTFriend {
        let friend = OCTFriend()
        friend.publicKey = "123"
        friend.connectionStatus = connectionStatus
        friend.isConnected = connectionStatus != .none
        friend.status = status

        switch gender {
            case .male:
                friend.nickname = String(localized: "app_store_screenshot_friend_male_\(number)")
                friend.avatarData = UIImagePNGRepresentation(UIImage(named: "male-\(number)")!)
            case .female:
                friend.nickname = String(localized: "app_store_screenshot_friend_female_\(number)")
                friend.avatarData = UIImagePNGRepresentation(UIImage(named: "female-\(number)")!)
        }
        
        realm.add(friend)

        return friend
    }

    func addChat(friend: OCTFriend) -> OCTChat {
        let chat = OCTChat()

        realm.add(chat)
        chat.friends.add(friend)

        return chat
    }

    func addDemoConversationToChat(_ chat: OCTChat) {
        addFileMessage(chat: chat, outgoing: false, fileName: "party.png")
        addTextMessage(chat: chat, outgoing: true, text: String(localized: "app_store_screenshot_conversation_1"))
        addTextMessage(chat: chat, outgoing: false, text: String(localized: "app_store_screenshot_conversation_2"))
        addTextMessage(chat: chat, outgoing: true, text: String(localized: "app_store_screenshot_conversation_3"))
        addTextMessage(chat: chat, outgoing: false, text: String(localized: "app_store_screenshot_conversation_4"))
        addTextMessage(chat: chat, outgoing: false, text: String(localized: "app_store_screenshot_conversation_5"))
        addTextMessage(chat: chat, outgoing: true, text: String(localized: "app_store_screenshot_conversation_6"))
        addTextMessage(chat: chat, outgoing: true, text: String(localized: "app_store_screenshot_conversation_7"))
    }

    func addTextMessage(chat: OCTChat, outgoing: Bool, text: String) {
        let messageText = OCTMessageText()
        messageText.text = text
        messageText.isDelivered = outgoing

        let message = addMessageAbstract(chat: chat, outgoing: outgoing)
        message.messageText = messageText
    }

    func addFileMessage(chat: OCTChat, outgoing: Bool, fileName: String) {
        let messageFile = OCTMessageFile()
        messageFile.fileName = fileName
        messageFile.internalFilePath = Bundle.main.path(forResource: "dummy-photo", ofType: "jpg")
        messageFile.fileType = .ready
        messageFile.fileUTI = kUTTypeImage as String

        let message = addMessageAbstract(chat: chat, outgoing: outgoing)
        message.messageFile = messageFile
    }

    func addCallMessage(chat: OCTChat, outgoing: Bool, answered: Bool, duration: TimeInterval) {
        let messageCall = OCTMessageCall()
        messageCall.callDuration = duration
        messageCall.callEvent = answered ? .answered : .unanswered

        let message = addMessageAbstract(chat: chat, outgoing: outgoing)
        message.messageCall = messageCall
    }

    func addMessageAbstract(chat: OCTChat, outgoing: Bool) -> OCTMessageAbstract {
        let message = OCTMessageAbstract()
        if !outgoing {
            let friend = chat.friends.firstObject() as! OCTFriend
            message.senderUniqueIdentifier = friend.uniqueIdentifier
        }
        message.chatUniqueIdentifier = chat.uniqueIdentifier
        message.dateInterval = Date().timeIntervalSince1970

        realm.add(message)
        chat.lastMessage = message

        return message
    }
}
