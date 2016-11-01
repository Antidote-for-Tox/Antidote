// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class OCTSubmanagerFriendsMock: NSObject, OCTSubmanagerFriends {
    func sendFriendRequestToAddress(address: String!, message: String!) throws {
        // nop
    }
    
    func approveFriendRequest(friendRequest: OCTFriendRequest!) throws {
        // nop
    }
    
    func removeFriendRequest(friendRequest: OCTFriendRequest!) {
        // nop
    }
    
    func removeFriend(friend: OCTFriend!) throws {
        // nop
    }
}
