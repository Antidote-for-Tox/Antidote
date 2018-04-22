// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation

private class BlockWrapper<T> {
    let block: T

    init(block: T) {
        self.block = block
    }
}

extension Timer {
    static func scheduledTimerWithTimeInterval(_ interval: TimeInterval, block: (Timer) -> Void, repeats: Bool) -> Timer {
        let userInfo = BlockWrapper(block: block)

        return scheduledTimer(timeInterval: interval, target: self, selector: #selector(Timer.executeBlock(_:)), userInfo: userInfo, repeats: repeats)
    }

    @objc static func executeBlock(_ timer: Timer) {
        guard let wrapper = timer.userInfo as? BlockWrapper<(Timer) -> Void> else {
            return
        }

        wrapper.block(timer)
    }
}
