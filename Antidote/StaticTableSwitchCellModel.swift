//
//  StaticTableSwitchCellModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class StaticTableSwitchCellModel: StaticTableBaseCellModel {
    var title: String?
    var on: Bool = false

    var valueChangedHandler: (Bool -> Void)?
}
