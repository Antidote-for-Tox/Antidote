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

#pragma mark -  Methods

- (void)createDefaultValuesIfNeeded
{
    if (! self.uShowMessageInLocalNotification) {
        self.uShowMessageInLocalNotification = @(YES);
    }

    if (! self.uChatBackgroundImageBlurEnable) {
        self.uChatBackgroundImageBlurEnable = @(YES);
    }
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

GENERATE_OBJECT(PendingFriendRequests,           @"pending-friend-requests",             NSArray *)
GENERATE_OBJECT(CurrentColorscheme,              @"current-colorscheme",                 NSNumber *)
GENERATE_OBJECT(FriendsSort,                     @"friends-sort",                        NSNumber *)
GENERATE_OBJECT(CurrentProfileFileName,          @"current-profile-filename",            NSString *)
GENERATE_OBJECT(ShowMessageInLocalNotification,  @"show-message-in-local-notification",  NSNumber *)
GENERATE_OBJECT(ChatBackgroundImageBlurEnable,   @"chat-background-view-enable",         NSNumber *)
GENERATE_OBJECT(ChatSelectedBackgroundIndex,     @"chat-selected-background-index",      NSNumber *)

@end