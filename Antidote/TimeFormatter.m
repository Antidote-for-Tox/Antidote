//
//  TimeFormatter.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 07.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "TimeFormatter.h"

@interface TimeFormatter()

@property (strong, nonatomic, readonly) NSDateFormatter *messageTimeFormatter;
@property (strong, nonatomic, readonly) NSDateFormatter *messageRelativeFormatter;
@property (strong, nonatomic, readonly) NSCalendar *currentCalendar;

@end

@implementation TimeFormatter
@synthesize messageTimeFormatter         = _messageTimeFormatter;
@synthesize messageRelativeFormatter     = _messageRelativeFormatter;
@synthesize currentCalendar              = _currentCalendar;

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    if (self = [super init]) {

    }

    return self;
}

+ (instancetype)sharedInstance
{
    static TimeFormatter *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[TimeFormatter alloc] initPrivate];
    });

    return instance;
}

#pragma mark -  Properties

- (NSDateFormatter *)messageTimeFormatter
{
    if (! _messageTimeFormatter) {
        _messageTimeFormatter = [NSDateFormatter new];
        _messageTimeFormatter.dateFormat = @"H:mm";
    }

    return _messageTimeFormatter;
}

- (NSDateFormatter *)messageRelativeFormatter
{
    if (! _messageRelativeFormatter) {
        _messageRelativeFormatter = [NSDateFormatter new];
        _messageRelativeFormatter.dateStyle = NSDateFormatterShortStyle;
        _messageRelativeFormatter.timeStyle = NSDateFormatterShortStyle;
        _messageRelativeFormatter.doesRelativeDateFormatting = YES;
    }

    return _messageRelativeFormatter;
}

- (NSCalendar *)currentCalendar
{
    if (! _currentCalendar) {
        _currentCalendar = [NSCalendar currentCalendar];
    }

    return _currentCalendar;
}

#pragma mark -  Public

- (NSString *)timeStringFromDate:(NSDate *)date
{
    if (! date) {
        return nil;
    }

    return [self.messageTimeFormatter stringFromDate:date];
}

- (NSString *)stringFromDate:(NSDate *)originalDate
{
    if (! originalDate) {
        return nil;
    }

    return [self.messageRelativeFormatter stringFromDate:originalDate];
}

- (BOOL)doHaveSameDay:(NSDate *)first and:(NSDate *)second
{
    const NSUInteger components = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;

    NSDateComponents *dc = [self.currentCalendar components:components fromDate:first];
    NSDate *firstNormalized = [self.currentCalendar dateFromComponents:dc];

    dc = [self.currentCalendar components:components fromDate:second];
    NSDate *secondNormalized = [self.currentCalendar dateFromComponents:dc];

    return [firstNormalized isEqualToDate:secondNormalized];
}

@end
