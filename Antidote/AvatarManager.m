//
//  AvatarManager.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 05.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "AvatarManager.h"
#import "NSString+Utilities.h"
#import "ToxManager.h"
#import "ProfileManager.h"

@interface AvatarManager()

@property (strong, nonatomic) NSCache *avatarCache;

@end

@implementation AvatarManager

#pragma mark -  Lifecycle

- (id)init
{
    return nil;
}

- (id)initPrivate
{
    if (self = [super init]) {
        self.avatarCache = [NSCache new];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateFriendNotification:)
                                                     name:kToxFriendsContainerUpdateSpecificFriendNotification
                                                   object:nil];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (AvatarManager *)sharedInstance
{
    static AvatarManager *instance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        instance = [[AvatarManager alloc] initPrivate];
    });

    return instance;
}

#pragma mark -  Public

+ (UIImage *)avatarInCurrentProfileWithClientId:(NSString *)clientId
                       orCreateAvatarFromString:(NSString *)string
                                       withSide:(CGFloat)side
{
    if (clientId) {
        UIImage *image = [[self sharedInstance].avatarCache objectForKey:clientId];

        if (image) {
            return image;
        }

        NSString *path = [[ProfileManager sharedInstance] pathInAvatarDirectoryForFileName:clientId];

        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            image = [UIImage imageWithContentsOfFile:path];

            if (image) {
                [[self sharedInstance].avatarCache setObject:image forKey:clientId];
                return image;
            }
        }
    }

    return [self avatarFromString:string side:side];
}

+ (UIImage *)avatarFromString:(NSString *)string side:(CGFloat)side
{
    string = [self firstLettersOfTwoWordsLettersFromString:string];

    UILabel *label = [UILabel new];
    label.backgroundColor = [AppearanceManager bubbleOutgoingColor];
    label.layer.borderColor = [AppearanceManager textMainColor].CGColor;
    label.layer.borderWidth = 1.0;
    label.layer.masksToBounds = YES;
    label.textColor = [AppearanceManager textMainColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = string;

    CGFloat fontSize = 51;
    CGSize size;

    do {
        fontSize--;

        // PL - placeholder in case if avatar text is nil
        NSString *str = string ?: @"PL";

        size = [str stringSizeWithFont:[AppearanceManager fontHelveticaNeueLightWithSize:fontSize]];

    } while (MAX(size.width, size.height) > side);

    CGRect frame = CGRectZero;
    frame.size.width = frame.size.height = side;

    label.font = [AppearanceManager fontHelveticaNeueLightWithSize:(int) (fontSize * 0.6)];
    label.layer.cornerRadius = frame.size.width / 2;
    label.frame = frame;

    return [self imageWithView:label];
}

+ (void)clearCache
{
    [[self sharedInstance].avatarCache removeAllObjects];
}

#pragma mark -  Notifications

- (void)updateFriendNotification:(NSNotification *)notification
{
    ToxFriend *friend = notification.userInfo[kToxFriendsContainerUpdateKeyFriend];

    if (friend.clientId) {
        [self.avatarCache removeObjectForKey:friend.clientId];
    }
}

#pragma mark -  Private

+ (NSString *)firstLettersOfTwoWordsLettersFromString:(NSString *)string
{
    NSArray *array = [string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSString *result = nil;

    for (NSUInteger index = 0; index < array.count; index++) {
        NSString *word = array[index];

        if (! word.length) {
            continue;
        }

        NSString *firstLetter = [word substringToIndex:1];

        if (result.length == 2) {
            break;
        }
        else if (result.length == 1) {
            result = [result stringByAppendingString:firstLetter];
        }
        else {
            result = firstLetter;
        }
    }

    return [result uppercaseString];
}

+ (UIImage *)imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return image;
}

@end
