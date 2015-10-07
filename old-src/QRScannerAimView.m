//
//  QRScannerAimView.m
//  Antidote
//
//  Created by Nikolay Palamar on 12/04/15.
//  Copyright (c) 2015 dvor. All rights reserved.
//

#import "QRScannerAimView.h"
#import "AppearanceManager.h"
#import "AppearanceManager.h"

@interface QRScannerAimView ()

@property (strong, nonatomic) CAShapeLayer *dashLayer;

@end

@implementation QRScannerAimView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }

    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    self.dashLayer.path = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    self.dashLayer.frame = self.bounds;
}

#pragma mark - Private Logic

- (void)commonInit
{
    CGColorRef strokeColor = [[[AppContext sharedContext].appearance textMainColor] CGColor];
    CGColorRef fillColor = [[[[AppContext sharedContext].appearance bubbleIncomingColor] colorWithAlphaComponent:0.5f] CGColor];

    self.dashLayer = [CAShapeLayer layer];
    self.dashLayer.strokeColor = strokeColor;
    self.dashLayer.fillColor = fillColor;
    self.dashLayer.lineDashPattern = @[ @20, @5 ];
    self.dashLayer.lineWidth = 2.0f;
    [self.layer addSublayer:self.dashLayer];
}

@end
