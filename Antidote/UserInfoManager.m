//
//  UserInfoManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "UserInfoManager.h"

@implementation UserInfoManager

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
    static UserInfoManager *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[UserInfoManager alloc] initPrivate];
    });

    return instance;
}

#pragma mark - Properties

/**
 * theProperty - property without "u" prefix
 *
 * Example:
 * @property NSString *uMyString;
 *
 * GENERATE_OBJECT(MyString, kMyStringKey, NSString *)
 */
#define GENERATE_OBJECT(theProperty, theKey, theType) \
- (void)setU##theProperty:(theType)object \
{ \
    @synchronized(self) { \
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; \
        [defaults setObject:object forKey:theKey]; \
        [defaults synchronize]; \
    } \
} \
\
- (theType)u##theProperty \
{ \
    @synchronized(self) { \
        return [[NSUserDefaults standardUserDefaults] objectForKey:theKey]; \
    } \
}

GENERATE_OBJECT(ToxData,                @"tox-data",                 NSData *)
GENERATE_OBJECT(PendingFriendRequests,  @"pending-friend-requests",  NSArray *)
GENERATE_OBJECT(AssociatedNames,        @"associated-names",         NSDictionary *)
GENERATE_OBJECT(CurrentColorscheme,     @"current-colorscheme",      NSNumber *)

@end
