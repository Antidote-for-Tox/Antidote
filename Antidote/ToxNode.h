//
//  ToxNode.h
//  Antidote
//
//  Created by Dmitry Vorobyov on 9/2/14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToxNode : NSObject

@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) NSUInteger port;
@property (strong, nonatomic) NSString *publicKey;

+ (ToxNode *)nodeWithAddress:(NSString *)address port:(NSUInteger)port publicKey:(NSString *)publicKey;

@end
