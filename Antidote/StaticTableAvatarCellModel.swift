// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class StaticTableAvatarCellModel: StaticTableBaseCellModel {
    struct Constants {
        static let AvatarImageSize: CGFloat = 120.0
    }

    var avatar: UIImage?
    var didTapOnAvatar: ((StaticTableAvatarCell) -> Void)?

    var userInteractionEnabled: Bool = true
}
