//
//  ToxFriend.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxFriend : NSObject

@property (strong, nonatomic) NSString *publicKey;

+ (ToxFriend *)friendWithPublicKey:(NSString *)publicKey;

- (NSString *)clientId;

@end
