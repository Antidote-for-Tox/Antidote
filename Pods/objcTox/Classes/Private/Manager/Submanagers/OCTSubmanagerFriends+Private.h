//
//  OCTSubmanagerFriends+Private.h
//  objcTox
//
//  Created by Dmytro Vorobiov on 16.04.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "OCTSubmanagerFriends.h"
#import "OCTSubmanagerDataSource.h"
#import "OCTToxDelegate.h"

@interface OCTSubmanagerFriends (Private) <OCTToxDelegate>

@property (weak, nonatomic) id<OCTSubmanagerDataSource> dataSource;

- (void)configure;

@end
