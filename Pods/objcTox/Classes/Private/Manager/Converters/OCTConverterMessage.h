//
//  OCTConverterMessage.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 05.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTConverterProtocol.h"
#import "OCTConverterFriend.h"

@interface OCTConverterMessage : NSObject <OCTConverterProtocol>

@property (strong, nonatomic) OCTConverterFriend *converterFriend;

@end
