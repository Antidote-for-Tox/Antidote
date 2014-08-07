//
//  TimeFormatter.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeFormatter : NSObject

+ (instancetype)sharedInstance;

- (NSString *)timeStringFromDate:(NSDate *)date;
- (NSString *)stringFromDate:(NSDate *)date;

@end
