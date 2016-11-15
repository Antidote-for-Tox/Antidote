// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

protocol TopCoordinatorProtocol: CoordinatorProtocol {
    /**
        Handle local notification.

        - Parameters:
          - notification: Notification to handle
     */
    func handleLocalNotification(_ notification: UILocalNotification)

    /**
        Handle openURL request.

        - Parameters:
          - url: URL to handle.
     */
    func handleInboxURL(_ url: URL)
}
