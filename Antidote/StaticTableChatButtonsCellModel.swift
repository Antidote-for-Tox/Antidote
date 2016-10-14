// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class StaticTableChatButtonsCellModel: StaticTableBaseCellModel {
    var chatButtonHandler: (Void -> Void)?
    var callButtonHandler: (Void -> Void)?
    var videoButtonHandler: (Void -> Void)?

    var chatButtonEnabled: Bool = true
    var callButtonEnabled: Bool = true
    var videoButtonEnabled: Bool = true
}
