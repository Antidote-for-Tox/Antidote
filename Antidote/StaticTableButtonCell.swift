//
//  StaticTableButtonCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class StaticTableButtonCell: UITableViewCell {
    func setupWithTheme(theme: Theme, model: StaticTableButtonModel) {
        textLabel?.text = model.title

        textLabel?.textAlignment = .Center
        textLabel?.textColor = theme.colorForType(.NormalText)
    }
}
