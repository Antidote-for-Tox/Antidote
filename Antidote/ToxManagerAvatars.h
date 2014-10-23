//
//  ToxManagerAvatars.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 23.10.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ToxManager.h"

@interface ToxManagerAvatars : NSObject

- (instancetype)initOnToxQueueWithToxManager:(ToxManager *)manager;

- (void)qUpdateAvatar:(UIImage *)image;

- (BOOL)synchronizedUserHasAvatar;
- (UIImage *)synchronizedUserAvatar;

@end
