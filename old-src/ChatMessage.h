//
//  ChatMessage.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 26.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JSQMessageData.h"
#import "OCTMessageAbstract.h"

@interface ChatMessage : NSObject <JSQMessageData>

- (instancetype)initWithMessage:(OCTMessageAbstract *)message;

@end
