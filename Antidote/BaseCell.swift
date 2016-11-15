// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
    func setupWithTheme(_ theme: Theme, model: BaseCellModel) {}

    /**
        Override this method in subclass.
     */
    func createViews() {}

    /**
        Override this method in subclass.
     */
    func installConstraints() {}
}
