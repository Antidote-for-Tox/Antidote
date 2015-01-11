//
//  CellWithToxId.m
//  Antidote
//
//  Created by Dmitry Vorobyov on 13.09.14.
//  Copyright (c) 2014 dvor. All rights reserved.
//

#import "CellWithToxId.h"
#import "UIView+Utilities.h"
#import "NSString+Utilities.h"

@interface CellWithToxId()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *qrButton;
@property (strong, nonatomic) CopyLabel *valueLabel;

@end

@implementation CellWithToxId

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createSubviews];
    }
    return self;
}

#pragma mark -  Actions

- (void)qrButtonPressed
{
    [self.delegate cellWithToxIdQrButtonPressed:self];
}

#pragma mark -  Public

- (void)redraw
{
    self.titleLabel.text = self.title;
    self.valueLabel.text = self.toxId;

    [self adjustSubviews];
}

+ (CGFloat)height
{
    return 100.0;
}

#pragma mark -  Private

- (void)createSubviews
{
    self.titleLabel = [self.contentView addLabelWithTextColor:[UIColor blackColor]
                                                      bgColor:[UIColor clearColor]];

    self.qrButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.qrButton setTitle:NSLocalizedString(@"QR", @"CellWithToxId") forState:UIControlStateNormal];
    [self.qrButton addTarget:self
                      action:@selector(qrButtonPressed)
            forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.qrButton];

    self.valueLabel = [self.contentView addCopyLabelWithTextColor:[UIColor grayColor]
                                                          bgColor:[UIColor clearColor]];
    self.valueLabel.numberOfLines = 3;
}

- (void)adjustSubviews
{
    const CGFloat viewWidth = self.bounds.size.width;
    CGRect frame = CGRectZero;

    {
        [self.titleLabel sizeToFit];
        frame = self.titleLabel.frame;
        frame.origin.x = 10.0;
        frame.origin.y = 5.0;
        self.titleLabel.frame = frame;
    }

    {
        [self.qrButton sizeToFit];
        frame = self.qrButton.frame;
        frame.origin.x = viewWidth - frame.size.width - self.titleLabel.frame.origin.x;
        frame.origin.y = self.titleLabel.frame.origin.y +
            (self.titleLabel.frame.size.height - frame.size.height) / 2;
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
}

@end
