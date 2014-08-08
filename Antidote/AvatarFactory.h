//
//  AvatarFactory.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 08.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AvatarFactory : NSObject

+ (UIImage *)avatarFromString:(NSString *)string side:(CGFloat)side;

@end
