//
//  OCTDBMessageText.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 24.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Realm/Realm.h>
#import "OCTMessageText.h"

@interface OCTDBMessageText : RLMObject

@property NSString *text;
@property BOOL isDelivered;
@property NSInteger type;
@property int messageId;

- (instancetype)initWithMessageText:(OCTMessageText *)message;

@end
