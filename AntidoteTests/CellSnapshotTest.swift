//
//  CellSnapshotTest.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.04.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class CellSnapshotTest: SnapshotBaseTest {
    func updateCellLayout(cell: UITableViewCell) {
        let size = cell.systemLayoutSizeFittingSize(CGSize(width: 320, height: 1000))
        cell.frame = CGRect(x: 0, y: 0, width: 320, height: size.height)

        cell.setNeedsLayout()
        cell.layoutIfNeeded()
    }
}
