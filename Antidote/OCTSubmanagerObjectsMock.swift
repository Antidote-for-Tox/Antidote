// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
    
class OCTSubmanagerObjectsMock: NSObject, OCTSubmanagerObjects {
    var genericSettingsData: Data? = nil
    let realm: RLMRealm 

    init(realm: RLMRealm) {
        self.realm = realm

        super.init()
    }
    
    func objects(for type: OCTFetchRequestType, predicate: NSPredicate!) -> RLMResults<AnyObject>! {
        switch type {
            case .friend:
                return OCTFriend.objects(in: realm, with: predicate)
            case .friendRequest:
                return OCTFriendRequest.objects(in: realm, with: predicate)
            case .chat:
                return OCTChat.objects(in: realm, with: predicate)
            case .call:
                return OCTCall.objects(in: realm, with: predicate)
            case .messageAbstract:
                return OCTMessageAbstract.objects(in: realm, with: predicate)
        }
    }
    
    func object(withUniqueIdentifier uniqueIdentifier: String!, for type: OCTFetchRequestType) -> OCTObject! {
        switch type {
            case .friend:
                return OCTFriend(in: realm, forPrimaryKey: uniqueIdentifier)
            case .friendRequest:
                return OCTFriendRequest(in: realm, forPrimaryKey: uniqueIdentifier)
            case .chat:
                return OCTChat(in: realm, forPrimaryKey: uniqueIdentifier)
            case .call:
                return OCTCall(in: realm, forPrimaryKey: uniqueIdentifier)
            case .messageAbstract:
                return OCTMessageAbstract(in: realm, forPrimaryKey: uniqueIdentifier)
        }
    }
    
    func change(_ friend: OCTFriend!, nickname: String!) {
        // nop
    }
    
    func change(_ chat: OCTChat!, enteredText: String!) {
        // nop
    }
    
    func change(_ chat: OCTChat!, lastReadDateInterval: TimeInterval) {
        // nop
    }
}
