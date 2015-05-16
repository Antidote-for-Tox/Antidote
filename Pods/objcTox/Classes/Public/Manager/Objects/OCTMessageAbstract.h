//
//  OCTMessageAbstract.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 14.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTFriend.h"

/**
 * An abstract message that represents one chunk of chat history.
 */
@interface OCTMessageAbstract : NSObject

/**
 * The date when message was send/received.
 */
@property (strong, nonatomic, readonly) NSDate *date;

/**
 * The sender of the message. If the message if outgoing sender is nil.
 */
@property (strong, nonatomic, readonly) OCTFriend *sender;

/**
 * Indicates if message is outgoing or incoming.
 * In case if it is incoming you can check `sender` property for message sender.
 */
- (BOOL)isOutgoing;

@end
