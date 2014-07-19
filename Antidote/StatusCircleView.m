//
//  StatusCircleView.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "StatusCircleView.h"
#import "UIColor+Utilities.h"

@implementation StatusCircleView

#pragma mark -  Public

- (void)redraw
{
    const CGFloat side = 10.0;

    CGRect frame = self.frame;
    frame.size.width = frame.size.height = side;
    self.frame = frame;

    self.layer.cornerRadius = side / 2;

    if (self.status == StatusCircleStatusOffline) {
        self.backgroundColor = [UIColor lightGrayColor];
    }
    else if (self.status == StatusCircleStatusOnline) {
        self.backgroundColor = [UIColor uColorOpaqueWithRed:92 green:184 blue:75];
    }
    else if (self.status == StatusCircleStatusAway) {
        self.backgroundColor = [UIColor uColorOpaqueWithRed:195 green:182 blue:41];
    }
    else if (self.status == StatusCircleStatusBusy) {
        self.backgroundColor = [UIColor uColorOpaqueWithRed:170 green:57 blue:59];
    }
    else if (self.status == StatusCircleStatusFriendRequest) {
        self.backgroundColor = [UIColor uColorOpaqueWithRed:57 green:132 blue:158];
    }
}

@end
