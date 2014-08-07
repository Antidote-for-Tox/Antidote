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
@property (strong, nonatomic, readonly) NSDateFormatter *messageWeekdayFormatter;
@property (strong, nonatomic, readonly) NSDateFormatter *messageDateFormatter;
@property (strong, nonatomic, readonly) NSDateFormatter *messageDateWithYearFormatter;
@property (strong, nonatomic, readonly) NSCalendar *currentCalendar;

@end

@implementation TimeFormatter
@synthesize messageTimeFormatter         = _messageTimeFormatter;
@synthesize messageWeekdayFormatter      = _messageWeekdayFormatter;
@synthesize messageDateFormatter         = _messageDateFormatter;
@synthesize messageDateWithYearFormatter = _messageDateWithYearFormatter;
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

- (NSDateFormatter *)messageWeekdayFormatter
{
    if (! _messageWeekdayFormatter) {
        _messageWeekdayFormatter = [NSDateFormatter new];
        _messageWeekdayFormatter.dateFormat = @"EEEE";
    }

    return _messageWeekdayFormatter;
}

- (NSDateFormatter *)messageDateFormatter
{
    if (! _messageDateFormatter) {
        _messageDateFormatter = [NSDateFormatter new];
        _messageDateFormatter.dateFormat = @"EEE, MMM d";
    }

    return _messageDateFormatter;
}

- (NSDateFormatter *)messageDateWithYearFormatter
{
    if (! _messageDateFormatter) {
        _messageDateFormatter = [NSDateFormatter new];
        _messageDateFormatter.dateFormat = @"yyyy, MMM d";
    }

    return _messageDateFormatter;
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

    const NSUInteger components = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;

    NSDateComponents *dc = [self.currentCalendar components:components fromDate:originalDate];
    NSDate *originalNormalized = [self.currentCalendar dateFromComponents:dc];

    dc = [self.currentCalendar components:components fromDate:[NSDate date]];
    NSDate *today = [self.currentCalendar dateFromComponents:dc];

    if ([today isEqualToDate:originalNormalized]) {

        return [self.messageTimeFormatter stringFromDate:originalDate];
    }

    [dc setHour:-24];
    NSDate *yesterday = [self.currentCalendar dateFromComponents:dc];

    if ([yesterday isEqualToDate:originalNormalized]) {

        return NSLocalizedString(@"Yesterday", @"chat time");
    }

    [dc setHour:- 24 * 6];
    NSDate *weekAgo = [self.currentCalendar dateFromComponents:dc];

    if ([weekAgo compare:originalNormalized] == NSOrderedAscending) {

        return [self.messageWeekdayFormatter stringFromDate:originalDate];
    }

    dc = [self.currentCalendar components:components fromDate:[NSDate date]];
    NSDateComponents *originalDC = [self.currentCalendar components:components fromDate:originalNormalized];

    if (dc.year < originalDC.year) {

        return [self.messageDateWithYearFormatter stringFromDate:originalDate];
    }

    return [self.messageDateFormatter stringFromDate:originalDate];
}

@end
