//
//  ToxIdView.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 02.08.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "ToxIdView.h"
#import "UIView+Utilities.h"
#import "NSString+Utilities.h"

@interface ToxIdView()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *qrButton;
@property (strong, nonatomic) CopyLabel *valueLabel;

@end

@implementation ToxIdView

- (instancetype)initWithId:(NSString *)toxId
{
    self = [super init];

    if (self) {
        [self createSubviews];
        self.valueLabel.text = toxId;

        [self adjustSubviews];
    }
    return self;
}

#pragma mark -  Actions

- (void)qrButtonPressed
{
    [self.delegate toxIdView:self wantsToShowQRWithText:self.valueLabel.text];
}

#pragma mark -  Private

- (void)createSubviews
{
    self.titleLabel = [self addLabelWithTextColor:[UIColor blackColor]
                                          bgColor:[UIColor clearColor]];
    self.titleLabel.text = NSLocalizedString(@"My Tox ID", @"Settings");

    self.qrButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.qrButton setTitle:NSLocalizedString(@"QR", @"Settings") forState:UIControlStateNormal];
    [self.qrButton addTarget:self
                      action:@selector(qrButtonPressed)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.qrButton];

    self.valueLabel = [self addCopyLabelWithTextColor:[UIColor grayColor]
                                              bgColor:[UIColor clearColor]];
    self.valueLabel.numberOfLines = 0;
}

- (void)adjustSubviews
{
    const CGFloat viewWidth = 320.0;
    CGRect frame = CGRectZero;

    {
        [self.titleLabel sizeToFit];
        frame = self.titleLabel.frame;
        frame.origin.x = 10.0;
        frame.origin.y = 0.0;
        self.titleLabel.frame = frame;
    }

    {
        [self.qrButton sizeToFit];
        frame = self.qrButton.frame;
        frame.origin.x = viewWidth - frame.size.width - 20.0;
        frame.origin.y = self.titleLabel.frame.origin.y;
        self.qrButton.frame = frame;
    }

    {
        const CGFloat xIndentation = self.titleLabel.frame.origin.x;
        const CGFloat maxWidth = viewWidth - 2 * xIndentation;

        frame = CGRectZero;
        frame.size = [self.valueLabel.text stringSizeWithFont:self.valueLabel.font
                                            constrainedToSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        frame.origin.x = xIndentation;
        frame.origin.y = CGRectGetMaxY(self.titleLabel.frame) + 10.0;
        self.valueLabel.frame = frame;
    }

    frame = self.frame;
    frame.size.width = viewWidth;
    frame.size.height = CGRectGetMaxY(self.valueLabel.frame);
    self.frame = frame;
}

@end
