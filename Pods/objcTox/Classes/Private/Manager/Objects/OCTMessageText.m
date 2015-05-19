//
//  OCTMessageText.m
//  objcTox
//
//  Created by Dmytro Vorobiov on 15.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTMessageText.h"

@interface OCTMessageText ()

@property (strong, nonatomic, readwrite) NSString *text;
@property (assign, nonatomic, readwrite) BOOL isDelivered;
@property (assign, nonatomic, readwrite) OCTToxMessageType type;

@end

@implementation OCTMessageText

@end
