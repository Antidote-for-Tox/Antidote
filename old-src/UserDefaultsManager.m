//
//  UserDefaultsManager.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 19.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "UserDefaultsManager.h"

@implementation UserDefaultsManager

#pragma mark - Properties

/**
 * theProperty - property without "u" prefix
 *
 * Example:
 * @property NSString *uMyString;
 *
 * GENERATE_OBJECT(MyString, @"my-string", NSString *)
 */
#define GENERATE_OBJECT(theProperty, theKey, theType) \
    - (void)setU ## theProperty:(theType)object \
    { \
        @synchronized(self) { \
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; \
            [defaults setObject:object forKey:theKey]; \
            [defaults synchronize]; \
        } \
    } \
\
    - (theType)u ## theProperty \
    { \
        @synchronized(self) { \
            return [[NSUserDefaults standardUserDefaults] objectForKey:theKey]; \
        } \
    }

/**
 * theProperty - property without "u" prefix
 *
 * Example:
 * @property NSInteger uMyInt;
 *
 * GENERATE_VARIABLE(MyInt, kMyIntKey, NSInteger, integerValue)
 */
#define GENERATE_VALUE(theProperty, theKey, theType, theReturnType) \
    - (void)setU ## theProperty:(theType)value \
    { \
        @synchronized(self) { \
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; \
            [defaults setObject:@(value) forKey:theKey]; \
            [defaults synchronize]; \
        } \
    } \
\
    - (theType)u ## theProperty \
    { \
        @synchronized(self) { \
            NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:theKey]; \
            return [number theReturnType]; \
        } \
    }

GENERATE_OBJECT(PendingFriendRequests,           @"user-info/pending-friend-requests",             NSArray *)
GENERATE_OBJECT(CurrentColorscheme,              @"user-info/current-colorscheme",                 NSNumber *)
GENERATE_OBJECT(FriendsSort,                     @"user-info/friends-sort",                        NSNumber *)
GENERATE_OBJECT(LastActiveProfile,               @"user-info/last-active-profile",                 NSString *)
GENERATE_VALUE(IsUserLoggedIn,                  @"user-info/is-user-logged-in",                   BOOL, boolValue)
GENERATE_OBJECT(ShowMessageInLocalNotification,  @"user-info/show-message-in-local-notification",  NSNumber *)
GENERATE_OBJECT(Ipv6Enabled,                     @"user-info/ipv6-enabled",                        NSNumber *)
GENERATE_OBJECT(UDPEnabled,                      @"user-info/udp-enabled",                         NSNumber *)


@end
