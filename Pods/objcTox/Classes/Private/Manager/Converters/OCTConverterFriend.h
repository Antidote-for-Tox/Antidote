//
//  OCTConverterFriend.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 03.05.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTConverterProtocol.h"
#import "OCTTox.h"
#import "OCTFriend.h"

@class OCTConverterFriend;

@protocol OCTConverterFriendDataSource <NSObject>

- (OCTTox *)converterFriendGetTox:(OCTConverterFriend *)converterFriend;

@end

/**
 * Note that OCTDBFriend has only friendNumber property, thus sortDescriptor is limited to it.
 * In case if another property will be passed converter will return nil.
 */
@interface OCTConverterFriend : NSObject <OCTConverterProtocol>

@property (weak, nonatomic) id<OCTConverterFriendDataSource> dataSource;

- (OCTFriend *)friendFromFriendNumber:(OCTToxFriendNumber)friendNumber;

@end
