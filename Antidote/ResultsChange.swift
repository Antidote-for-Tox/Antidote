// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

/// Swift wrapper for RLMResults addNotificationBlock.
enum ResultsChange<T: OCTObject> {
    case initial(Results<T>?)
    case update(Results<T>?, deletions: [Int], insertions: [Int], modifications: [Int])
    case error(NSError)
}
