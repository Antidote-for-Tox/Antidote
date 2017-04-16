//
//  ResultsExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 26/04/2017.
//  Copyright © 2017 dvor. All rights reserved.
//

import Foundation

extension Results where T : OCTMessageAbstract {
    func undeliveredMessages() -> Results<T> {
        let undeliveredPredicate = NSPredicate(format: "messageText != nil AND messageText.isDelivered == NO AND senderUniqueIdentifier == nil")
        return self.objects(with: undeliveredPredicate)
    }
}

