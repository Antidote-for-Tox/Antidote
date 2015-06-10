//
//  CustomLogFormatter.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 18.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CustomLogFormatter.h"

@interface CustomLogFormatter ()

@property (atomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation CustomLogFormatter

- (id)init
{
    if (self = [super init]) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"dd/MM hh:mm:ss:SSS"];
    }

    return self;
}

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *logLevel;
    switch (logMessage->logFlag) {
        case LOG_FLAG_ERROR: logLevel = @"[ERROR]";
            break;
        case LOG_FLAG_WARN: logLevel = @"[WARN] ";
            break;
        case LOG_FLAG_INFO: logLevel = @" INFO  ";
            break;
        default: logLevel = @" VERB  ";
            break;
    }

    NSString *date = [self.dateFormatter stringFromDate:logMessage->timestamp];

    NSString *message = [logMessage->logMsg stringByReplacingOccurrencesOfString:@"\n" withString:@"\n\t\t"];

    return [NSString stringWithFormat:@"%@ %@\t%@", logLevel, date, message];
}

@end
