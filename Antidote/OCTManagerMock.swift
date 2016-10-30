// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

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

        let f1 = addFriend(nickname: "Antony Mcleroy", connectionStatus: .TCP)
        let f2 = addFriend(nickname: "Robert Primm", connectionStatus: .None)
        let f3 = addFriend(nickname: "Joseph", connectionStatus: .None)
        let f4 = addFriend(nickname: "Willow Handt", connectionStatus: .TCP)
        let f5 = addFriend(nickname: "Fleur", connectionStatus: .None)

        let c1 = addChat(friend: f1)
        let c2 = addChat(friend: f2)
        let c3 = addChat(friend: f3)
        let c4 = addChat(friend: f4)
        let c5 = addChat(friend: f5)

        addDemoConversationToChat(c1)

        c1.lastReadDateInterval = NSDate().timeIntervalSince1970

        try! realm.commitWriteTransaction()
    }

    func addFriend(nickname nickname: String, connectionStatus: OCTToxConnectionStatus) -> OCTFriend {
        let friend = OCTFriend()
        friend.nickname = nickname
        friend.publicKey = "123"
        friend.connectionStatus = connectionStatus
        friend.isConnected = connectionStatus != .None
        
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
        addTextMessage(chat: chat, text: "Is Antidote really that secure?", outgoing: true)
        addTextMessage(chat: chat, text: "sure, it is peer-to-peer", outgoing: false)
        addTextMessage(chat: chat, text: "And what does that mean? Peer-to-peer? 😄", outgoing: true)
        addTextMessage(chat: chat, text: "you text me directly, the are no servers or things like that", outgoing: false)
        addTextMessage(chat: chat, text: "+ it's encrypted 🔐😎", outgoing: false)
        addTextMessage(chat: chat, text: "Cool!", outgoing: true)
        addTextMessage(chat: chat, text: "I'll give it a go then", outgoing: true)
    }

    func addTextMessage(chat chat: OCTChat, text: String, outgoing: Bool) {
        let messageText = OCTMessageText()
        messageText.text = text

        let message = OCTMessageAbstract()
        if !outgoing {
            let friend = chat.friends.firstObject() as! OCTFriend
            message.senderUniqueIdentifier = friend.uniqueIdentifier
        }
        message.chatUniqueIdentifier = chat.uniqueIdentifier
        message.messageText = messageText
        message.dateInterval = NSDate().timeIntervalSince1970

        realm.addObject(message)
        chat.lastMessage = message
    }
}
