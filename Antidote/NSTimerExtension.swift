//
//  NSTimerExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 20.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

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

        return scheduledTimerWithTimeInterval(interval, target: self, selector: "executeBlock:", userInfo: userInfo, repeats: repeats)
    }

    static func executeBlock(timer: NSTimer) {
        guard let wrapper = timer.userInfo as? BlockWrapper<NSTimer -> Void> else {
            return
        }

        wrapper.block(timer)
    }
}
