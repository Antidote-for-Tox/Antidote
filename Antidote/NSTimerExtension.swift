// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private class ClosureWrapper<T> {
    let closure: T

    init(closure: T) {
        self.closure = closure
    }
}

extension Timer {
    static func scheduledTimer(timeInterval interval: TimeInterval, closure: (Timer) -> Void, repeats: Bool) -> Timer {
        let userInfo = ClosureWrapper(closure: closure)

        return scheduledTimer(timeInterval: interval, target: self, selector: #selector(Timer.executeBlock(_:)), userInfo: userInfo, repeats: repeats)
    }

    static func executeBlock(_ timer: Timer) {
        guard let wrapper = timer.userInfo as? ClosureWrapper<(Timer) -> Void> else {
            return
        }

        wrapper.closure(timer)
    }
}
