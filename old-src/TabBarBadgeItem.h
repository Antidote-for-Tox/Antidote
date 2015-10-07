//
//  TabBarBadgeItem.h
//  Antidote
//
//  Created by Dmytro Vorobiov on 09.07.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TabBarItemProtocol.h"

@interface TabBarBadgeItem : UIView <TabBarItemProtocol>

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *badgeText;

@end
