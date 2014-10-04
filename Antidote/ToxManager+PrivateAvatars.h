//
//  ToxManager+PrivateAvatars.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 27.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxManager.h"

@interface ToxManager (PrivateAvatars)

- (void)qRegisterAvatarCallbacksAndSetup;
- (void)qUpdateAvatar:(UIImage *)image;

- (BOOL)synchronizedUserHasAvatar;
- (UIImage *)synchronizedUserAvatar;

@end
