//
//  OCTDBFriendRequest.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 19.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Realm/Realm.h>
#import "OCTFriendRequest.h"

@interface OCTDBFriendRequest : RLMObject

@property NSString *publicKey;
@property NSString *message;
@property NSTimeInterval dateInterval;

@end
