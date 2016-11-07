// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import MobileCoreServices

private enum Gender {
    case Male
    case Female
}

class OCTManagerMock: NSObject, OCTManager {
    var bootstrap: OCTSubmanagerBootstrap
    var calls: OCTSubmanagerCalls
    var chats: OCTSubmanagerChats
    var dns: OCTSubmanagerDNS
    var files: OCTSubmanagerFiles
    var friends: OCTSubmanagerFriends
    var objects: OCTSubmanagerObjects
    var user: OCTSubmanagerUser

    var realm: RLMRealm

    override init() {
        let configuration = RLMRealmConfiguration.defaultConfiguration()
        configuration.inMemoryIdentifier = "test realm"
        realm = try! RLMRealm(configuration: configuration)

        bootstrap = OCTSubmanagerBootstrapMock()
        calls = OCTSubmanagerCallsMock()
        chats = OCTSubmanagerChatsMock()
        dns = OCTSubmanagerDNSMock()
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
    
    func changeEncryptPassword(newPassword: String, oldPassword: String) -> Bool {
        return true
    }
    
    func isManagerEncryptedWithPassword(password: String) -> Bool {
        return true
    }
}

private extension OCTManagerMock {
    func populateRealm() {
        realm.beginWriteTransaction()

        let f1 = addFriend(gender: .Female, number: 1, connectionStatus: .TCP, status: .None)
        let f2 = addFriend(gender: .Male, number: 1, connectionStatus: .TCP, status: .Busy)
        let f3 = addFriend(gender: .Female, number: 2, connectionStatus: .None, status: .None)
        let f4 = addFriend(gender: .Male, number: 2, connectionStatus: .TCP, status: .Away)
        let f5 = addFriend(gender: .Male, number: 3, connectionStatus: .TCP, status: .None)
        let f6 = addFriend(gender: .Female, number: 3, connectionStatus: .TCP, status: .Away)
        let f7 = addFriend(gender: .Male, number: 4, connectionStatus: .TCP, status: .Away)
        let f8 = addFriend(gender: .Female, number: 4, connectionStatus: .None, status: .None)
        let f9 = addFriend(gender: .Female, number: 5, connectionStatus: .TCP, status: .None)
        let f10 = addFriend(gender: .Male, number: 5, connectionStatus: .None, status: .None)

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

        c1.lastReadDateInterval = NSDate().timeIntervalSince1970
        // unread message
        // c2.lastReadDateInterval = NSDate().timeIntervalSince1970
        c3.lastReadDateInterval = NSDate().timeIntervalSince1970
        c4.lastReadDateInterval = NSDate().timeIntervalSince1970
        c5.lastReadDateInterval = NSDate().timeIntervalSince1970
        c6.lastReadDateInterval = NSDate().timeIntervalSince1970
        c7.lastReadDateInterval = NSDate().timeIntervalSince1970
        c8.lastReadDateInterval = NSDate().timeIntervalSince1970
        c9.lastReadDateInterval = NSDate().timeIntervalSince1970
        c10.lastReadDateInterval = NSDate().timeIntervalSince1970

        try! realm.commitWriteTransaction()
    }

    func addFriend(gender gender: Gender,
                   number: Int,
                   connectionStatus: OCTToxConnectionStatus,
                   status: OCTToxUserStatus) -> OCTFriend {
        let friend = OCTFriend()
        friend.publicKey = "123"
        friend.connectionStatus = connectionStatus
        friend.isConnected = connectionStatus != .None
        friend.status = status

        switch gender {
            case .Male:
                friend.nickname = String(localized: "app_store_screenshot_friend_male_\(number)")
                friend.avatarData = UIImagePNGRepresentation(UIImage(named: "male-\(number)")!)
            case .Female:
                friend.nickname = String(localized: "app_store_screenshot_friend_female_\(number)")
                friend.avatarData = UIImagePNGRepresentation(UIImage(named: "female-\(number)")!)
        }
        
        realm.addObject(friend)

        return friend
    }

    func addChat(friend friend: OCTFriend) -> OCTChat {
        let chat = OCTChat()

        realm.addObject(chat)
        chat.friends.addObject(friend)

        return chat
    }

    func addDemoConversationToChat(chat: OCTChat) {
        addFileMessage(chat: chat, outgoing: false, fileName: "party.png")
        addTextMessage(chat: chat, outgoing: true, text: String(localized: "app_store_screenshot_conversation_1"))
        addTextMessage(chat: chat, outgoing: false, text: String(localized: "app_store_screenshot_conversation_2"))
        addTextMessage(chat: chat, outgoing: true, text: String(localized: "app_store_screenshot_conversation_3"))
        addTextMessage(chat: chat, outgoing: false, text: String(localized: "app_store_screenshot_conversation_4"))
        addTextMessage(chat: chat, outgoing: false, text: String(localized: "app_store_screenshot_conversation_5"))
        addTextMessage(chat: chat, outgoing: true, text: String(localized: "app_store_screenshot_conversation_6"))
        addTextMessage(chat: chat, outgoing: true, text: String(localized: "app_store_screenshot_conversation_7"))
    }

    func addTextMessage(chat chat: OCTChat, outgoing: Bool, text: String) {
        let messageText = OCTMessageText()
        messageText.text = text

        let message = addMessageAbstract(chat: chat, outgoing: outgoing)
        message.messageText = messageText
    }

    func addFileMessage(chat chat: OCTChat, outgoing: Bool, fileName: String) {
        let messageFile = OCTMessageFile()
        messageFile.fileName = fileName
        messageFile.internalFilePath = NSBundle.mainBundle().pathForResource("dummy-photo", ofType: "jpg")
        messageFile.fileType = .Ready
        messageFile.fileUTI = kUTTypeImage as String

        let message = addMessageAbstract(chat: chat, outgoing: outgoing)
        message.messageFile = messageFile
    }

    func addCallMessage(chat chat: OCTChat, outgoing: Bool, answered: Bool, duration: NSTimeInterval) {
        let messageCall = OCTMessageCall()
        messageCall.callDuration = duration
        messageCall.callEvent = answered ? .Answered : .Unanswered

        let message = addMessageAbstract(chat: chat, outgoing: outgoing)
        message.messageCall = messageCall
    }

    func addMessageAbstract(chat chat: OCTChat, outgoing: Bool) -> OCTMessageAbstract {
        let message = OCTMessageAbstract()
        if !outgoing {
            let friend = chat.friends.firstObject() as! OCTFriend
            message.senderUniqueIdentifier = friend.uniqueIdentifier
        }
        message.chatUniqueIdentifier = chat.uniqueIdentifier
        message.dateInterval = NSDate().timeIntervalSince1970

        realm.addObject(message)
        chat.lastMessage = message

        return message
    }
}
