// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class StaticTableMultiChoiceButtonCellModel: StaticTableBaseCellModel {
    enum ButtonStyle {
        case Negative
        case Positive
    }

    struct ButtonModel {
        let title: String
        let style: ButtonStyle
        let target: AnyObject?
        let action: Selector
    }

    var buttons = [ButtonModel]()
}
