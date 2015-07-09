//
//  TabBarItemProtocol.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 09.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TabBarItemProtocol <NSObject>

@property (assign, nonatomic) BOOL selected;
@property (copy, nonatomic) void (^didTapOnItem)(id item);

@end
