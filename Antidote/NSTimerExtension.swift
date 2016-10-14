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

extension NSTimer {
    static func scheduledTimerWithTimeInterval(interval: NSTimeInterval, block: NSTimer -> Void, repeats: Bool) -> NSTimer {
        let userInfo = BlockWrapper(block: block)

        return scheduledTimerWithTimeInterval(interval, target: self, selector: #selector(NSTimer.executeBlock(_:)), userInfo: userInfo, repeats: repeats)
    }

    static func executeBlock(timer: NSTimer) {
        guard let wrapper = timer.userInfo as? BlockWrapper<NSTimer -> Void> else {
            return
        }

        wrapper.block(timer)
    }
}
