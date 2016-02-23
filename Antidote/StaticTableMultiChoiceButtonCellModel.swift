//
//  StaticTableMultiChoiceButtonCellModel.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 22.02.16.
//  Copyright © 2016 dvor. All rights reserved.
//

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
