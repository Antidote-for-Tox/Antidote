//
//  NSDateFormatterExtension.swift
//  Antidote
//
//  Created by Dmytro Vorobiov on 02.01.16.
//  Copyright © 2016 dvor. All rights reserved.
//

import Foundation

extension NSDateFormatter {
    enum Type {
        case Time
        case DateAndTime
        case RelativeDate
        case RelativeDateAndTime
    }

    convenience init(type: Type) {
        self.init()

        switch type {
            case .Time:
                dateFormat = "H:mm"
            case .DateAndTime:
                dateStyle = .ShortStyle
                timeStyle = .ShortStyle
                doesRelativeDateFormatting = false
            case .RelativeDate:
                dateStyle = .ShortStyle
                timeStyle = .NoStyle
                doesRelativeDateFormatting = true
            case .RelativeDateAndTime:
                dateStyle = .ShortStyle
                timeStyle = .ShortStyle
                doesRelativeDateFormatting = true
        }
    }
}
