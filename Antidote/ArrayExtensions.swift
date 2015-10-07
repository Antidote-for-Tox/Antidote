//
//  ArrayExtensions.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 07/10/15.
//  Copyright © 2015 dvor. All rights reserved.
//

extension Array {
    func each(closure: (Element) -> Void) {
        for item in self {
            closure(item)
        }
    }
}
