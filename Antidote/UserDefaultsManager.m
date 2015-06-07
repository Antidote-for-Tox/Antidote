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

GENERATE_OBJECT(PendingFriendRequests,           @"pending-friend-requests",             NSArray *)
GENERATE_OBJECT(CurrentColorscheme,              @"current-colorscheme",                 NSNumber *)
GENERATE_OBJECT(FriendsSort,                     @"friends-sort",                        NSNumber *)
GENERATE_OBJECT(CurrentProfileName,              @"current-profile-name",                NSString *)
GENERATE_OBJECT(ShowMessageInLocalNotification,  @"show-message-in-local-notification",  NSNumber *)
GENERATE_OBJECT(Ipv6Enabled,                     @"ipv6-enabled",                        NSNumber *)
GENERATE_OBJECT(UdpEnabled,                      @"udp-enabled",                         NSNumber *)

@end
