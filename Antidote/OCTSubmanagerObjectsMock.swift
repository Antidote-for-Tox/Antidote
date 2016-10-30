// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class OCTSubmanagerObjectsMock: NSObject, OCTSubmanagerObjects {
    var genericSettingsData: NSData? = nil
    let realm: RLMRealm 

    init(realm: RLMRealm) {
        self.realm = realm

        super.init()
    }
    
    func objectsForType(type: OCTFetchRequestType, predicate: NSPredicate!) -> RLMResults! {
        switch type {
            case .Friend:
                return OCTFriend.objectsInRealm(realm, withPredicate: predicate)
            case .FriendRequest:
                return OCTFriendRequest.objectsInRealm(realm, withPredicate: predicate)
            case .Chat:
                return OCTChat.objectsInRealm(realm, withPredicate: predicate)
            case .Call:
                return OCTCall.objectsInRealm(realm, withPredicate: predicate)
            case .MessageAbstract:
                return OCTMessageAbstract.objectsInRealm(realm, withPredicate: predicate)
        }
    }
    
    func objectWithUniqueIdentifier(uniqueIdentifier: String!, forType type: OCTFetchRequestType) -> OCTObject! {
        switch type {
            case .Friend:
                return OCTFriend(inRealm: realm, forPrimaryKey: uniqueIdentifier)
            case .FriendRequest:
                return OCTFriendRequest(inRealm: realm, forPrimaryKey: uniqueIdentifier)
            case .Chat:
                return OCTChat(inRealm: realm, forPrimaryKey: uniqueIdentifier)
            case .Call:
                return OCTCall(inRealm: realm, forPrimaryKey: uniqueIdentifier)
            case .MessageAbstract:
                return OCTMessageAbstract(inRealm: realm, forPrimaryKey: uniqueIdentifier)
        }
    }
    
    func changeFriend(friend: OCTFriend!, nickname: String!) {
        // nop
    }
    
    func changeChat(chat: OCTChat!, enteredText: String!) {
        // nop
    }
    
    func changeChat(chat: OCTChat!, lastReadDateInterval: NSTimeInterval) {
        // nop
    }
}
