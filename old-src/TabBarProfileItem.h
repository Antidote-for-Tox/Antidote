//
//  TabBarProfileItem.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 09.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TabBarItemProtocol.h"
#import "StatusCircleView.h"

@interface TabBarProfileItem : UIView <TabBarItemProtocol>

@property (assign, nonatomic) StatusCircleStatus status;

@end
