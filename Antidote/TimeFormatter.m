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
@property (strong, nonatomic, readonly) NSDateFormatter *messageRelativeDateAndTimeFormatter;
@property (strong, nonatomic, readonly) NSDateFormatter *messageRelativeDateFormatter;
@property (strong, nonatomic, readonly) NSCalendar *currentCalendar;

@end

@implementation TimeFormatter
@synthesize messageTimeFormatter                = _messageTimeFormatter;
@synthesize messageRelativeDateAndTimeFormatter = _messageRelativeDateAndTimeFormatter;
@synthesize messageRelativeDateFormatter        = _messageRelativeDateFormatter;
@synthesize currentCalendar                     = _currentCalendar;

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

- (NSDateFormatter *)messageRelativeDateAndTimeFormatter
{
    if (! _messageRelativeDateAndTimeFormatter) {
        _messageRelativeDateAndTimeFormatter = [NSDateFormatter new];
        _messageRelativeDateAndTimeFormatter.dateStyle = NSDateFormatterShortStyle;
        _messageRelativeDateAndTimeFormatter.timeStyle = NSDateFormatterShortStyle;
        _messageRelativeDateAndTimeFormatter.doesRelativeDateFormatting = YES;
    }

    return _messageRelativeDateAndTimeFormatter;
}

- (NSDateFormatter *)messageRelativeDateFormatter
{
    if (! _messageRelativeDateFormatter) {
        _messageRelativeDateFormatter = [NSDateFormatter new];
        _messageRelativeDateFormatter.dateStyle = NSDateFormatterShortStyle;
        _messageRelativeDateFormatter.timeStyle = NSDateFormatterNoStyle;
        _messageRelativeDateFormatter.doesRelativeDateFormatting = YES;
    }

    return _messageRelativeDateFormatter;
}

- (NSCalendar *)currentCalendar
{
    if (! _currentCalendar) {
        _currentCalendar = [NSCalendar currentCalendar];
    }

    return _currentCalendar;
}

#pragma mark -  Public

- (NSString *)stringFromDate:(NSDate *)date type:(TimeFormatterType)type
{
    if (! date) {
        return nil;
    }

    if (type == TimeFormatterTypeTime) {
        return [self.messageTimeFormatter stringFromDate:date];
    }
    else if (type == TimeFormatterTypeRelativeDateAndTime) {
        return [self.messageRelativeDateAndTimeFormatter stringFromDate:date];
    }
    else if (type == TimeFormatterTypeRelativeDate) {
        return [self.messageRelativeDateFormatter stringFromDate:date];
    }

    return nil;
}

- (BOOL)areSameDays:(NSDate *)first and:(NSDate *)second
{
    const NSUInteger components = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;

    NSDateComponents *dc = [self.currentCalendar components:components fromDate:first];
    NSDate *firstNormalized = [self.currentCalendar dateFromComponents:dc];

    dc = [self.currentCalendar components:components fromDate:second];
    NSDate *secondNormalized = [self.currentCalendar dateFromComponents:dc];

    return [firstNormalized isEqualToDate:secondNormalized];
}

@end
