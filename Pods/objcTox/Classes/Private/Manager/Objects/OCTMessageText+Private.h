//
//  OCTMessageText+Private.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 24.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTMessageText.h"

@interface OCTMessageText (Private)

@property (strong, nonatomic, readwrite) NSString *text;
@property (assign, nonatomic, readwrite) BOOL isDelivered;
@property (assign, nonatomic, readwrite) OCTToxMessageType type;

@end
