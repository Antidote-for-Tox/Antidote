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
        self.backgroundColor = [AppearanceManager statusOfflineColor];
        self.backgroundColor = [UIColor lightGrayColor];
    }
    else if (self.status == StatusCircleStatusOnline) {
        self.backgroundColor = [AppearanceManager statusOnlineColor];
    }
    else if (self.status == StatusCircleStatusAway) {
        self.backgroundColor = [AppearanceManager statusAwayColor];
    }
    else if (self.status == StatusCircleStatusBusy) {
        self.backgroundColor = [AppearanceManager statusBusyColor];
    }
}

@end
