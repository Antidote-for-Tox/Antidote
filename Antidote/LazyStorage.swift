//
//  LazyStorage.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 03.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

class LazyStorage<ItemType> {
    private var storage: ItemType?
    private let createBlock: Void -> ItemType

    var object: ItemType {
        get {
            if storage == nil {
                storage = createBlock()
            }

            return storage!
        }
    }

    init(createBlock: Void -> ItemType) {
        self.createBlock = createBlock
    }

    func reset() {
        storage = nil
    }
}
