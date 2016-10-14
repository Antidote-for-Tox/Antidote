// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import UIKit

class ActiveSessionNavigationCoordinator {
    let theme: Theme
    let navigationController: UINavigationController

    init(theme: Theme) {
        self.theme = theme
        self.navigationController = UINavigationController()
    }

    init(theme: Theme, navigationController: UINavigationController) {
        self.theme = theme
        self.navigationController = navigationController
    }

    func startWithOptions(options: CoordinatorOptions?) {
        preconditionFailure("This method must be overridden")
    }
}
