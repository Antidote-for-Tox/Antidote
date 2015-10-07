//
//  StatusCircleView.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 19.07.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "StatusCircleView.h"
#import "UIColor+Utilities.h"
#import "AppearanceManager.h"

@interface StatusCircleView ()

@property (strong, nonatomic) UIView *colorView;

@end

@implementation StatusCircleView

#pragma mark -  Public

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        self.colorView = [UIView new];
        [self addSubview:self.colorView];

        self.side = 10.0;
    }

    return self;
}

- (void)redraw
{
    const CGFloat colorSide = self.side;
    const CGFloat whiteSide = colorSide + (self.showWhiteBorder ? 4.0 : 0.0);

    CGRect frame = self.frame;
    frame.size.width = frame.size.height = whiteSide;
    self.frame = frame;

    frame = CGRectZero;
    frame.size.width = frame.size.height = colorSide;
    frame.origin.x = frame.origin.y = (whiteSide - colorSide) / 2;
    self.colorView.frame = frame;

    self.layer.cornerRadius = self.frame.size.width / 2;
    self.colorView.layer.cornerRadius = colorSide / 2;

    self.backgroundColor = [UIColor whiteColor];

    if (self.status == StatusCircleStatusOffline) {
        self.colorView.backgroundColor = [[AppContext sharedContext].appearance statusOfflineColor];
    }
    else if (self.status == StatusCircleStatusOnline) {
        self.colorView.backgroundColor = [[AppContext sharedContext].appearance statusOnlineColor];
    }
    else if (self.status == StatusCircleStatusAway) {
        self.colorView.backgroundColor = [[AppContext sharedContext].appearance statusAwayColor];
    }
    else if (self.status == StatusCircleStatusBusy) {
        self.colorView.backgroundColor = [[AppContext sharedContext].appearance statusBusyColor];
    }
}

@end
