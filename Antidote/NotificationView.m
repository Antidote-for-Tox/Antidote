//
//  NotificationView.m
//  Antidote
//
//  Created by Dmytro Vorobiov on 27.06.15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "NotificationView.h"
#import "UIColor+Utilities.h"

@implementation NotificationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (! self) {
        return nil;
    }

    int color = arc4random_uniform(255);
    self.backgroundColor = [UIColor uColorWithRed:color green:56 blue:57 alpha:0.9];

    return self;
}

@end
