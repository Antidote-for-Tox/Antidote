// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

typealias CoordinatorOptions = [String: Any]

protocol CoordinatorProtocol {
    /**
        This method will be called when coordinator should start working.

        - Parameters:
          - options: Options to start with. Options are used for recovering state of coordinator on recreation.
     */
    func startWithOptions(options: CoordinatorOptions?)
}
