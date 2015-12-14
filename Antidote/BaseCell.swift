//
//  BaseCell.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 14/12/15.
//  Copyright © 2015 dvor. All rights reserved.
//

import UIKit

class BaseCell: UITableViewCell {
    static var staticReuseIdentifier: String {
        get {
            return NSStringFromClass(self)
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        createViews()
        installConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
        Override this method in subclass.
     */
    func setupWithTheme(theme: Theme, model: BaseCellModel) {}

    /**
        Override this method in subclass.
     */
    func createViews() {}

    /**
        Override this method in subclass.
     */
    func installConstraints() {}

}
