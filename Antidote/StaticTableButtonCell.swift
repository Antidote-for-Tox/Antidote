//
//  StaticTableButtonCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class StaticTableButtonCell: UITableViewCell {
    func setupWithModel(model: StaticTableButtonModel) {
        textLabel?.text = model.title
    }
}
