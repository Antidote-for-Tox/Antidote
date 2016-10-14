// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

class CellSnapshotTest: SnapshotBaseTest {
    func updateCellLayout(cell: UITableViewCell) {
        let size = cell.systemLayoutSizeFittingSize(CGSize(width: 320, height: 1000))
        cell.frame = CGRect(x: 0, y: 0, width: 320, height: size.height)

        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }
}
