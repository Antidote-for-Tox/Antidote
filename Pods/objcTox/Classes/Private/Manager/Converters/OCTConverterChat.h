//
//  OCTConverterChat.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 05.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTConverterProtocol.h"
#import "OCTConverterMessage.h"
#import "OCTConverterFriend.h"

@class OCTConverterChat;

@protocol OCTConverterChatDelegate <NSObject>

- (void)converterChat:(OCTConverterChat *)converter updateDBChatWithBlock:(void (^)())block;

@end

@interface OCTConverterChat : NSObject <OCTConverterProtocol>

@property (weak, nonatomic) id<OCTConverterChatDelegate> delegate;

@property (strong, nonatomic) OCTConverterMessage *converterMessage;
@property (strong, nonatomic) OCTConverterFriend *converterFriend;

@end
