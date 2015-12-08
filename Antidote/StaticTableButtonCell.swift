//
//  StaticTableButtonCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class StaticTableButtonCell: StaticTableBaseCell {
    override func setupWithTheme(theme: Theme, model: StaticTableBaseModel) {
        super.setupWithTheme(theme, model: model)

        guard let buttonModel = model as? StaticTableButtonModel else {
            assert(false, "Wrong model \(model) passed to cell \(self)")
            return
        }

        textLabel?.text = buttonModel.title

        textLabel?.textAlignment = .Center
        textLabel?.textColor = theme.colorForType(.NormalText)
    }
}
