//
//  OCTChat+Private.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 27.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTChat.h"

@interface OCTChat (Private)

@property (copy, nonatomic, readwrite) NSString *uniqueIdentifier;

@property (strong, nonatomic, readwrite) NSArray *friends;
@property (strong, nonatomic, readwrite) OCTMessageAbstract *lastMessage;

@property (copy, nonatomic) void (^enteredTextUpdateBlock)(NSString *enteredText);
@property (copy, nonatomic) void (^lastReadDateUpdateBlock)(NSDate *lastReadDate);

@end
