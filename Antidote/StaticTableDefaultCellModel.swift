// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class StaticTableDefaultCellModel: StaticTableSelectableCellModel {
    enum RightImageType {
        case none
        case arrow
        case checkmark
    }

    var userStatus: UserStatus?

    var title: String?
    var value: String?

    var rightButton: String?
    var rightButtonHandler: ((Void) -> Void)?

    var rightImageType: RightImageType = .none

    var userInteractionEnabled: Bool = true

    var canCopyValue: Bool = false
}
