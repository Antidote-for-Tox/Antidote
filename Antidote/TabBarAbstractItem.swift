//
//  TabBarAbstractItem.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 17.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import UIKit

class TabBarAbstractItem: UIView {
    var selected: Bool = false
    var didTapHandler: (Void -> Void)?
}
