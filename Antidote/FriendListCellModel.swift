// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class FriendListCellModel: BaseCellModel {
    var avatar: UIImage?

    var topText: String = ""
    var bottomText: String = ""
    var multilineBottomtext: Bool = false

    var accessibilityLabel = ""
    var accessibilityValue = ""

    var status: UserStatus = .Offline
    var hideStatus: Bool = false
}
