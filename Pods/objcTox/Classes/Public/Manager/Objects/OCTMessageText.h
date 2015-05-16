//
//  OCTMessageText.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 15.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTMessageAbstract.h"
#import "OCTToxConstants.h"

/**
 * Simple text message.
 */
@interface OCTMessageText : OCTMessageAbstract

/**
 * The text of the message.
 */
@property (strong, nonatomic, readonly) NSString *text;

/**
 * Indicate if message is delivered. Actual only for outgoing messages.
 */
@property (assign, nonatomic, readonly) BOOL isDelivered;

/**
 * Type of the message.
 */
@property (assign, nonatomic, readonly) OCTToxMessageType type;

@end
