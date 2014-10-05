//
//  AvatarManager.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 05.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvatarManager : NSObject

+ (UIImage *)avatarInCurrentProfileWithClientId:(NSString *)clientId
                       orCreateAvatarFromString:(NSString *)string
                                       withSide:(CGFloat)side;

+ (UIImage *)avatarFromString:(NSString *)string side:(CGFloat)side;

+ (void)clearCache;

@end
