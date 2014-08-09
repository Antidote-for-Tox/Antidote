//
//  TimeFormatter.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TimeFormatterType) {
    TimeFormatterTypeTime,
    TimeFormatterTypeRelativeDateAndTime,
    TimeFormatterTypeRelativeDate,
};

@interface TimeFormatter : NSObject

+ (instancetype)sharedInstance;

- (NSString *)stringFromDate:(NSDate *)date type:(TimeFormatterType)type;

- (BOOL)areSameDays:(NSDate *)first and:(NSDate *)second;

@end
